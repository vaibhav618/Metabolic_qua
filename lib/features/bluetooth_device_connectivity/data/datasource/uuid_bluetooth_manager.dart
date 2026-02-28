import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// ✅ NEW: link status so UI can show "Reconnecting..." for LINK_SUPERVISION_TIMEOUT etc.
enum BleLinkStatus { connecting, connected, reconnecting, disconnected }

class UuidBluetoothManager {
  static final UuidBluetoothManager _instance = UuidBluetoothManager._internal();
  factory UuidBluetoothManager() => _instance;

  UuidBluetoothManager._internal() {
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off ||
          state == BluetoothAdapterState.turningOff) {
        _handleBluetoothOff();
      }
    });
  }

  BluetoothDevice? _device;
  BluetoothCharacteristic? _notifyChar;
  BluetoothCharacteristic? _writeChar;

  final _connCtrl = StreamController<bool>.broadcast();
  final _dataCtrl = StreamController<String>.broadcast();
  final _readyCtrl = StreamController<bool>.broadcast();

  // ✅ NEW: link status stream (UI uses this)
  final _linkCtrl = StreamController<BleLinkStatus>.broadcast();
  Stream<BleLinkStatus> get linkStatusStream => _linkCtrl.stream;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;

  Timer? _scanLoopTimer;
  bool _stopScanRequested = false;
  DateTime? _lastScanResultAt;

  bool _isConnected = false;

  // ✅ guards
  bool _connecting = false;
  bool _reconnecting = false;
  String? _lastDeviceId;
  DateTime _lastDisconnectAt = DateTime.fromMillisecondsSinceEpoch(0);

  // ✅ optional health logging
  Timer? _rssiTimer;

  // ✅ allow auto reconnect
  bool autoReconnectEnabled = true;

  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid readCharacteristicUuid =
  Guid("49535343-1e4d-4bd9-ba61-23c647249616");
  final Guid writeCharacteristicUuid =
  Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connCtrl.stream;
  Stream<String> get dataStream => _dataCtrl.stream;
  Stream<bool> get deviceReadyStream => _readyCtrl.stream;

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("🟩 BLE_MGR | $msg");
    }
  }

  void _emitLink(BleLinkStatus s) {
    if (!_linkCtrl.isClosed) _linkCtrl.add(s);
  }

  void _handleBluetoothOff() {
    _log("Bluetooth OFF -> teardown");
    _isConnected = false;
    if (!_connCtrl.isClosed) _connCtrl.add(false);
    if (!_readyCtrl.isClosed) _readyCtrl.add(false);

    _emitLink(BleLinkStatus.disconnected); // ✅ NEW
    _teardown();
  }

  /// ✅ Optional helper (you already call this from cubit)
  Future<void> clearAllConnections() async {
    autoReconnectEnabled = false;
    try {
      await stopScan();
    } catch (_) {}
    try {
      await disconnect();
    } catch (_) {}
    autoReconnectEnabled = true;
  }

  // ✅ Scan with self-healing loop
  Future<void> startScan({
    void Function(List<ScanResult>)? onResults,
  }) async {
    _stopScanRequested = false;

    final s = await FlutterBluePlus.adapterState.first;
    if (s != BluetoothAdapterState.on) {
      _log("startScan blocked: adapterState=$s");
      return;
    }

    await stopScan();
    await Future.delayed(const Duration(milliseconds: 250));

    _lastScanResultAt = null;
    _log("startScan() with loop");

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      _lastScanResultAt = DateTime.now();
      onResults?.call(results);
    }, onError: (e) {
      _log("scanResults error: $e");
    });

    Future<void> startOneShot() async {
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      } catch (e) {
        _log("startScan oneShot error: $e");
      }
    }

    await startOneShot();

    _scanLoopTimer?.cancel();
    _scanLoopTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_stopScanRequested) return;

      final st = await FlutterBluePlus.adapterState.first;
      if (st != BluetoothAdapterState.on) return;

      final last = _lastScanResultAt;
      final noResultsRecently =
          last == null || DateTime.now().difference(last) > const Duration(seconds: 4);

      if (noResultsRecently) {
        _log("scanLoop: no results -> restarting scan");
        await startOneShot();
      }
    });
  }

  Future<void> stopScan() async {
    _log("stopScan()");
    _stopScanRequested = true;

    try {
      _scanLoopTimer?.cancel();
    } catch (_) {}
    _scanLoopTimer = null;

    try {
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  Future<void> connectById(String id) async {
    _log("connectById($id)");

    List<BluetoothDevice> connected = const [];
    try {
      connected = await FlutterBluePlus.connectedDevices;
    } catch (_) {}

    final already = connected.where((d) => d.remoteId.str == id).toList();
    if (already.isNotEmpty) {
      _log("already connected by OS -> connect(existing device)");
      return connect(already.first);
    }

    final found = Completer<void>();
    StreamSubscription<List<ScanResult>>? sub;

    await stopScan();
    await Future.delayed(const Duration(milliseconds: 200));

    sub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.remoteId.str == id) {
          _log("target found in scan -> stopScan + connect()");
          try {
            await FlutterBluePlus.stopScan();
            await sub?.cancel();
            await connect(r.device);
            if (!found.isCompleted) found.complete();
          } catch (e) {
            if (!found.isCompleted) found.completeError(e);
          }
          return;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
      await found.future;
    } finally {
      await sub?.cancel();
      await stopScan();
    }
  }

  Future<void> connect(
      BluetoothDevice device, {
        Duration readyTimeout = const Duration(seconds: 12),
      }) async {
    if (_connecting) {
      _log("connect() skipped: already connecting");
      return;
    }
    _connecting = true;

    _emitLink(BleLinkStatus.connecting); // ✅ NEW
    _log("connect(${device.remoteId.str})");
    await stopScan();

    // disconnect previous
    if (_device != null && _device!.remoteId != device.remoteId) {
      try {
        _log("disconnect previous device...");
        await _device?.disconnect();
      } catch (_) {}
    }

    _device = device;
    _lastDeviceId = device.remoteId.str;
    _teardownInternalFields();

    final connectedCompleter = Completer<void>();

    await _connSub?.cancel();
    _connSub = device.connectionState.listen((s) async {
      final connected = s == BluetoothConnectionState.connected;
      _log("device.connectionState => $s");

      _isConnected = connected;
      if (!_connCtrl.isClosed) _connCtrl.add(connected);

      if (connected) {
        _emitLink(BleLinkStatus.connected); // ✅ NEW
        try {
          if (Platform.isAndroid) {
            try {
              await device.requestMtu(247);
            } catch (_) {}
          }

          await _discoverAndSubscribeWithRetry();
          if (!_readyCtrl.isClosed) _readyCtrl.add(true);

          _startRssiLogging();

          if (!connectedCompleter.isCompleted) {
            connectedCompleter.complete();
          }
        } catch (e) {
          _log("discover/subscribe failed: $e");
          if (!connectedCompleter.isCompleted) {
            connectedCompleter.completeError(e);
          }
          await _hardResetLink();
          _teardown();

          _emitLink(BleLinkStatus.disconnected); // ✅ NEW

          if (autoReconnectEnabled && _lastDeviceId != null) {
            // ignore: unawaited_futures
            _autoReconnect(_lastDeviceId!);
          }
        }
      } else {
        _lastDisconnectAt = DateTime.now();
        _stopRssiLogging();

        if (!connectedCompleter.isCompleted) return;

        final prevId = _lastDeviceId;

        _emitLink(BleLinkStatus.disconnected); // ✅ NEW

        await _hardResetLink();
        _teardown();

        if (autoReconnectEnabled && prevId != null) {
          // ignore: unawaited_futures
          _autoReconnect(prevId);
        }
      }
    });

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (!msg.contains("already connected")) {
        _connecting = false;
        _emitLink(BleLinkStatus.disconnected); // ✅ NEW
        rethrow;
      }
    }

    try {
      await connectedCompleter.future.timeout(readyTimeout, onTimeout: () {
        throw TimeoutException("BLE connect timeout");
      });
    } finally {
      _connecting = false;
    }
  }

  // ✅ THIS is what makes reconnect “instant” in practice
  Future<void> _autoReconnect(String id) async {
    if (_reconnecting) return;
    if (_connecting) return;

    _reconnecting = true;
    _emitLink(BleLinkStatus.reconnecting); // ✅ NEW

    try {
      final since = DateTime.now().difference(_lastDisconnectAt);
      if (since < const Duration(milliseconds: 900)) {
        await Future.delayed(const Duration(milliseconds: 900) - since);
      }

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          _log("autoReconnect attempt $attempt -> connectById($id)");
          await connectById(id);
          _log("autoReconnect success");
          _emitLink(BleLinkStatus.connected); // ✅ NEW
          return;
        } catch (e) {
          _log("autoReconnect failed attempt $attempt: $e");
          await Future.delayed(Duration(milliseconds: 450 * attempt));
        }
      }

      // failed all attempts
      _emitLink(BleLinkStatus.disconnected); // ✅ NEW
    } finally {
      _reconnecting = false;
    }
  }

  // ✅ After supervision timeout, do a stronger cleanup
  Future<void> _hardResetLink() async {
    final d = _device;
    if (d == null) return;

    try {
      try {
        if (_notifyChar != null) {
          await _notifyChar!.setNotifyValue(false);
        }
      } catch (_) {}

      await _notifySub?.cancel();
    } catch (_) {}

    try {
      await d.disconnect();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> disconnect() async {
    _log("disconnect()");
    autoReconnectEnabled = false; // manual disconnect should not auto reconnect
    _emitLink(BleLinkStatus.disconnected); // ✅ NEW

    try {
      await _device?.disconnect();
    } catch (e) {
      if (kDebugMode) print("⚠️ disconnect() threw: $e");
    } finally {
      _teardown();
      autoReconnectEnabled = true;
    }
  }

  Future<void> _discoverAndSubscribeWithRetry() async {
    Object? lastErr;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _discoverAndSubscribe();
        return;
      } catch (e) {
        lastErr = e;
        _log("discover attempt $attempt failed: $e");
        await Future.delayed(Duration(milliseconds: 250 * attempt));
      }
    }
    throw Exception("Discover/subscribe failed: $lastErr");
  }

  Future<void> _discoverAndSubscribe() async {
    if (_device == null) throw Exception('No device');
    await Future.delayed(const Duration(milliseconds: 350));

    final services = await _device!.discoverServices();
    BluetoothCharacteristic? nChar;
    BluetoothCharacteristic? wChar;

    for (final s in services) {
      if (s.uuid == serviceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid == readCharacteristicUuid || (c.properties.notify && nChar == null)) {
            nChar = c;
          }
          if (c.uuid == writeCharacteristicUuid ||
              ((c.properties.write || c.properties.writeWithoutResponse) && wChar == null)) {
            wChar = c;
          }
        }
      }
    }

    if (nChar == null || wChar == null) {
      throw Exception('Chars not found');
    }

    _notifyChar = nChar;
    _writeChar = wChar;

    await _notifySub?.cancel();
    try {
      await _notifyChar!.setNotifyValue(true);
    } catch (_) {}

    _notifySub = _notifyChar!.onValueReceived.listen((value) {
      if (value.isNotEmpty && !_dataCtrl.isClosed) {
        _dataCtrl.add(String.fromCharCodes(value));
      }
    }, onError: (e) {
      _log("notify stream error: $e");
    });
  }

  Future<void> write(String data, {int maxRetries = 3}) async {
    if (_device == null || !_isConnected || _writeChar == null) return;

    final bytes = data.codeUnits;
    final withoutResponse =
        _writeChar!.properties.writeWithoutResponse && !_writeChar!.properties.write;

    for (int i = 1; i <= maxRetries; i++) {
      try {
        await _writeChar!.write(bytes, withoutResponse: withoutResponse);
        return;
      } catch (e) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 120 * i));
      }
    }
  }

  void _startRssiLogging() {
    _rssiTimer?.cancel();
    final d = _device;
    if (d == null) return;

    _rssiTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_isConnected) return;
      try {
        final rssi = await d.readRssi();
        _log("RSSI: $rssi dBm");
      } catch (_) {}
    });
  }

  void _stopRssiLogging() {
    try {
      _rssiTimer?.cancel();
    } catch (_) {}
    _rssiTimer = null;
  }

  void _teardownInternalFields() {
    _notifyChar = null;
    _writeChar = null;

    try {
      _notifySub?.cancel();
    } catch (_) {}
    _notifySub = null;
  }

  void _teardown() {
    _stopRssiLogging();
    _teardownInternalFields();

    try {
      _connSub?.cancel();
    } catch (_) {}
    _connSub = null;

    _isConnected = false;

    if (!_readyCtrl.isClosed) _readyCtrl.add(false);
    if (!_connCtrl.isClosed) _connCtrl.add(false);
  }

  void dispose() {
    _log("dispose()");
    stopScan();
  }

  Future<void> shutdown() async {
    _log("shutdown()");
    await stopScan();
    await disconnect();

    await _adapterStateSub?.cancel();
    _adapterStateSub = null;

    if (!_connCtrl.isClosed) await _connCtrl.close();
    if (!_dataCtrl.isClosed) await _dataCtrl.close();
    if (!_readyCtrl.isClosed) await _readyCtrl.close();

    // ✅ NEW
    if (!_linkCtrl.isClosed) await _linkCtrl.close();
  }

  Future<bool> getCurrentConnectionState() async {
    final d = _device;
    if (d == null) return false;

    final s = await d.connectionState.first;
    final connected = s == BluetoothConnectionState.connected;

    _isConnected = connected;
    if (!_connCtrl.isClosed) _connCtrl.add(connected);
    if (!_readyCtrl.isClosed) {
      _readyCtrl.add(connected && _notifyChar != null && _writeChar != null);
    }

    // ✅ NEW
    _emitLink(connected ? BleLinkStatus.connected : BleLinkStatus.disconnected);

    return connected;
  }
}