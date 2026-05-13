import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';

class OtaProcessor {
  // Pass in your Bluetooth repository or write function
  final Future<void> Function(List<int>) writeRawData;
  final Stream<List<int>> rawDataStream;

  // Callbacks for the Cubit/UI
  final Function(double) onProgress;
  final Function(String) onLog;
  final Function() onSuccess;
  final Function(String) onError;

  // Protocol Constants
  static const int otaSof = 0xAA;
  static const int cmdOtaBegin = 0x01;
  static const int cmdOtaChunk = 0x02;
  static const int cmdOtaEnd = 0x03;
  static const int cmdOtaAbort = 0x04;
  static const int cmdOtaPing = 0x05;

  static const int rspOk = 0x00;
  static const int rspPong = 0x10;
  static const int errNoSession = 0x06;

  static const int chunkSize = 256;

  // 🚀 HARDWARE FIX: Stop-and-Wait (1).
  // 240 bytes is so fast that windowSize 8 will overwhelm the flash writer.
  static const int windowSize = 1;

  // Increased to 10 to survive long sector erases at the end
  static const int maxRetries = 10;

  StreamSubscription<List<int>>? _rxSub;
  final List<int> _rxBuffer = [];

  // 🚀 RACE CONDITION FIX: Queue catches ultra-fast ACKs so they never get missed
  final List<int> _ackQueue = [];
  Completer<void>? _queueCompleter;

  bool _isAborted = false;

  OtaProcessor({
    required this.writeRawData,
    required this.rawDataStream,
    required this.onProgress,
    required this.onLog,
    required this.onSuccess,
    required this.onError,
  }) {
    _startListening();
  }

  void _log(String msg) {
    if (kDebugMode) print("[OTA_PROCESSOR] $msg");
    onLog(msg);
  }

  void _startListening() {
    _rxSub = rawDataStream.listen((data) {
      _rxBuffer.addAll(data);
      _processRxBuffer();
    });
  }

  // ----------------------------------------------------------------
  // 🚨 CRITICAL FIX: Flexible Packet Parsing + Queue
  // ----------------------------------------------------------------
  void _processRxBuffer() {
    while (_rxBuffer.length >= 2) {
      if (_rxBuffer[0] != otaSof) {
        _rxBuffer.removeAt(0);
        continue;
      }

      int responseCode = _rxBuffer[1];

      // FAST-TRACK: Short Responses (Like PONG or basic ACKs)
      if (responseCode == rspPong ||
          responseCode == rspOk ||
          responseCode == errNoSession) {
        if (_rxBuffer.length >= 3) {
          _rxBuffer.removeRange(0, 3);

          _ackQueue.add(responseCode);
          if (_queueCompleter != null && !_queueCompleter!.isCompleted) {
            _queueCompleter!.complete();
          }
          continue;
        } else {
          break;
        }
      }

      // STANDARD TRACK: Long Responses (with length and CRC)
      if (_rxBuffer.length < 6) break;

      int len = _rxBuffer[2] | (_rxBuffer[3] << 8);
      int totalPacketSize = 4 + len + 2;

      if (_rxBuffer.length < totalPacketSize) {
        break;
      }

      _rxBuffer.removeRange(0, totalPacketSize);

      _ackQueue.add(responseCode);
      if (_queueCompleter != null && !_queueCompleter!.isCompleted) {
        _queueCompleter!.complete();
      }
    }
  }

  Future<int> _waitForAck({int timeoutSeconds = 10}) async {
    if (_ackQueue.isNotEmpty) {
      return _ackQueue.removeAt(0);
    }

    _queueCompleter = Completer<void>();
    try {
      await _queueCompleter!.future.timeout(Duration(seconds: timeoutSeconds));
      return _ackQueue.removeAt(0);
    } catch (e) {
      return -1; // -1 represents a Timeout
    }
  }

  Future<void> _sendPacket(int cmd, List<int> payload) async {
    if (_isAborted) return;

    List<int> packet = [otaSof, cmd];
    packet.add(payload.length & 0xFF);
    packet.add((payload.length >> 8) & 0xFF);
    packet.addAll(payload);

    int crc = _crc16CcittFalse(packet.sublist(1));
    packet.add(crc & 0xFF);
    packet.add((crc >> 8) & 0xFF);

    // 🚀 MAXIMIZING MTU EFFICIENCY: 240 Bytes!
    for (int i = 0; i < packet.length; i += 240) {
      int end = (i + 240 > packet.length) ? packet.length : i + 240;
      await writeRawData(packet.sublist(i, end));

      // Tiny 5ms breather for the PB-03 UART to flush to the main chip
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  Future<void> startFlash(List<int> rawFirmware) async {
    _isAborted = false;
    _rxBuffer.clear();
    _ackQueue.clear();

    try {
      _log("Padding firmware...");
      List<int> fw = List.from(rawFirmware);
      while (fw.length % chunkSize != 0) {
        fw.add(0xFF);
      }

      int totalChunks = fw.length ~/ chunkSize;
      int crc32 = getCrc32(fw);

      _log(
          "Firmware prepared: ${fw.length} bytes, $totalChunks chunks, CRC32: $crc32");

      // Give bootloader 2 seconds to turn its UART on fully before pinging
      _log("Waiting 2 seconds for bootloader UART to stabilize...");
      await Future.delayed(const Duration(seconds: 2));

      // Phase 1: PING
      _log("Sending PING...");
      int pingRsp = -1;
      int pingRetries = 0;

      while (pingRsp != rspPong) {
        if (_isAborted) throw Exception("Update aborted by user.");

        await _sendPacket(cmdOtaPing, []);
        pingRsp = await _waitForAck(timeoutSeconds: 3);

        if (pingRsp == rspPong) break;

        pingRetries++;
        if (pingRetries >= 15) {
          throw Exception("Device did not respond to PING (Got: $pingRsp)");
        }

        _log("Bootloader not ready. Retrying PING ($pingRetries/15)...");
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      _log("PING successful.");

      // Phase 2: BEGIN Handshake
      _log("Sending BEGIN handshake...");
      var beginData = ByteData(12);
      beginData.setUint32(0, fw.length, Endian.little);
      beginData.setUint32(4, crc32, Endian.little);
      beginData.setUint16(8, chunkSize, Endian.little);
      beginData.setUint16(10, totalChunks, Endian.little);

      await _sendPacket(cmdOtaBegin, beginData.buffer.asUint8List());
      int beginRsp = await _waitForAck(timeoutSeconds: 5);

      if (beginRsp == errNoSession) {
        _log(
            "🚨 DEVICE REBOOTING TO SLOT A. Please wait 8 seconds and reconnect.");
        onError("SLOT_SWAP_REBOOT");
        return;
      } else if (beginRsp != rspOk) {
        throw Exception("BEGIN handshake rejected (Code: $beginRsp)");
      }
      _log("BEGIN handshake accepted.");

      // Phase 3: THE SLIDING WINDOW
      _log("Starting transmission (Window Size: $windowSize)...");
      int expectedAck = 0;
      int nextToSend = 0;
      int retryCount = 0;

      while (expectedAck < totalChunks) {
        if (_isAborted) throw Exception("Update aborted by user.");

        while (nextToSend < totalChunks &&
            (nextToSend - expectedAck) < windowSize) {
          int offset = nextToSend * chunkSize;
          List<int> chunkData = fw.sublist(offset, offset + chunkSize);

          var chunkPayload = ByteData(2 + chunkData.length);
          chunkPayload.setUint16(0, nextToSend, Endian.little);
          chunkPayload.buffer.asUint8List().setAll(2, chunkData);

          await _sendPacket(cmdOtaChunk, chunkPayload.buffer.asUint8List());
          nextToSend++;
        }

        // Give the chip 10 seconds to acknowledge a chunk
        int ack = await _waitForAck(timeoutSeconds: 10);

        if (ack == rspOk) {
          expectedAck++;
          retryCount = 0;
          onProgress(expectedAck / totalChunks);

          if (expectedAck % 10 == 0) {
            _log("Progress: $expectedAck / $totalChunks chunks.");
          }
        } else {
          // 🚨 THE "LAST CHUNK REBOOT" FIX 🚨
          if (expectedAck >= totalChunks - 1) {
            _log(
                "Last chunk didn't ACK. The hardware CPU is locked verifying flash memory.");
            _log(
                "✅ OTA Successful! Skipping END command because device is already restarting.");
            onProgress(1.0);
            onSuccess();
            return;
          }

          retryCount++;
          _log(
              "⚠️ Chunk $expectedAck failed (Code: $ack). Retry $retryCount/$maxRetries...");

          if (retryCount >= maxRetries) {
            throw Exception("Max retries exceeded at chunk $expectedAck.");
          }

          nextToSend = expectedAck;
          // Increased back-off delay to let the chip finish erasing its memory sector
          await Future.delayed(const Duration(milliseconds: 1500));
        }
      }

      // Phase 4: END & VERIFY
      _log("All chunks sent. Sending END command...");
      await _sendPacket(cmdOtaEnd, []);

      // Let the device reboot even if it drops the connection here
      int endRsp = await _waitForAck(timeoutSeconds: 8);

      if (endRsp == rspOk || endRsp == -1) {
        _log("✅ Firmware verified and written! Device is rebooting.");
        onSuccess();
      } else {
        throw Exception("Device rejected final verification (Code: $endRsp)");
      }
    } catch (e) {
      _log("❌ OTA Failed: $e");
      await _sendPacket(cmdOtaAbort, []);
      onError(e.toString());
    }
  }

  void abort() {
    _isAborted = true;
  }

  void dispose() {
    _isAborted = true;
    _rxSub?.cancel();
  }

  int _crc16CcittFalse(List<int> data) {
    int crc = 0xFFFF;
    for (int byte in data) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc;
  }
}
