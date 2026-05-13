import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
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

  Timer? _connectGraceTimer;
  bool _connectAttemptActive = false;
  String? _selectedDeviceId;

  static const Duration _readyTimeout = Duration(seconds: 5);

  static const Duration _scanRetryEvery = Duration(seconds: 3);
  static const Duration _deviceStaleAfter = Duration(seconds: 6);
  static const Duration _pruneEvery = Duration(seconds: 2);

  static const Duration _scanKickEvery = Duration(seconds: 7);
  static const Duration _scanKickGap = Duration(milliseconds: 200);

  static const Duration _connectGraceDuration = Duration(seconds: 4);

  bool _wasEverConnected = false;

  bool _handshakeCompleted = false;
  bool _handshakeInProgress = false;

  bool _initCalled = false;
  bool _scanRequested = false;
  bool _startingScan = false;

  bool deviceIsExhaleOrInhaleModeCalled = false;

  // 🚨 NEW: Flags for the UUID & Version check sequence
  bool _initialChecksInProgress = false;
  bool _initialChecksCompleted = false;
  String _deviceVersion = "";
  final String _requiredVersion = "v1.2.0"; // The version we want them to have

  final _frameBuffer = _BleFrameBuffer();
  final Map<String, _SeenDevice> _seen = {};

  BluetoothConnectionCubit(this.repo) : super(const BluetoothConnectionState());

  void _log(String msg) {
    if (kDebugMode) {
      print("🟦 BLE_CUBIT | $msg");
    }
  }

  void safeEmit(BluetoothConnectionState s) {
    if (!isClosed) {
      emit(s);
      _log(
        "EMIT => status=${s.status}, scan=${s.isScanning}, conn=${s.isConnected}, "
        "connecting=${s.isConnecting}, id=${s.connectingDeviceId}, ready=${s.deviceReady}",
      );
    }
  }

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  Future<void> init({String? profileId}) async {
    if (_initCalled) return;
    _initCalled = true;

    _listenAdapter();
    _listenConnection();
    _listenData();
    _listenDeviceReady();

    if (repo.isConnected) {
      _wasEverConnected = true;
      _handshakeCompleted = false;
      _handshakeInProgress = false;
      _initialChecksCompleted = false;
      _initialChecksInProgress = false;
      _frameBuffer.clear();
      deviceIsExhaleOrInhaleModeCalled = false;
      _connectAttemptActive = false;
      _connectGraceTimer?.cancel();

      safeEmit(state.copyWith(
        isConnected: true,
        isConnecting: false,
        status: BluetoothConnectionStatus.connected,
        isScanning: false,
        clearTextError: true,
        deviceIsInhaleOrExhaleMode: false,
        deviceReady: false,
        firmwareUpdateRequired: false,
      ));

      _performInitialChecks(); // 🚨 Start UUID/Version check
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
      deviceIsInhaleOrExhaleMode: false,
      firmwareUpdateRequired: false,
    ));

    _scanRequested = true;
    await _startScanFlow();
  }

  Future<void> disposeConnection() async {
    _log("disposeConnection() called");

    // cancel timers
    _readyTimeoutTimer?.cancel();
    _readyTimeoutTimer = null;

    _scanRetryTimer?.cancel();
    _scanRetryTimer = null;

    _pruneTimer?.cancel();
    _pruneTimer = null;

    _scanKickTimer?.cancel();
    _scanKickTimer = null;

    _connectGraceTimer?.cancel();
    _connectGraceTimer = null;

    // reset flags
    _connectAttemptActive = false;
    _selectedDeviceId = null;
    _wasEverConnected = false;
    _handshakeCompleted = false;
    _handshakeInProgress = false;
    _initialChecksCompleted = false;
    _initialChecksInProgress = false;
    _initCalled = false;
    _scanRequested = false;
    _startingScan = false;
    deviceIsExhaleOrInhaleModeCalled = false;

    // clear local buffers
    _frameBuffer.clear();
    _seen.clear();

    // cancel active subscriptions
    try {
      await _adapterSub?.cancel();
    } catch (_) {}
    _adapterSub = null;

    try {
      await _connSub?.cancel();
    } catch (_) {}
    _connSub = null;

    try {
      await _dataSub?.cancel();
    } catch (_) {}
    _dataSub = null;

    try {
      await _readySub?.cancel();
    } catch (_) {}
    _readySub = null;

    try {
      await _scanSub?.cancel();
    } catch (_) {}
    _scanSub = null;

    // stop BLE work from repository side
    try {
      await repo.stopScan();
    } catch (_) {}

    try {
      await repo.disconnect();
    } catch (_) {}

    // reset cubit state
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
      deviceIsInhaleOrExhaleMode: false,
      lastData: "",
      firmwareUpdateRequired: false,
    ));
  }

  void _listenAdapter() {
    _adapterSub?.cancel();
    _adapterSub = fbp.FlutterBluePlus.adapterState.listen((s) async {
      _log("ADAPTER_STREAM => $s");

      if (s == fbp.BluetoothAdapterState.off) {
        // Bluetooth turned off
        _handleBluetoothOff();
      }
    }, onError: (e) {
      _log("ADAPTER_STREAM ERROR => $e");
    });
  }

  void _handleBluetoothOff() async {
    // When Bluetooth is turned off, stop scanning and reset state
    _log("Bluetooth is off, stopping scan and resetting state.");

    _readyTimeoutTimer?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _connectGraceTimer?.cancel();

    _handshakeCompleted = false;
    _handshakeInProgress = false;
    _initialChecksCompleted = false;
    _initialChecksInProgress = false;
    deviceIsExhaleOrInhaleModeCalled = false;
    _frameBuffer.clear();
    _seen.clear();
    _connectAttemptActive = false;
    _selectedDeviceId = null;

    try {
      await repo.stopScan();
    } catch (_) {}

    // Clear devices from the list
    safeEmit(state.copyWith(
      isScanning: false,
      devices: const [],
      deviceReady: false,
      isConnected: false,
      isConnecting: false,
      status: BluetoothConnectionStatus.disconnected,
      isDeviceError: false,
      clearConnectingDeviceId: true,
      deviceIsInhaleOrExhaleMode: false,
      firmwareUpdateRequired: false,
    ));
  }

  void _listenConnection() {
    _connSub?.cancel();

    _log("_listenConnection() subscribed");

    _connSub = repo.connectionStatusStream().listen((connected) async {
      _log(
        "CONN_STREAM => connected=$connected | state(connecting=${state.isConnecting}, wasEver=$_wasEverConnected, attempt=$_connectAttemptActive)",
      );

      if (connected) {
        _wasEverConnected = true;
        _handshakeCompleted = false;
        _handshakeInProgress = false;
        _initialChecksCompleted = false;
        _initialChecksInProgress = false;
        deviceIsExhaleOrInhaleModeCalled = false;
        _frameBuffer.clear();
        _connectAttemptActive = false;

        safeEmit(state.copyWith(
          isConnected: true,
          isConnecting: false,
          status: BluetoothConnectionStatus.connected,
          isScanning: false,
          clearTextError: true,
          deviceIsInhaleOrExhaleMode: false,
          deviceReady: false,
          firmwareUpdateRequired: false,
        ));

        // 🚨 Start UUID & Version check immediately upon connection
        _performInitialChecks();
        return;
      }

      // If device gets disconnected, remove it from the list
      if (!connected && _seen.containsKey(_selectedDeviceId)) {
        _seen.remove(_selectedDeviceId); // Remove the disconnected device
      }

      safeEmit(state.copyWith(
        isConnected: false,
        isConnecting: false,
        deviceReady: false,
        status: BluetoothConnectionStatus.disconnected,
        clearConnectingDeviceId: true,
        deviceIsInhaleOrExhaleMode: false,
        firmwareUpdateRequired: false,
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
      _log(
          "READY_STREAM => isGattReady=$isGattReady | connected=${state.isConnected}");

      if (!state.isConnected) return;
      if (!isGattReady) return;

      // 🚨 Only do app readiness (sending '{') IF the version check passed
      if (_initialChecksCompleted && !state.firmwareUpdateRequired) {
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

      // 🚨 INTERCEPT RESPONSES DURING INITIAL CHECKS
      if (_initialChecksInProgress) {
        // Extract version string (e.g. v1.2.0 or 1.2.0)
        final versionMatch = RegExp(r'v?\d+\.\d+\.\d+').firstMatch(cleaned);

        if (versionMatch != null) {
          _deviceVersion = versionMatch.group(0)!;
          _processVersionResult();
          return; // Stop processing this packet
        }

        // Log other responses (like UUID) but do not process them as normal data yet
        _log("Pre-handshake data intercepted (UUID/Status): $cleaned");
        return;
      }

      onBleData(cleaned);
      safeEmit(state.copyWith(lastData: cleaned));
    }, onError: (e) {
      _log("DATA_STREAM ERROR => $e");
    });
  }

  // -------------------------------------------------------------------
  // 🚨 NEW: The UUID & Version Check Logic
  // -------------------------------------------------------------------
  Future<void> _performInitialChecks() async {
    if (!state.isConnected) return;
    if (_initialChecksInProgress || _initialChecksCompleted) return;

    _initialChecksInProgress = true;
    _log("Starting Initial Checks (! and \") before Handshake...");

    try {
      // 1. Ask for UUID
      await repo.sendData('!');

      // Delay slightly to prevent BLE buffer collisions
      await Future.delayed(const Duration(milliseconds: 300));

      // 2. Ask for Firmware Version
      await repo.sendData('"');
    } catch (e) {
      _log("Failed to send initial check commands: $e");
    }

    // Wait up to 4 seconds for the device to respond with its version
    Timer(const Duration(seconds: 4), () {
      if (_initialChecksInProgress) {
        _log("Version check timed out. Device likely does not support OTA.");
        _deviceVersion = "unknown";
        _processVersionResult();
      }
    });
  }

  void _processVersionResult() {
    _initialChecksInProgress = false;
    _initialChecksCompleted = true;

    _log(
        "Initial Checks Result: Device is on $_deviceVersion. Required: $_requiredVersion");

    if (_deviceVersion != _requiredVersion && _deviceVersion != "unknown") {
      // 🚨 HALT: Device needs an update. DO NOT send '{'.
      _log("Update Required. Halting handshake to prevent LED lock.");
      safeEmit(state.copyWith(firmwareUpdateRequired: true));
    } else {
      // 🚨 PASS: Device is up to date (or doesn't support OTA). Proceed normally.
      _log("Version OK (or unknown). Proceeding to Handshake ('{').");
      _checkAppReadiness();
    }
  }
  // -------------------------------------------------------------------

  Future<void> _startScanFlow({
    Duration timeout = const Duration(seconds: 15),
  }) async {
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
    _log(
      "_checkAppReadiness() called | completed=$_handshakeCompleted, inProgress=$_handshakeInProgress",
    );

    if (!state.isConnected) return;
    // 🚨 Extra guard: Don't handshake if we need an update
    if (state.firmwareUpdateRequired) return;
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

      if (!repo.isConnected) {
        _log("READY_TIMEOUT tick but repo not ready -> waiting");
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

        int added = 0;
        for (final d in devices) {
          final name = d.name.trim().toLowerCase();
          if (!name.contains("respyr")) continue;
          _seen[d.id] = _SeenDevice(d, now);
          added++;
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

  void startScan({Duration timeout = const Duration(seconds: 15)}) {
    if (state.isConnected || state.isConnecting) return;

    _scanSub?.cancel();
    _scanRetryTimer?.cancel();
    _pruneTimer?.cancel();
    _scanKickTimer?.cancel();
    _connectGraceTimer?.cancel();
    _seen.clear();

    safeEmit(state.copyWith(
      status: BluetoothConnectionStatus.scanning,
      isScanning: true,
      isConnecting: false,
      devices: const [],
      isDeviceError: false,
      clearTextError: true,
      clearConnectingDeviceId: true,
      deviceReady: false,
      deviceIsInhaleOrExhaleMode: false,
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

  // Method to clear/abort a queued connection
  void cancelConnect() {
    if (_connectAttemptActive) {
      // Abort or cancel any in-progress connection
      _log("Canceling queued connection attempt.");
      _connectAttemptActive = false; // Reset the flag
      // Optionally, trigger cleanup like stopping the scan
      repo.stopScan();
      emit(state.copyWith(
        isConnecting: false,
        status: BluetoothConnectionStatus.disconnected,
        deviceReady: false,
      ));
    }
  }

  Future<void> connectById(String id, {String? profileId}) async {
    if (state.isConnecting || state.isConnected) return;

    _selectedDeviceId = id;
    _connectAttemptActive = true;
    _connectGraceTimer?.cancel();

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
    _connectGraceTimer?.cancel();

    try {
      await repo.stopScan();
    } catch (_) {}

    _wasEverConnected = false;

    _handshakeCompleted = false;
    _handshakeInProgress = false;
    _initialChecksCompleted = false;
    _initialChecksInProgress = false;
    deviceIsExhaleOrInhaleModeCalled = false;
    _frameBuffer.clear();

    safeEmit(state.copyWith(
      connectingDeviceId: id,
      status: BluetoothConnectionStatus.connecting,
      isConnecting: true,
      isScanning: false,
      deviceReady: false,
      isDeviceError: false,
      clearTextError: true,
      firmwareUpdateRequired: false,
    ));

    try {
      await repo.connectById(id);
    } catch (e) {
      _connectAttemptActive = false;
      safeEmit(state.copyWith(
        status: BluetoothConnectionStatus.textError,
        textError: e.toString(),
        isConnecting: false,
        isConnected: false,
        clearConnectingDeviceId: true,
      ));
      _scanRequested = true;
      await _startScanFlow();
    }
  }

  Future<void> disconnect() async {
    _connectAttemptActive = false;
    _connectGraceTimer?.cancel();
    _selectedDeviceId = null;

    try {
      await repo.disconnect();
    } catch (e) {}
  }

  void sendAbort() {
    if (state.isConnected) {
      try {
        repo.sendData("&");
      } catch (e) {}
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

    final bool isInhaleExhalePacket =
        _slashNum.hasMatch(f) || _curlyNum.hasMatch(f);

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
    _connectGraceTimer?.cancel();

    await _adapterSub?.cancel();
    await _connSub?.cancel();
    await _dataSub?.cancel();
    await _readySub?.cancel();
    await _scanSub?.cancel();

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
