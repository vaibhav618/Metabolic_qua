import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_calibration_cubit/bluetooth_calibration_state.dart';

import '../../../data/model/breath_setting_model.dart';
import '../../../data/services/breathing_config_service.dart';

class BluetoothCalibrationCubit extends Cubit<BluetoothCalibrationState> {
  final BluetoothRepository repo;
  final AudioHelper _audioHelper;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _globalWaitTimer;        // 100s inhale-timeout timer (background)
  Timer? _uiCountdownTimer;       // what UI shows
  Timer? _deviceSyncWindowTimer;  // 3s window after '{' to wait for number

  Timer? _inhaleTimeoutTimer;

  Timer? _ackRetryTimer;
  static const Duration _ackWait = Duration(seconds: 10);

  static const int _globalMaxSeconds = 100;
  static const Duration _deviceSyncWindow = Duration(seconds: 3);

  bool _calibrationAckReceived = false;
  bool _handshakeLoopRunning = false;

  bool _disposed = false;
  bool _isRunningCalibration = false;

  int _globalRemaining = _globalMaxSeconds;

  bool _usingDeviceCountdown = false;
  int _uiRemaining = _globalMaxSeconds;

  // ✅ NEW: only accept numeric countdown inside this window
  bool _awaitingCountdownNumber = false;

  BluetoothCalibrationCubit(this.repo, this._audioHelper)
      : super(BluetoothCalibrationState.initial()) {
    init();
  }

  void _log(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print("🟪 CALIB_CUBIT | $msg");
    }
  }

  void init() {
    _log("init()");
    _connSub = repo.connectionStatusStream().listen(handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(onBluetoothDataReceived);

    if (repo.isConnected) {
      _log("repo.isConnected=true at init -> handleBluetoothConnection(true)");
      handleBluetoothConnection(true);
    }
  }

  Future<void> handleBluetoothConnection(bool connected) async {
    if (_disposed) return;

    _log("handleBluetoothConnection => connected=$connected");
    emit(state.copyWith(isBluetoothConnected: connected));

    if (connected) {
      _log("connected -> start global timer + UI timer + handshake loop");
      _startGlobalWaitTimer100s();
      _startUiCountdownTimer();
      _startHandshakeLoop();
    } else {
      _stopAll();
      if (!state.isDialogShown) showDisconnectedDialog();
    }
  }

  Future<void> onBluetoothDataReceived(String data) async {
    if (_disposed || data.isEmpty) return;

    final raw = data.trim();
    final normalized = raw.toLowerCase();

    _log("RX => '$raw'");

    // ✅ ACK from device
    if (!_calibrationAckReceived && normalized == "{") {
      _log("ACK '{' received");
      _calibrationAckReceived = true;
      _stopHandshakeLoop();

      // ✅ After '{', open 3s window to accept countdown number
      _startDeviceSyncWindow();

      // Start calibration sequence
      if (!_isRunningCalibration) {
        _isRunningCalibration = true;
        _log("start calibration sequence in 1s");
        Future.delayed(const Duration(seconds: 1), _startCalibrationSequence);
      }
      return;
    }

    // ✅ Only accept number if we are within 3s window AFTER '{'
    final numMatch = RegExp(r'^\d+$').firstMatch(normalized);
    if (numMatch != null) {
      if (!_awaitingCountdownNumber) {
        _log("NUM '$normalized' ignored (not in 3s window)");
        return;
      }

      final v = int.tryParse(normalized);
      if (v != null) {
        _log("DEVICE_COUNTDOWN_NUMBER accepted => $v");
        _awaitingCountdownNumber = false;

        _usingDeviceCountdown = true;
        _uiRemaining = v;

        emit(state.copyWith(
          remainingSeconds: _uiRemaining,
          isTimeStarted: true,
          isTimeOver: false,
          startCalibrationTime: true,
        ));

        _deviceSyncWindowTimer?.cancel();
        _deviceSyncWindowTimer = null;
      }
      return;
    }

    // ✅ Inhale navigation
    if (normalized.contains("inhale") && !state.navigateToInhaleScreen) {
      _log("INHALE received -> navigate");

      _inhaleTimeoutTimer?.cancel();
      _audioHelper.stopAudio();

      _globalWaitTimer?.cancel();
      _uiCountdownTimer?.cancel();
      _deviceSyncWindowTimer?.cancel();

      final BreathingSettings settings =
      await BreathingConfigService.fetchBreathingSettings();
      if (_disposed) return;

      emit(state.copyWith(
        navigateToInhaleScreen: true,
        waitForInhaleCmd: false,
        showPleaseWaitMessage: false,
        breathingSettings: settings,
      ));

      _cancelStreamsOnly();
      return;
    }
  }

  Future<BreathingSettings> loadBreathSettings() async {
    return BreathingConfigService.fetchBreathingSettings();
  }

  void _startGlobalWaitTimer100s() {
    _globalWaitTimer?.cancel();
    _globalRemaining = _globalMaxSeconds;

    _usingDeviceCountdown = false;
    _uiRemaining = _globalRemaining;

    emit(state.copyWith(
      isTimeStarted: true,
      remainingSeconds: _uiRemaining,
      isTimeOver: false,
    ));

    _globalWaitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || state.navigateToInhaleScreen) {
        timer.cancel();
        return;
      }

      _globalRemaining--;

      if (_globalRemaining <= 0) {
        timer.cancel();
        _log("GLOBAL timer over -> timeout");
        emit(state.copyWith(
          remainingSeconds: 0,
          isTimeOver: true,
        ));
        return;
      }
    });
  }

  void _startUiCountdownTimer() {
    _uiCountdownTimer?.cancel();

    _uiCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed || state.navigateToInhaleScreen) {
        t.cancel();
        return;
      }

      if (_usingDeviceCountdown) {
        if (_uiRemaining > 0) _uiRemaining--;
        emit(state.copyWith(
          remainingSeconds: _uiRemaining,
          isTimeStarted: true,
          isTimeOver: false,
        ));
      } else {
        _uiRemaining = _globalRemaining;
        emit(state.copyWith(
          remainingSeconds: _uiRemaining,
          isTimeStarted: true,
          isTimeOver: false,
        ));
      }

      if (_uiRemaining % 5 == 0) {
        _log("screen remaining => ${state.remainingSeconds}");
      }
    });
  }

  void _startDeviceSyncWindow() {
    _deviceSyncWindowTimer?.cancel();

    // ✅ Mark that UI can start showing time text now
    emit(state.copyWith(startCalibrationTime: true));

    // ✅ Open window only for 3 seconds
    _awaitingCountdownNumber = true;

    _deviceSyncWindowTimer = Timer(_deviceSyncWindow, () {
      if (_disposed || state.navigateToInhaleScreen) return;

      // close window
      _awaitingCountdownNumber = false;

      // If no number arrived, stay with global remaining
      if (!_usingDeviceCountdown) {
        _log("no device number in 3s -> keep global remaining on UI");
        emit(state.copyWith(remainingSeconds: _globalRemaining));
      }
    });
  }

  void _startHandshakeLoop() {
    if (_disposed) return;
    if (_handshakeLoopRunning) return;

    _handshakeLoopRunning = true;
    _calibrationAckReceived = false;

    emit(state.copyWith(
      isTimeStarted: true,
      isTimeOver: false,
      completedSteps: 0,
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
      allSignalSent: false,
      navigateToInhaleScreen: false,
      startCalibrationTime: false,
    ));

    _sendHandshakeAndWait();
  }

  Future<void> _sendHandshakeAndWait() async {
    if (_disposed || !state.isBluetoothConnected) return;
    if (_calibrationAckReceived) return;

    try {
      _log("TX handshake => '?' then '{'");
      await repo.sendData("?");
      await repo.sendData("{");
    } catch (_) {}

    _ackRetryTimer?.cancel();
    _ackRetryTimer = Timer(_ackWait, () {
      if (_disposed || !state.isBluetoothConnected) return;
      if (_calibrationAckReceived) return;
      _sendHandshakeAndWait();
    });
  }

  void _stopHandshakeLoop() {
    _log("_stopHandshakeLoop()");
    _handshakeLoopRunning = false;
    _ackRetryTimer?.cancel();
    _ackRetryTimer = null;
  }

  Future<void> _startCalibrationSequence() async {
    if (_disposed || !state.isBluetoothConnected) return;

    _log("_startCalibrationSequence()");
    emit(state.copyWith(allSignalSent: false));

    for (int i = 1; i <= 5; i++) {
      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      final wait = Duration(seconds: i == 1 ? 20 : 10);
      _log("step $i -> wait ${wait.inSeconds} seconds");
      await Future.delayed(wait);

      if (_disposed || !state.isBluetoothConnected || state.navigateToInhaleScreen) return;

      if (i == 3) _audioHelper.playActivatingSensors();
      if (i == 4) _audioHelper.playStartBreathTest();

      emit(state.copyWith(completedSteps: i));
      _log("emit completedSteps=$i");

      if (i == 1) {
        emit(state.copyWith(allSignalSent: true));
        _log("emit allSignalSent=true");
      }
    }

    emit(state.copyWith(waitForInhaleCmd: true));

    _inhaleTimeoutTimer?.cancel();
    _inhaleTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_disposed && !state.navigateToInhaleScreen) {
        emit(state.copyWith(showPleaseWaitMessage: true));
      }
    });
  }

  void sendAbort() {
    try {
      repo.sendData("&");
    } catch (_) {}
  }

  void showDisconnectedDialog() {
    if (!_disposed) emit(state.copyWith(isDialogShown: true));
  }

  void dialogDismissed() {
    if (!_disposed) emit(state.copyWith(isDialogShown: false));
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } finally {
      if (!_disposed) emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  void _cancelStreamsOnly() {
    _inhaleTimeoutTimer?.cancel();
    _stopHandshakeLoop();
    _connSub?.cancel();
    _dataSub?.cancel();
  }

  void _stopAll() {
    _audioHelper.stopAudio();

    _inhaleTimeoutTimer?.cancel();
    _stopHandshakeLoop();

    _globalWaitTimer?.cancel();
    _uiCountdownTimer?.cancel();
    _deviceSyncWindowTimer?.cancel();

    _calibrationAckReceived = false;
    _isRunningCalibration = false;

    _awaitingCountdownNumber = false;

    _usingDeviceCountdown = false;
    _globalRemaining = _globalMaxSeconds;
    _uiRemaining = _globalMaxSeconds;

    emit(state.copyWith(
      completedSteps: 0,
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
      allSignalSent: false,
      isTimeStarted: false,
      isTimeOver: false,
      remainingSeconds: _globalMaxSeconds,
      navigateToInhaleScreen: false,
      startCalibrationTime: false,
    ));
  }

  void stop() {
    _cancelStreamsOnly();
    _audioHelper.stopAudio();
    _globalWaitTimer?.cancel();
    _uiCountdownTimer?.cancel();
    _deviceSyncWindowTimer?.cancel();
    _awaitingCountdownNumber = false;
  }

  void stopScreenOperation() {
    if (_disposed) return;

    _inhaleTimeoutTimer?.cancel();
    _stopHandshakeLoop();
    _audioHelper.stopAudio();

    _globalWaitTimer?.cancel();
    _uiCountdownTimer?.cancel();
    _deviceSyncWindowTimer?.cancel();
    _awaitingCountdownNumber = false;

    emit(state.copyWith(
      waitForInhaleCmd: false,
      showPleaseWaitMessage: false,
    ));
  }

  @override
  Future<void> close() {
    _disposed = true;
    stop();
    return super.close();
  }
}
