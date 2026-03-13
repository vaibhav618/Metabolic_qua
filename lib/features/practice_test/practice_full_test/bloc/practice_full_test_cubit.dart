import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../common/widgets/threshold.dart';
import '../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'practice_full_test_state.dart';

class PracticeFullTestCubit extends Cubit<PracticeFullTestState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (!kDebug) return;
    debugPrint("[PRACTICE_FULL_TEST] $msg");
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _secondTimer;

  // 🚨 COMPATIBILITY LOGIC: Active Polling Variables
  Timer? _compatibilityTimer;
  int _compatibilityTicks = 0;

  bool _disposed = false;
  bool _flowStopped = false;
  bool _testStarted = false;

  // 🚨 NEW: ACCUMULATOR & SMOOTHING VARS
  String _incomingBuffer = "";
  double _lastEmittedProgress = -1.0;
  double _smoothedProgress = 0.0;
  bool _breathDetectedInPhase = false;

  bool _batteryDiedDuringTest = false;

  // 🚨 UPDATED REGEX: Unanchored for buffer parsing
  final RegExp _slashNum = RegExp(r'/\s*(\d+(?:\.\d+)?)\s*/');
  final RegExp _curlyNum = RegExp(r'\{\s*(\d+(?:\.\d+)?)\s*\}');

  bool _baseCaptured = false;
  double _base = 0;

  bool _armed = false;
  static const double _armAt = 10.0;
  static const double _dropToZeroThreshold = 1.0;

  static const Duration _failOutOfBand = Duration(seconds: 2);

  bool _dropFailTriggered = false;

  bool _everReachedBand = false;
  Timer? _needTicker;
  Duration _needAccumulated = Duration.zero;
  DateTime? _needLastTickAt;
  Timer? _outOfBandTimer;

  bool _waitingHandshakeAck = false;
  bool _waitingPercentAck = false;

  Timer? _retryTimer;
  Timer? _timeoutTimer;
  static const Duration _retryEvery = Duration(milliseconds: 500);
  static const Duration _timeout = Duration(seconds: 4);

  Timer? _postExitTimer;
  bool _exitSent = false;

  DateTime? _holdStartAt;
  static const Duration _holdStartCheckingAfter = Duration(seconds: 1);

  PracticeFullTestCubit(this.repo, this.breathingSettings)
      : super(const PracticeFullTestState()) {
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        _startFullTestHandshake();
      }
    });
  }

  double get _minBand => state.phase == FullTestPhase.exhaling
      ? breathingSettings.exhale.minBand.toDouble()
      : breathingSettings.inhale.minBand.toDouble();

  double get _maxBand => state.phase == FullTestPhase.exhaling
      ? breathingSettings.exhale.maxBand.toDouble()
      : breathingSettings.inhale.maxBand.toDouble();

  Duration get _needTarget => state.phase == FullTestPhase.exhaling
      ? Duration(milliseconds: breathingSettings.exhale.timeMs)
      : Duration(milliseconds: breathingSettings.inhale.timeMs);

  Duration get _acceptTarget {
    final need = _needTarget;
    if (need <= const Duration(milliseconds: 500)) return need;
    return need - const Duration(milliseconds: 500);
  }

  // 🚨 RE-ADDED MISSING GETTER
  bool get _canSaveAbortTime =>
      _testStarted ||
      state.phase == FullTestPhase.inhaleCountdown ||
      state.phase == FullTestPhase.exhaleCountdown ||
      _waitingHandshakeAck ||
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
      emit(state.copyWith(isConnected: connected));
      if (!connected &&
          !state.isFailed &&
          state.phase != FullTestPhase.success) {
        _finishFail("Device disconnected. Please reconnect and try again.");
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _flowStopped) return;
      if (!repo.isConnected || data.isEmpty) return;

      // 🚨 ACCUMULATOR
      _incomingBuffer += data;

      if (_incomingBuffer.contains("ERROR") &&
          _incomingBuffer.contains("003")) {
        _batteryDiedDuringTest = true;
        _incomingBuffer =
            _incomingBuffer.replaceAll(RegExp(r'ERROR\s*003'), '');
      }

      final lower = _incomingBuffer.toLowerCase();

      // 1) RETRY CHECK (%)
      if (_waitingPercentAck && _incomingBuffer.contains("%")) {
        d("Reset confirmed. Restarting flow with (|).");
        _waitingPercentAck = false;
        _stopTimers();
        _startFullTestHandshake();
        _incomingBuffer = "";
        return;
      }

      // 2) HANDSHAKE (|)
      if (_waitingHandshakeAck && state.phase == FullTestPhase.initial) {
        if (lower.contains("inhale") ||
            _slashNum.hasMatch(_incomingBuffer) ||
            _curlyNum.hasMatch(_incomingBuffer)) {
          d("Handshake OK. Sending '1' to start inhale stream.");
          _cancelCompatibilityTimer();
          _waitingHandshakeAck = false;
          _stopTimers();
          if (repo.isConnected) repo.sendData("1");
          startCounter(
            countdownPhase: FullTestPhase.inhaleCountdown,
            nextPhase: FullTestPhase.inhaling,
            from: 5,
            resetBase: true,
          );
        }
      }

      // 3) TRANSITION
      if (state.phase == FullTestPhase.transitioning) {
        if (lower.contains("blow") ||
            lower.contains("exhale") ||
            _incomingBuffer.contains("3") ||
            _curlyNum.hasMatch(_incomingBuffer) ||
            _slashNum.hasMatch(_incomingBuffer)) {
          d("Device Ready for Exhale. Sending '3' to start stream.");
          if (repo.isConnected) repo.sendData("3");
          startCounter(
            countdownPhase: FullTestPhase.exhaleCountdown,
            nextPhase: FullTestPhase.exhaling,
            from: 8,
            resetBase: false,
          );
        }
      }

      if (!_testStarted && state.phase != FullTestPhase.exhaleCountdown) return;

      // 🚨 PROCESS ACCUMULATED DATA PACKETS
      while (true) {
        // Base Capture
        if (!_baseCaptured) {
          final m = _slashNum.firstMatch(_incomingBuffer);
          if (m != null) {
            _cancelCompatibilityTimer(); // 🚨 COMPATIBILITY LOGIC: Data received!
            final val = double.tryParse(m.group(1)!);
            if (val != null && val >= 700 && val <= 1150) {
              _base = val;
              _baseCaptured = true;
              d("Captured Base: $_base for ${state.phase.name}");
            }
            _incomingBuffer = _incomingBuffer.substring(m.end);
            continue;
          }
        }

        // Pressure Packets
        final m = _curlyNum.firstMatch(_incomingBuffer);
        if (m != null) {
          _cancelCompatibilityTimer(); // 🚨 COMPATIBILITY LOGIC: Data received!
          final val = double.tryParse(m.group(1)!);
          if (val != null && val >= 700 && val <= 1150) {
            _handlePressureData(val);
          }
          _incomingBuffer = _incomingBuffer.substring(m.end);
          continue;
        }

        break;
      }
    });
  }

  void _handlePressureData(double value) {
    if (state.phase == FullTestPhase.inhaling) {
      _processInhaleData(value);
    } else if (state.phase == FullTestPhase.exhaling) {
      _processExhaleData(value);
    } else if (state.phase == FullTestPhase.exhaleCountdown) {
      _processHoldData(value);
    }
  }

  void _processHoldData(double value) {
    final holdStart = _holdStartAt;
    if (holdStart == null) return;

    final elapsedHold = DateTime.now().difference(holdStart);
    if (elapsedHold < const Duration(milliseconds: 1500)) return;

    if (value > (_base + 2.5)) {
      _finishFail("Exhale detected during hold");
      return;
    }

    if (value < (_base - 2.5)) {
      _finishFail("Inhale detected during hold");
      return;
    }
  }

  void _processInhaleData(double value) {
    if (value > _base + 1.5) {
      _finishFail("Exhale detected instead of inhale");
      return;
    }

    final signed = Thresholds.calculateInhalePercentage(
      _base,
      value,
      breathingSettings.inhale.threshold.toDouble(),
    );

    double rawProgress = signed < 0 ? (-signed) : 0.0;

    // FAST SYMMETRIC SMOOTHING
    const double alpha = 0.80;
    if (_lastEmittedProgress < 0) {
      _smoothedProgress = rawProgress;
    } else {
      _smoothedProgress =
          (rawProgress * alpha) + (_smoothedProgress * (1.0 - alpha));
    }
    _lastEmittedProgress = _smoothedProgress;

    final inhaleProgress = _smoothedProgress >= 0 ? _smoothedProgress : 0.0;
    final startedNow = inhaleProgress >= _armAt;

    emit(state.copyWith(
      progressSigned: signed,
      progress: startedNow ? inhaleProgress : 0,
    ));

    if (!_armed && startedNow) _armed = true;

    if (_armed &&
        !_dropFailTriggered &&
        inhaleProgress <= _dropToZeroThreshold) {
      _dropFailTriggered = true;
      _finishFail("Inhale dropped to 0");
      return;
    }

    if (_armed) {
      _applyBandRules(inhaleProgress);
    }
  }

  void _processExhaleData(double value) {
    // Noise Gate Detection
    if (!_breathDetectedInPhase && value > _base + 0.5) {
      _breathDetectedInPhase = true;
    }

    if (value < _base - 1.5) {
      _finishFail("Inhale detected instead of exhale");
      return;
    }

    if (_breathDetectedInPhase && value <= _base + 0.5) {
      _finishFail("Exhale failed: you stopped exhaling.");
      return;
    }

    final signed = Thresholds.calculateBlowPercentage1(
      _base,
      value,
      breathingSettings.exhale.threshold.toDouble(),
    );

    double rawProgress = signed > 0 ? signed : 0.0;
    if (!_breathDetectedInPhase) rawProgress = 0.0;

    // FAST SYMMETRIC SMOOTHING
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
      progressSigned: signed,
      progress: startedNow ? exhaleProgress : 0,
    ));

    if (!_armed && startedNow) _armed = true;

    if (_armed &&
        !_dropFailTriggered &&
        exhaleProgress <= _dropToZeroThreshold) {
      _dropFailTriggered = true;
      _finishFail("Exhale dropped to 0");
      return;
    }

    if (_armed) {
      _applyBandRules(exhaleProgress);
    }
  }

  void _startFullTestHandshake() {
    if (_disposed || _flowStopped) return;
    if (!repo.isConnected) return;

    _waitingHandshakeAck = true;

    d("Cleaning device state before handshake (%)");
    repo.sendData("%");

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_disposed || !_waitingHandshakeAck) return;

      void sendCommand() {
        if (_disposed || _flowStopped || !repo.isConnected) return;
        d("Sending Full Test Prime (|)");
        repo.sendData("|");
      }

      sendCommand();

      _retryTimer?.cancel();
      _retryTimer = Timer.periodic(_retryEvery, (_) {
        if (!_waitingHandshakeAck || _disposed) return;
        sendCommand();
      });
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeout, () {
      if (_disposed || !_waitingHandshakeAck) return;
      _stopTimers();
      _waitingHandshakeAck = false;
      // 🚨 COMPATIBILITY FLAG TRIGGER: Offer skip
      _finishFail("Device not responding. Please try again.", showSkip: true);
    });
  }

  void restartAfterFailWithPercent() {
    if (_disposed) return;
    d("Restarting Full Test Flow...");

    _stopTimers();
    _pauseNeedTicker();
    _secondTimer?.cancel();
    _cancelCompatibilityTimer();

    _resetPhaseTracking(resetBase: true);
    _batteryDiedDuringTest = false;
    _flowStopped = false;
    _waitingHandshakeAck = false;
    _testStarted = false;
    _exitSent = false;
    _holdStartAt = null;

    _waitingPercentAck = true;

    emit(const PracticeFullTestState());
    emit(state.copyWith(isConnected: repo.isConnected));

    _sendPercentWithRetry();
  }

  void _sendPercentWithRetry() {
    if (_disposed || !repo.isConnected) return;

    d("Sending Reset (%)");
    repo.sendData("%");

    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(_retryEvery, (timer) {
      if (!_waitingPercentAck || _disposed || !repo.isConnected) {
        timer.cancel();
        return;
      }
      d("Retrying Reset (%)");
      repo.sendData("%");
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeout, () {
      if (_disposed || !_waitingPercentAck) return;
      _stopTimers();
      _waitingPercentAck = false;
      // 🚨 COMPATIBILITY FLAG TRIGGER: Offer skip
      _finishFail("Failed to reset device.", showSkip: true);
    });
  }

  void startCounter({
    required FullTestPhase countdownPhase,
    required FullTestPhase nextPhase,
    int from = 5,
    bool resetBase = false,
  }) {
    if (_disposed) return;

    _resetPhaseTracking(resetBase: resetBase);
    _testStarted = false;
    _cancelCompatibilityTimer();

    if (countdownPhase == FullTestPhase.exhaleCountdown) {
      _holdStartAt = DateTime.now();
    }

    final totalMillis = from * 1000;
    final endsAt = DateTime.now().millisecondsSinceEpoch + totalMillis;

    emit(state.copyWith(
      phase: countdownPhase,
      startCounter: from,
      startCounterTotalMillis: totalMillis,
      startCounterEndsAtEpochMs: endsAt,
      showSkipButton: false, // 🚨 Reset compatibility flag
    ));

    _secondTimer?.cancel();
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || _flowStopped) return;

      final current = state.startCounter - 1;
      if (current <= 0) {
        timer.cancel();
        _testStarted = true;
        d("Timer finished. Opening data dam for ${nextPhase.name}.");
        emit(state.copyWith(phase: nextPhase));

        // 🚨 COMPATIBILITY LOGIC: Start Polling for stream data once counter finishes
        _cancelCompatibilityTimer();
        _compatibilityTimer = Timer.periodic(const Duration(seconds: 2), (t) {
          _compatibilityTicks++;
          if (_compatibilityTicks >= 4) {
            _cancelCompatibilityTimer();
            d("Stream Compatibility timeout: Device not sending packets. Showing skip.");
            // 🚨 COMPATIBILITY FLAG TRIGGER: Offer skip
            _finishFail("Device is not streaming data. It may be incompatible.",
                showSkip: true);
          }
        });
      } else {
        emit(state.copyWith(startCounter: current));
      }
    });
  }

  void _applyBandRules(double progressAbs) {
    final inBand = (progressAbs >= _minBand && progressAbs <= _maxBand);

    if (inBand && !_everReachedBand) {
      _everReachedBand = true;
      _startNeedTicker();
    }

    if (!_everReachedBand) return;

    if (inBand) {
      _outOfBandTimer?.cancel();
      _outOfBandTimer = null;
    } else {
      _outOfBandTimer ??= Timer(_failOutOfBand, () {
        _finishFail("Out of range for 2 seconds");
      });
    }
  }

  void _startNeedTicker() {
    _needLastTickAt = DateTime.now();
    emit(state.copyWith(needRunning: true));

    _needTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _flowStopped) return;

      final now = DateTime.now();
      _needAccumulated += now.difference(_needLastTickAt ?? now);
      _needLastTickAt = now;

      final seconds = (_needAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _needTarget.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_needAccumulated >= _acceptTarget) {
        _handlePhaseSuccess();
      }
    });
  }

  void _handlePhaseSuccess() {
    _pauseNeedTicker();
    _outOfBandTimer?.cancel();
    _cancelCompatibilityTimer();

    if (state.phase == FullTestPhase.inhaling) {
      d("Inhale Passed! Sending '2' (Hold).");
      if (repo.isConnected) repo.sendData("2");
      _resetPhaseTracking(resetBase: false);
      emit(state.copyWith(phase: FullTestPhase.transitioning));
    } else if (state.phase == FullTestPhase.exhaling) {
      d("Exhale Passed! Sending Exit sequence (/) and (%).");
      _flowStopped = true;
      _testStarted = false;

      _sendExitAndPercent(sendPercent: true);

      emit(state.copyWith(
        phase: FullTestPhase.success,
        failReason: _batteryDiedDuringTest ? "POST_TEST_LOW_BATTERY" : "",
      ));
    }
  }

  void _sendExitAndPercent({bool sendPercent = true}) {
    if (_exitSent) return;
    _exitSent = true;

    if (!repo.isConnected) return;

    try {
      repo.sendData("/");
    } catch (_) {}

    _postExitTimer?.cancel();
    if (!sendPercent) return;

    _postExitTimer = Timer(const Duration(milliseconds: 200), () {
      if (_disposed) return;
      if (!repo.isConnected) return;
      try {
        repo.sendData("%");
      } catch (_) {}
    });
  }

  // 🚨 UPDATED SIGNATURE: Accepts optional showSkip flag
  void _finishFail(String reason, {bool showSkip = false}) {
    if (_disposed || _flowStopped) return;
    d("Test Failed: $reason. Forcing Exit (&).");

    _flowStopped = true;
    _testStarted = false;
    _stopTimers();
    _pauseNeedTicker();
    _cancelCompatibilityTimer();

    emit(state.copyWith(
      isFailed: true,
      failReason: reason,
      showSkipButton: showSkip, // 🚨 Pass flag to state
    ));

    if (repo.isConnected) {
      try {
        repo.sendData("&");
      } catch (_) {}
    }
  }

  void _resetPhaseTracking({bool resetBase = false}) {
    _armed = false;
    _everReachedBand = false;
    _needAccumulated = Duration.zero;
    _needLastTickAt = null;
    _dropFailTriggered = false;

    // 🚨 RESET NEW VARS
    _lastEmittedProgress = -1.0;
    _smoothedProgress = 0.0;
    _breathDetectedInPhase = false;
    _incomingBuffer = "";

    if (resetBase) {
      _baseCaptured = false;
      _base = 0;
    }

    _pauseNeedTicker();
    _outOfBandTimer?.cancel();
    _cancelCompatibilityTimer();
    emit(state.copyWith(progress: 0, progressSigned: 0, inBandSeconds: 0));
  }

  void _pauseNeedTicker() {
    _needTicker?.cancel();
    _needTicker = null;
    emit(state.copyWith(needRunning: false));
  }

  void _stopTimers() {
    _retryTimer?.cancel();
    _timeoutTimer?.cancel();
    _postExitTimer?.cancel();
    _cancelCompatibilityTimer();
  }

  void stopFlow() {
    d("Forcing Full Test Flow to Stop");
    _flowStopped = true;
    _testStarted = false;
    _cancelCompatibilityTimer();
    _dataSub?.cancel();
    _connSub?.cancel();
    _secondTimer?.cancel();
  }

  Future<void> cancelTest() async {
    if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();
    if (_disposed || _flowStopped) return;
    d("User clicked Close: Aggressive Cleanup Starting.");

    _flowStopped = true;
    _testStarted = false;
    _waitingHandshakeAck = false;
    _waitingPercentAck = false;

    _stopTimers();
    _pauseNeedTicker();
    _secondTimer?.cancel();
    _secondTimer = null;

    _resetPhaseTracking(resetBase: true);

    if (repo.isConnected) {
      try {
        d("Sending Force Abort (&) to hardware...");
        repo.sendData("&");
      } catch (e) {
        d("Error during hardware exit: $e");
      }
    }

    emit(state.copyWith(navigateBack: true));
  }

  Future<void> _setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> close() {
    d("Closing Full Test Cubit - Cleaning up");
    _disposed = true;

    _postExitTimer?.cancel();
    _retryTimer?.cancel();
    _timeoutTimer?.cancel();
    _needTicker?.cancel();
    _outOfBandTimer?.cancel();
    _secondTimer?.cancel();
    _cancelCompatibilityTimer();

    _connSub?.cancel();
    _dataSub?.cancel();

    if (!_flowStopped && repo.isConnected && !_exitSent) {
      try {
        d("Emergency Stop: Sending '&' because cubit closed.");
        repo.sendData("&");
      } catch (_) {}
    }

    return super.close();
  }
}
