import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../common/widgets/threshold.dart';
import '../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'practice_test_exhale_state.dart';

class PracticeTestExhaleCubit extends Cubit<PracticeTestExhaleState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (!kDebug) return;
    debugPrint("[PRACTICE_EXHALE] $msg");
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _finishTimer;
  Timer? _secondTimer;
  Timer? _startRetryTimer;
  DateTime? _startSentAt;

  // 🚨 COMPATIBILITY LOGIC: Active Polling Variables
  Timer? _compatibilityTimer;
  int _compatibilityTicks = 0;

  bool _disposed = false;
  bool _startSent = false;
  bool _testStarted = false;
  bool _cancelled = false;
  bool _flowStopped = false;

  // 🚨 ACCUMULATOR & SMOOTHING VARS
  String _incomingBuffer = "";
  double _lastEmittedProgress = -1.0;
  double _smoothedProgress = 0.0;
  bool _exhaleDetected = false;

  bool _batteryDiedDuringTest = false;

  // 🚨 UNANCHORED REGEX
  final RegExp _slashNum = RegExp(r'/\s*(\d+(?:\.\d+)?)\s*/');
  final RegExp _curlyNum = RegExp(r'\{\s*(\d+(?:\.\d+)?)\s*\}');

  bool _baseCaptured = false;
  double _base = 0;

  bool _armed = false;
  static const double _armAt = 10.0;

  double get _minBand => breathingSettings.exhale.minBand.toDouble();
  double get _maxBand => breathingSettings.exhale.maxBand.toDouble();

  Duration get _exhaleNeed =>
      Duration(milliseconds: breathingSettings.exhale.timeMs);

  Duration get _exhaleAccept {
    final need = _exhaleNeed;
    if (need <= const Duration(milliseconds: 500)) return need;
    return need - const Duration(milliseconds: 500);
  }

  static const Duration _failOutOfBand = Duration(seconds: 2);

  bool _everReachedBand = false;

  Timer? _exhaleNeedTicker;
  Duration _exhaleNeedAccumulated = Duration.zero;
  DateTime? _exhaleNeedLastTickAt;

  Timer? _outOfBandTimer;

  static const double _dropToZeroThreshold = 1.0;
  bool _dropFailTriggered = false;

  int _packetCount = 0;

  bool _waitingExhaleAck = false;
  bool _deviceReadyForExhale = false;
  Timer? _exhaleAckRetryTimer;
  Timer? _exhaleAckTimeoutTimer;

  bool _waitingPercentAck = false;
  Timer? _percentRetryTimer;
  Timer? _percentTimeoutTimer;

  static const Duration _retryEvery = Duration(milliseconds: 500);
  static const Duration _timeout = Duration(seconds: 3);

  PracticeTestExhaleCubit(this.repo, this.breathingSettings)
      : super(const PracticeTestExhaleState()) {
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        _startExhaleHandshake();
      }
    });
  }

  bool get _canSaveAbortTime =>
      _testStarted ||
      state.startCounterStarted ||
      state.startCounterFinished ||
      state.exhaleStarted ||
      _waitingExhaleAck ||
      _waitingPercentAck;

  // 🚨 COMPATIBILITY LOGIC: Cleanup helper
  void _cancelCompatibilityTimer() {
    _compatibilityTimer?.cancel();
    _compatibilityTimer = null;
    _compatibilityTicks = 0;
  }

  void _listen() {
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (_disposed) return;

      emit(state.copyWith(isConnected: connected, error: null));

      if (!connected) {
        final flowRunning = _testStarted ||
            state.startCounterStarted ||
            state.startCounterFinished ||
            state.exhaleStarted ||
            _waitingExhaleAck ||
            _waitingPercentAck;

        if (flowRunning && !state.exhaleFailed && !state.exhaleFinished) {
          if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();
          _finishDisconnect(
              "Device disconnected. Please reconnect and try again.");
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected || data.isEmpty) return;

      // 🚨 ACCUMULATOR
      _incomingBuffer += data;

      if (_incomingBuffer.contains("ERROR") &&
          _incomingBuffer.contains("003")) {
        _batteryDiedDuringTest = true;
        _incomingBuffer =
            _incomingBuffer.replaceAll(RegExp(r'ERROR\s*003'), '');
      }

      // =======================================================================
      // 🚨 1. FIRMWARE FINGERPRINT CHECK (Ready Handshake)
      // =======================================================================
      // We ONLY accept it as READY if the device explicitly replies with "blownow"
      if (!_deviceReadyForExhale) {
        final lower = _incomingBuffer.toLowerCase();
        if (lower.contains("blownow")) {
          d("Device is READY ('blownow' received). Firmare is compatible. Starting 5-second counter.");
          _deviceReadyForExhale = true;
          _waitingExhaleAck = false;
          _waitingPercentAck = false;
          _stopExhaleAckTimers();
          _stopPercentTimers();
          startCounter(from: 5);
        }
      }

      // 2. Percent ACK Check
      if (_waitingPercentAck && _incomingBuffer.contains("%")) {
        _waitingPercentAck = false;
        _stopPercentTimers();
        _resetForFreshStart();
        _startExhaleHandshake();
        _incomingBuffer = "";
        return;
      }

      if (!_testStarted) return;
      if (state.exhaleFailed || state.exhaleFinished) return;

      // 3. Process Numeric Packets in Buffer
      while (true) {
        if (!_baseCaptured) {
          final m = _slashNum.firstMatch(_incomingBuffer);
          if (m != null) {
            _cancelCompatibilityTimer(); // 🚨 FLAG OFF
            _base = double.parse(m.group(1)!);
            _baseCaptured = true;
            _startRetryTimer?.cancel();
            emit(state.copyWith(
                baseValueReceived: true, blowExhaleBaseValue: _base));
            _incomingBuffer = _incomingBuffer.substring(m.end);
            continue;
          }
        }

        final m = _curlyNum.firstMatch(_incomingBuffer);
        if (m != null) {
          _cancelCompatibilityTimer(); // 🚨 FLAG OFF
          final exhaleRaw = double.parse(m.group(1)!);
          _processExhalePacket(exhaleRaw);
          _incomingBuffer = _incomingBuffer.substring(m.end);
          continue;
        }

        break;
      }
    });
  }

  void _processExhalePacket(double exhaleValue) {
    if (state.exhaleFailed || state.exhaleFinished) return;

    // 🚨 WIDENED SANITY CHECK
    if (exhaleValue < 700 || exhaleValue > 1150) return;

    _packetCount++;
    if (_packetCount <= 8 || _packetCount % 25 == 0) {
      d("pkt=$_packetCount raw=$exhaleValue base=$_base detected=$_exhaleDetected");
    }

    // 🚨 NOISE GATE & DETECTION
    if (!_exhaleDetected && exhaleValue > _base + 0.5) {
      _exhaleDetected = true;
      d("Exhale detected: $exhaleValue > $_base");
    }

    if (exhaleValue < (_base - 1.5)) {
      unawaited(_setCancelOrDisconnectFlag());
      _finishFail("Oops! You inhaled instead of exhaling.");
      return;
    }

    if (_exhaleDetected && exhaleValue <= _base + 0.5) {
      _finishFail("Exhale failed: you stopped exhaling.");
      return;
    }

    double rawProgress = 0;
    if (exhaleValue > _base) {
      rawProgress = Thresholds.calculateBlowPercentage1(
        _base,
        exhaleValue,
        breathingSettings.exhale.threshold.toDouble(),
      );
    }

    if (!_exhaleDetected) rawProgress = 0.0;

    // 🚨 FAST SYMMETRIC SMOOTHING (Low-Pass Filter)
    const double alpha = 0.80;
    if (_lastEmittedProgress < 0) {
      _smoothedProgress = rawProgress;
    } else {
      _smoothedProgress =
          (rawProgress * alpha) + (_smoothedProgress * (1.0 - alpha));
    }
    _lastEmittedProgress = _smoothedProgress;

    final exhaleProgress = _smoothedProgress > 0 ? _smoothedProgress : 0.0;
    final startedNow = exhaleProgress >= _armAt;

    emit(state.copyWith(
      progressSigned: exhaleValue - _base,
      progress: startedNow ? exhaleProgress : 0,
      exhaleStarted: startedNow ? true : state.exhaleStarted,
      exhaleFinished: state.exhaleFinished,
    ));

    if (!_armed && startedNow) _armed = true;

    if (_armed &&
        !_dropFailTriggered &&
        exhaleProgress <= _dropToZeroThreshold) {
      _dropFailTriggered = true;
      _finishFail("Exhale dropped to 0");
      return;
    }

    if (_armed && !state.exhaleFinished) {
      _applyBandRules(exhaleProgress);
    }
  }

  void _startExhaleHandshake() {
    if (_disposed || _cancelled || _flowStopped) return;
    if (!repo.isConnected) return;
    if (_waitingExhaleAck || _deviceReadyForExhale) return;

    _waitingExhaleAck = true;

    void sendPrimeCmd() {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      try {
        d("Sending Exhale Prime Command (^)");
        repo.sendData("^");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    sendPrimeCmd();

    _exhaleAckRetryTimer?.cancel();
    _exhaleAckRetryTimer = Timer.periodic(_retryEvery, (_) {
      if (!_waitingExhaleAck || _deviceReadyForExhale) return;
      sendPrimeCmd();
    });

    // 🚨 TIMEOUT LOGIC: If "blownow" never arrives, it's incompatible. Skip immediately.
    _exhaleAckTimeoutTimer?.cancel();
    _exhaleAckTimeoutTimer = Timer(_timeout, () {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!_waitingExhaleAck || _deviceReadyForExhale) return;

      _stopExhaleAckTimers();
      _waitingExhaleAck = false;
      d("Handshake timeout: Device did not reply with 'blownow'. Showing skip.");
      _finishFail(
          "Device is not responding to practice mode. It may be incompatible.",
          showSkip: true);
    });
  }

  void restartAfterFailWithPercent() {
    if (_disposed || _cancelled) return;
    if (!repo.isConnected) {
      emit(state.copyWith(error: "Device not connected"));
      return;
    }

    _flowStopped = false;
    _testStarted = false;
    _cancelCompatibilityTimer();

    emit(state.copyWith(
      exhaleFailed: false,
      exhaleFinished: false,
      exhaleSuccess: false,
      exhaleFailReason: "",
      startCounterStarted: false,
      startCounterFinished: false,
      startCounter: 0,
      startCounterMillis: 0,
      startCounterTotalMillis: 0,
      startCounterEndsAtEpochMs: 0,
      progress: 0,
      progressSigned: 0,
      inBandSeconds: 0,
      exhaleNeedRunning: false,
      exhaleNeedStartsAtEpochMs: 0,
      exhaleNeedEndsAtEpochMs: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      error: null,
      navigateBack: false,
      exhaleStarted: false,
      showSkipButton: false, // 🚨 Reset compatibility flag
    ));

    _sendPercentAndWaitAck();
  }

  void _sendPercentAndWaitAck() {
    if (_waitingPercentAck) return;

    _waitingPercentAck = true;

    void sendResetSequence() async {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      try {
        repo.sendData("/");
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_disposed && repo.isConnected) repo.sendData("%");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    sendResetSequence();

    _percentRetryTimer?.cancel();
    _percentRetryTimer = Timer.periodic(_retryEvery, (_) {
      if (!_waitingPercentAck) return;
      sendResetSequence();
    });

    _percentTimeoutTimer?.cancel();
    _percentTimeoutTimer = Timer(_timeout, () {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!_waitingPercentAck) return;

      _waitingPercentAck = false;
      _stopPercentTimers();
      _finishFail("No response for % from device", showSkip: true);
    });
  }

  void startCounter({int from = 5}) {
    if (_disposed) return;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _cancelCompatibilityTimer();

    _startSent = false;
    _testStarted = false;

    _baseCaptured = false;
    _base = 0;

    _cancelled = false;
    _flowStopped = false;

    _resetAllTracking();

    final totalMs = from * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    final endsAt = now + totalMs;

    emit(state.copyWith(
      navigateBack: false,
      startCounter: from,
      startCounterMillis: totalMs,
      startCounterTotalMillis: totalMs,
      startCounterEndsAtEpochMs: endsAt,
      startCounterStarted: true,
      startCounterFinished: false,
      exhaleStarted: false,
      exhaleFinished: false,
      exhaleSuccess: false,
      exhaleFailed: false,
      exhaleFailReason: "",
      inBandSeconds: 0,
      exhaleNeedRunning: false,
      exhaleNeedTotalMillis: _exhaleNeed.inMilliseconds,
      exhaleNeedStartsAtEpochMs: 0,
      exhaleNeedEndsAtEpochMs: 0,
      progress: 0,
      progressSigned: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      error: null,
      showSkipButton: false, // 🚨 Reset compatibility flag
    ));

    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || _cancelled) return;
      final remainingMs = endsAt - DateTime.now().millisecondsSinceEpoch;
      final remainingSec = (remainingMs / 1000).ceil().clamp(0, from);
      emit(state.copyWith(startCounter: remainingSec));
    });

    _finishTimer = Timer(Duration(milliseconds: totalMs), () {
      if (_disposed || _cancelled) return;

      _secondTimer?.cancel();
      _secondTimer = null;

      emit(state.copyWith(
        startCounter: 0,
        startCounterMillis: 0,
        startCounterStarted: false,
        startCounterFinished: true,
      ));

      _sendStart();
    });
  }

  void _sendStart() {
    if (_disposed || _cancelled || _flowStopped || _startSent) return;
    if (!repo.isConnected) return;
    if (!_deviceReadyForExhale) return;

    _startSent = true;
    _testStarted = true;
    _startSentAt = DateTime.now();

    void sendStartCmd() {
      if (!repo.isConnected || _disposed || _cancelled || _baseCaptured) return;
      d("Sending Stream Start Command (1)...");
      try {
        repo.sendData("1");
      } catch (_) {}
    }

    sendStartCmd();

    // 🚨 COMPATIBILITY LOGIC: Active Polling Timer for '1'
    _cancelCompatibilityTimer();
    _compatibilityTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _compatibilityTicks++;

      if (_compatibilityTicks >= 4) {
        // 8 Seconds total
        _cancelCompatibilityTimer();
        d("Compatibility timeout: Device not streaming data. Showing skip button.");
        _finishFail("Device is not streaming data. It may be incompatible.",
            showSkip: true);
      } else {
        d("Compatibility ping $_compatibilityTicks: Resending '1'");
        sendStartCmd();
      }
    });
  }

  void _applyBandRules(double progressAbs) {
    if (_disposed || _cancelled || _flowStopped || state.exhaleFinished) return;

    final inBand = (progressAbs >= _minBand && progressAbs <= _maxBand);

    if (inBand && !_everReachedBand) {
      _everReachedBand = true;

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(
        exhaleNeedRunning: true,
        exhaleNeedTotalMillis: _exhaleNeed.inMilliseconds,
        exhaleNeedStartsAtEpochMs: nowMs,
        exhaleNeedEndsAtEpochMs: 0,
      ));

      _startExhaleNeedTickerIfNeeded();
    }

    if (!_everReachedBand) return;

    if (inBand) {
      _cancelOutOfBandFailTimer();
    } else {
      _startOutOfBandFailTimerIfNeeded("Out of range for 2 seconds");
    }
  }

  void _startExhaleNeedTickerIfNeeded() {
    if (_exhaleNeedTicker != null) return;

    _exhaleNeedLastTickAt = DateTime.now();

    if (!state.exhaleNeedRunning) {
      emit(state.copyWith(exhaleNeedRunning: true));
    }

    _exhaleNeedTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped || state.exhaleFinished)
        return;

      final now = DateTime.now();
      final last = _exhaleNeedLastTickAt ?? now;
      _exhaleNeedLastTickAt = now;

      _exhaleNeedAccumulated += now.difference(last);

      final seconds = (_exhaleNeedAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _exhaleNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_exhaleNeedAccumulated >= _exhaleAccept) {
        _finishExhaleSuccess();
      }
    });
  }

  void _pauseExhaleNeedTicker({required bool setRunningFalse}) {
    _exhaleNeedTicker?.cancel();
    _exhaleNeedTicker = null;
    _exhaleNeedLastTickAt = null;

    if (setRunningFalse && state.exhaleNeedRunning) {
      emit(state.copyWith(exhaleNeedRunning: false));
    }
  }

  void _startOutOfBandFailTimerIfNeeded(String reason) {
    if (_outOfBandTimer != null) return;
    _outOfBandTimer = Timer(_failOutOfBand, () {
      if (_disposed || _cancelled || _flowStopped || state.exhaleFinished)
        return;
      _finishFail(reason);
    });
  }

  void _cancelOutOfBandFailTimer() {
    _outOfBandTimer?.cancel();
    _outOfBandTimer = null;
  }

  void _finishExhaleSuccess() {
    if (_disposed || _cancelled || _flowStopped || state.exhaleFinished) return;

    _pauseExhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelCompatibilityTimer();

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      exhaleFinished: true,
      exhaleSuccess: true,
      exhaleFailed: false,
      exhaleFailReason: _batteryDiedDuringTest ? "POST_TEST_LOW_BATTERY" : "",
      exhaleNeedRunning: false,
      exhaleNeedTotalMillis: _exhaleNeed.inMilliseconds,
      exhaleNeedEndsAtEpochMs: nowMs,
    ));

    if (repo.isConnected) {
      repo.sendData("2");
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_disposed && repo.isConnected) repo.sendData("/");
      });
    }
  }

  void _finishFail(String reason, {bool showSkip = false}) {
    if (_disposed || _cancelled || state.exhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopExhaleAckTimers();
    _cancelCompatibilityTimer();

    _pauseExhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _stopPercentTimers();
    _waitingPercentAck = false;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      exhaleFinished: true,
      exhaleSuccess: false,
      exhaleFailed: true,
      exhaleFailReason: reason,
      showSkipButton: showSkip,
      exhaleNeedRunning: false,
      exhaleNeedTotalMillis: _exhaleNeed.inMilliseconds,
      exhaleNeedEndsAtEpochMs:
          (state.exhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
    ));

    if (repo.isConnected) {
      repo.sendData("2");
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_disposed && repo.isConnected) repo.sendData("/");
      });
    }
  }

  void _finishDisconnect(String reason) {
    if (_disposed || _cancelled || state.exhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopExhaleAckTimers();
    _stopPercentTimers();
    _cancelCompatibilityTimer();
    _waitingPercentAck = false;

    _pauseExhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    emit(state.copyWith(
      exhaleFinished: true,
      exhaleSuccess: false,
      exhaleFailed: true,
      exhaleFailReason: reason,
    ));

    if (repo.isConnected) repo.sendData("&");
  }

  void _resetAllTracking() {
    _armed = false;
    _everReachedBand = false;
    _exhaleNeedAccumulated = Duration.zero;
    _exhaleNeedLastTickAt = null;
    _dropFailTriggered = false;
    _batteryDiedDuringTest = false;
    _exhaleDetected = false;
    _lastEmittedProgress = -1.0;
    _incomingBuffer = ""; // Reset accumulator
    _startRetryTimer?.cancel();
    _pauseExhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _cancelCompatibilityTimer();
    _packetCount = 0;
  }

  void _resetForFreshStart() {
    _startSent = false;
    _testStarted = false;
    _flowStopped = false;

    _deviceReadyForExhale = false;
    _waitingExhaleAck = false;
    _stopExhaleAckTimers();

    _baseCaptured = false;
    _base = 0;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _resetAllTracking();
  }

  void _stopExhaleAckTimers() {
    _exhaleAckRetryTimer?.cancel();
    _exhaleAckTimeoutTimer?.cancel();
    _exhaleAckRetryTimer = null;
    _exhaleAckTimeoutTimer = null;
  }

  void _stopPercentTimers() {
    _percentRetryTimer?.cancel();
    _percentTimeoutTimer?.cancel();
    _percentRetryTimer = null;
    _percentTimeoutTimer = null;
  }

  Future<void> cancelTest() async {
    if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();
    if (_disposed || _cancelled) return;

    _cancelled = true;
    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopExhaleAckTimers();
    _stopPercentTimers();
    _cancelCompatibilityTimer();
    _waitingPercentAck = false;

    _pauseExhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    if (repo.isConnected && !state.exhaleFailed) {
      try {
        repo.sendData("2");
        await Future.delayed(const Duration(milliseconds: 300));
        repo.sendData("/");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    if (!state.startCounterFinished) {
      try {
        repo.sendData("&");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    emit(state.copyWith(
      exhaleFinished: true,
      exhaleSuccess: false,
      exhaleFailed: true,
      exhaleFailReason: "Aborted by user.",
      navigateBack: true,
    ));
  }

  Future<void> sendAbort() async {
    if (_disposed) return;
    if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();

    if (repo.isConnected) {
      try {
        repo.sendData("&");
      } catch (_) {}
    }
  }

  Future<void> _setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );
  }

  void stopFlow() {
    d("Forcing Exhale Flow to Stop");
    _flowStopped = true;
    _testStarted = false;
    _dataSub?.cancel();
    _connSub?.cancel();
    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _cancelCompatibilityTimer();
  }

  @override
  Future<void> close() {
    d("Closing Exhale Cubit - Cleaning up");
    _disposed = true;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();

    _stopExhaleAckTimers();
    _stopPercentTimers();
    _cancelCompatibilityTimer();

    _pauseExhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
