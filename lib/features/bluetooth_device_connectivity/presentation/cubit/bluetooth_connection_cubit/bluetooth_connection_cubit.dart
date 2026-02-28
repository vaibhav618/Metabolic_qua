import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';

import '../../../data/datasource/bluetooth_manager.dart';
import 'bluetooth_connection_state.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothRepository repo;

  Timer? _readyTimeoutTimer;

  StreamSubscription? _connSub;
  StreamSubscription? _dataSub;
  StreamSubscription? _readySub;
  StreamSubscription? _scanSub;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterSub;

  Timer? _scanRetryTimer;
  Timer? _pruneTimer;
  Timer? _scanKickTimer;

  // ✅ NEW
  StreamSubscription? _linkSub;

  static const Duration _readyTimeout = Duration(seconds: 5);

  static const Duration _scanRetryEvery = Duration(seconds: 3);
  static const Duration _deviceStaleAfter = Duration(seconds: 6);
  static const Duration _pruneEvery = Duration(seconds: 2);

  static const Duration _scanKickEvery = Duration(seconds: 7);
  static const Duration _scanKickGap = Duration(milliseconds: 200);

  bool _wasEverConnected = false;

  bool _handshakeCompleted = false;
  bool _handshakeInProgress = false;

  bool _initCalled = false;
  bool _scanRequested = false;
  bool _startingScan = false;
  bool deviceIsExhaleOrInhaleModeCalled = false;

  final _frameBuffer = _BleFrameBuffer();
  final Map<String, _SeenDevice> _seen = {};

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("🟦 BLE_CUBIT | $msg");
    }
  }

  void safeEmit(BluetoothConnectionState s) {
    if (!isClosed) {
      emit(s);
      _log(
        "EMIT => status=${s.status}, scan=${s.isScanning}, conn=${s.isConnected}, "
            "connecting=${s.isConnecting}, id=${s.connectingDeviceId}, ready=${s.deviceReady}, "
            "reconnecting=${s.isReconnecting}, linkMsg=${s.linkMessage}",
      );
    }
  }

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  Future<void> init() async {
    if (_initCalled) return;
    _initCalled = true;

    _listenAdapter();
    _listenConnection();
    _listenData();
    _listenDeviceReady();

    // ✅ NEW: listen link status from manager
    _listenLinkStatus();

    if (repo.isConnected) {
      _wasEverConnected = true;
      _handshakeCompleted = false;
      _handshakeInProgress = false;
      _frameBuffer.clear();

      safeEmit(state.copyWith(
        isConnected: true,
        isConnecting: false,
        status: BluetoothConnectionStatus.connected,
        isScanning: false,
        clearTextError: true,
        deviceIsInhaleOrExhaleMode: false,

        // ✅ clear reconnect UI
        isReconnecting: false,
        clearLinkMessage: true,
      ));

      await _checkAppReadiness();
      return;
    }

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.disconnected,
      isScanning: false,
      isConnecting: false,
      isConnected: false,
      devices: const [],
      deviceReady: false,
      isDeviceError: false,
      clearTextError: true,
      clearConnectingDeviceId: true,

      // ✅ clear reconnect UI
      isReconnecting: false,
      clearLinkMessage: true,
    ));

    _scanRequested = true;
    await _startScanFlow();
  }

  // ✅ NEW: convert manager link status -> UI flags only
  void _listenLinkStatus() {
    _linkSub?.cancel();

    _linkSub = UuidBluetoothManager().linkStatusStream.listen((s) {
      _log("LINK_STATUS => $s");

      switch (s) {
        case BleLinkStatus.reconnecting:
          safeEmit(state.copyWith(
            isReconnecting: true,
            linkMessage: "Connection lost. Reconnecting...",
            status: BluetoothConnectionStatus.connecting,
            deviceReady: false,
            isDeviceError: false,
            clearTextError: true,
          ));
          break;

        case BleLinkStatus.connecting:
          safeEmit(state.copyWith(
            isReconnecting: false,
            linkMessage: "Connecting...",
          ));
          break;

        case BleLinkStatus.connected:
          safeEmit(state.copyWith(
            isReconnecting: false,
            clearLinkMessage: true,
          ));
          break;

        case BleLinkStatus.disconnected:
        // Don’t force scan/stop here — your existing connection stream will do that.
          safeEmit(state.copyWith(
            isReconnecting: false,
            linkMessage: "Disconnected",
            deviceReady: false,
          ));
          break;
      }
    }, onError: (e) {
      _log("LINK_STATUS ERROR => $e");
    });
  }

  void _listenAdapter() {
    _adapterSub?.cancel();
    _adapterSub = fbp.FlutterBluePlus.adapterState.listen((s) async {
      _log("ADAPTER_STREAM => $s");

      if (s != fbp.BluetoothAdapterState.on) {
        _readyTimeoutTimer?.cancel();
        _scanRetryTimer?.cancel();
        _pruneTimer?.cancel();
        _scanKickTimer?.cancel();

        _handshakeCompleted = false;
        _handshakeInProgress = false;
        _frameBuffer.clear();

        _seen.clear();

        try {
          await repo.stopScan();
        } catch (_) {}

        safeEmit(state.copyWith(
          isScanning: false,
          devices: const [],
          deviceReady: false,
          isConnected: false,
          isConnecting: false,
          status: BluetoothConnectionStatus.disconnected,
          isDeviceError: false,
          clearConnectingDeviceId: true,

          // ✅ show bluetooth off message
          isReconnecting: false,
          linkMessage: "Bluetooth is off",
        ));
        return;
      }

      if (_scanRequested &&
          !state.isConnected &&
          !state.isConnecting &&
          !state.isScanning) {
        await _startScanFlow();
      }
    }, onError: (e) {
      _log("ADAPTER_STREAM ERROR => $e");
    });
  }

  void _listenConnection() {
    _connSub?.cancel();

    _log("_listenConnection() subscribed");
    _connSub = repo.connectionStatusStream().listen((connected) async {
      _log(
        "CONN_STREAM => connected=$connected | state(connecting=${state.isConnecting}, wasEver=$_wasEverConnected)",
      );

      if (connected) {
        _wasEverConnected = true;

        _scanRetryTimer?.cancel();
        _pruneTimer?.cancel();
        _scanKickTimer?.cancel();

        _handshakeCompleted = false;
        _handshakeInProgress = false;
        _frameBuffer.clear();

        safeEmit(state.copyWith(
          isConnected: true,
          isConnecting: false,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
          clearTextError: true,

          // ✅ clear reconnect UI
          isReconnecting: false,
          clearLinkMessage: true,
        ));

        await _checkAppReadiness();
        return;
      }

      if (state.isConnecting && !_wasEverConnected) {
        _log("IGNORED transient DISCONNECTED (during connecting)");
        return;
      }

      _readyTimeoutTimer?.cancel();
      _scanRetryTimer?.cancel();
      _pruneTimer?.cancel();
      _scanKickTimer?.cancel();

      _handshakeCompleted = false;
      _handshakeInProgress = false;
      _frameBuffer.clear();

      _seen.clear();

      safeEmit(state.copyWith(
        isConnected: false,
        isConnecting: false,
        deviceReady: false,
        status: BluetoothConnectionStatus.disconnected,
        clearConnectingDeviceId: true,
        // NOTE: reconnect banner handled by linkStatusStream if it’s reconnecting
      ));

      _scanRequested = true;

      final s = await fbp.FlutterBluePlus.adapterState.first;
      if (s == fbp.BluetoothAdapterState.on && !state.isScanning) {
        await _startScanFlow();
      }
    }, onError: (e) {
      _log("CONN_STREAM ERROR => $e");
    });
  }

  void _listenDeviceReady() {
    _readySub?.cancel();

    _log("_listenDeviceReady() subscribed");
    _readySub = repo.deviceReadyStream().listen((isGattReady) async {
      _log("READY_STREAM => $isGattReady | isConnected=${state.isConnected}");
      if (isGattReady && state.isConnected) {
        await _checkAppReadiness();
      }
    }, onError: (e) {
      _log("READY_STREAM ERROR => $e");
    });
  }

  void _listenData() {
    _dataSub?.cancel();

    _log("_listenData() subscribed");
    _dataSub = repo.receivedDataStream().listen((data) {
      final cleaned = data.trim();
      if (cleaned.isEmpty) return;

      _log("DATA_STREAM => '$cleaned'");
      onBleData(cleaned);

      safeEmit(state.copyWith(lastData: cleaned));
    }, onError: (e) {
      _log("DATA_STREAM ERROR => $e");
    });
  }

  Future<void> _startScanFlow({Duration timeout = const Duration(seconds: 15)}) async {
    if (_startingScan) return;
    if (state.isConnected || state.isConnecting) return;

    _startingScan = true;
    try {
      final s = await fbp.FlutterBluePlus.adapterState.first;
      if (s != fbp.BluetoothAdapterState.on) {
        await fbp.FlutterBluePlus.adapterState
            .firstWhere((x) => x == fbp.BluetoothAdapterState.on);
      }

      await repo.ensureScanPrerequisites();
      await Future.delayed(const Duration(milliseconds: 350));

      startScan(timeout: timeout);
    } catch (e) {
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isScanning: false,
        isConnecting: false,
      ));
    } finally {
      _startingScan = false;
    }
  }

  Future<void> _checkAppReadiness() async {
    _log("_checkAppReadiness() completed=$_handshakeCompleted inProgress=$_handshakeInProgress");

    if (!state.isConnected) return;
    if (_handshakeCompleted) return;
    if (_handshakeInProgress) return;

    _handshakeInProgress = true;
    _readyTimeoutTimer?.cancel();

    await _sendHandshake();

    _readyTimeoutTimer = Timer.periodic(_readyTimeout, (timer) async {
      if (!state.isConnected) {
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      if (_handshakeCompleted) {
        timer.cancel();
        _handshakeInProgress = false;
        return;
      }

      await _sendHandshake();
    });
  }

  Future<void> _sendHandshake() async {
    try {
      await repo.sendData("{");
      await repo.sendData("%");
    } catch (e) {
      _log("SEND ERROR => $e");
    }
  }

  void _handleReadyPacket() {
    if (_handshakeCompleted) return;

    _handshakeCompleted = true;
    _handshakeInProgress = false;
    _readyTimeoutTimer?.cancel();

    safeEmit(state.copyWith(deviceReady: true));
  }

  void _pruneAndEmit() {
    final now = DateTime.now();
    _seen.removeWhere((_, v) => now.difference(v.lastSeen) > _deviceStaleAfter);
    final list = _seen.values.map((e) => e.device).toList();

    safeEmit(state.copyWith(
      devices: list,
      isScanning: true,
    ));
  }

  bool _hasRespyrInSeen() {
    for (final v in _seen.values) {
      if (v.device.name.trim().toLowerCase().contains("respyr")) return true;
    }
    return false;
  }

  void _attachRepoScan({Duration timeout = const Duration(seconds: 15)}) {
    _scanSub?.cancel();

    _scanSub = repo.scan(timeout: timeout).listen(
          (devices) {
        final now = DateTime.now();

        for (final d in devices) {
          final name = d.name.trim().toLowerCase();
          if (!name.contains("respyr")) continue;
          _seen[d.id] = _SeenDevice(d, now);
        }

        _pruneAndEmit();
      },
      onError: (e) {
        safeEmit(state.copyWith(
          status: BluetoothConnectionStatus.textError,
          textError: e.toString(),
          isScanning: false,
          isConnecting: false,
        ));
      },
      onDone: () {
        safeEmit(state.copyWith(isScanning: false));
      },
    );
  }

  void startScan({Duration timeout = const Duration(seconds: 15)}) async{

    try {
      await repo.stopScan();
    } catch (_) {}

    if (state.isConnected || state.isConnecting) return;

    _scanSub?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _seen.clear();

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.scanning,
      isScanning: true,
      isConnecting: false,
      devices: const [],
      isDeviceError: false,
      clearTextError: true,
      clearConnectingDeviceId: true,

      // ✅ scanning hides reconnect banner
      isReconnecting: false,
      clearLinkMessage: true,
    ));

    _attachRepoScan(timeout: timeout);

    _pruneTimer = Timer.periodic(_pruneEvery, (_) {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;
      _pruneAndEmit();
    });

    _scanRetryTimer = Timer.periodic(_scanRetryEvery, (_) async {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      if (_hasRespyrInSeen()) return;

      _log("SCAN_RETRY -> no Respyr yet, restarting repo scan");

      try {
        await repo.stopScan();
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 250));

      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _attachRepoScan(timeout: timeout);
    });

    _scanKickTimer = Timer.periodic(_scanKickEvery, (_) async {
      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _log("SCAN_KICK -> restarting scan to catch device power cycle");

      try {
        await repo.stopScan();
      } catch (_) {}

      await Future.delayed(_scanKickGap);

      if (isClosed) return;
      if (!state.isScanning) return;
      if (state.isConnected || state.isConnecting) return;

      _attachRepoScan(timeout: timeout);
    });
  }

  Future<void> connectById(String id) async {
    if (state.isConnecting || state.isConnected) return;

    final s = await fbp.FlutterBluePlus.adapterState.first;
    if (s != fbp.BluetoothAdapterState.on) {
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: "Bluetooth is off",
      ));
      return;
    }

    _scanRequested = false;

    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _scanSub?.cancel();

    try {
      await repo.stopScan();
    } catch (_) {}

    _wasEverConnected = false;

    _handshakeCompleted = false;
    _handshakeInProgress = false;
    _frameBuffer.clear();

    safeEmit(state.copyWith(
      connectingDeviceId: id,
      status: BluetoothConnectionStatus.connecting,
      isConnecting: true,
      isScanning: false,
      deviceReady: false,
      isDeviceError: false,
      clearTextError: true,

      isReconnecting: false,
      linkMessage: "Connecting...",
    ));

    try {
      await repo.connectById(id);
    } catch (e) {
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isConnecting: false,
        isConnected: false,
        clearConnectingDeviceId: true,
        isReconnecting: false,
      ));
      _scanRequested = true;
      await _startScanFlow();
    }
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } catch (_) {}
  }

  void sendAbort() {
    if (state.isConnected) {
      try {
        repo.sendData("&");
      } catch (_) {}
    }
  }

  void onBleData(String cleaned) {
    if (cleaned.contains("%")) {
      _handleReadyPacket();
      cleaned = cleaned.replaceAll("%", "").trim();
      if (cleaned.isEmpty) return;
    }

    final frames = _frameBuffer.add(cleaned);
    for (final frame in frames) {
      _handleFullFrame(frame);
    }
  }

  void _handleFullFrame(String frame) {
    final f = frame.trim();

    if (f.contains("ERROR")) {
      final errorMessage = f == "{ERROR:003}" ? "LOW_BATTERY" : "DEVICE_ERROR";
      safeEmit(state.copyWith(isDeviceError: true, textError: errorMessage));
      return;
    }

    final bool isInhaleExhalePacket = _slashNum.hasMatch(f) || _curlyNum.hasMatch(f);
    if (isInhaleExhalePacket) {
      _log("✅ INHALE/EXHALE DETECTED => $f");
      if (!deviceIsExhaleOrInhaleModeCalled) {
        deviceIsExhaleOrInhaleModeCalled = true;
        safeEmit(state.copyWith(deviceIsInhaleOrExhaleMode: true));
      }
    }
  }

  @override
  Future<void> close() async {
    _readyTimeoutTimer?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();

    await _adapterSub?.cancel();
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _readySub?.cancel();
    await _scanSub?.cancel();
    await _linkSub?.cancel();

    return super.close();
  }
}

class _SeenDevice {
  final BluetoothDeviceModel device;
  DateTime lastSeen;
  _SeenDevice(this.device, this.lastSeen);
}

class _BleFrameBuffer {
  final StringBuffer _sb = StringBuffer();

  List<String> add(String chunk) {
    if (chunk.isEmpty) return const [];

    _sb.write(chunk);

    final all = _sb.toString();
    final out = <String>[];

    int searchFrom = 0;
    while (true) {
      final start = all.indexOf("{", searchFrom);
      if (start == -1) break;

      final end = all.indexOf("}", start);
      if (end == -1) break;

      out.add(all.substring(start, end + 1));
      searchFrom = end + 1;
    }

    if (out.isEmpty) {
      if (all.length > 2048) _sb.clear();
      return const [];
    }

    final lastEnd = all.lastIndexOf("}");
    final remaining = all.substring(lastEnd + 1);
    _sb.clear();
    _sb.write(remaining);

    return out;
  }

  void clear() => _sb.clear();
}