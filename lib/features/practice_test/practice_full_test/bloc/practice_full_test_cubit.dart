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

  bool _disposed = false;
  bool _flowStopped = false;
  bool _testStarted = false;

  // 🚨 NEW: Flag to silently track low battery during an active test
  bool _batteryDiedDuringTest = false;

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

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

  // 🚨 ADDED: Track when the hold phase started to give a 1-second grace period
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

      final clean = data.trim();
      if (clean.isEmpty) return;

      // 🚨 SILENT CATCH: Note the low battery, but DO NOT return or fail.
      // Let the code continue so the test can finish on backup power.
      if (clean.contains("ERROR") && clean.contains("003")) {
        _batteryDiedDuringTest = true;
        return; // Ignore this specific packet so Regex doesn't break
      }

      // Only print raw packets occasionally to keep logs clean, but always print text commands
      final isRawData = _slashNum.hasMatch(clean) || _curlyNum.hasMatch(clean);
      if (!isRawData) d("Data received: '$clean'");

      final lower = clean.toLowerCase();

      // 1) RETRY CHECK (%)
      if (_waitingPercentAck) {
        if (clean == "%" || isRawData) {
          d("Reset confirmed. Restarting flow with (|).");
          _waitingPercentAck = false;
          _stopTimers();
          _startFullTestHandshake();
        }
        return;
      }

      // 2) HANDSHAKE (|) -> Wait for 'inhale' OR Auto-Start on raw data
      if (_waitingHandshakeAck && state.phase == FullTestPhase.initial) {
        if (lower.contains("inhale") || isRawData) {
          d("Handshake OK. Sending '1' to start inhale stream.");
          _waitingHandshakeAck = false;
          _stopTimers();
          if (repo.isConnected) repo.sendData("1");
          startCounter(
            countdownPhase: FullTestPhase.inhaleCountdown,
            nextPhase: FullTestPhase.inhaling,
            from: 5,
            resetBase: true, // 🚨 Capture a fresh baseline at test start
          );
          return;
        }
      }

// 3) TRANSITION -> Wait for hardware prompt OR Auto-Start on raw data
      if (state.phase == FullTestPhase.transitioning) {
        if (lower.contains("blow") ||
            lower.contains("exhale") ||
            clean == "3" ||
            isRawData) {
          d("Device Ready for Exhale. Sending '3' to start stream.");
          if (repo.isConnected) repo.sendData("3");
          startCounter(
            countdownPhase: FullTestPhase.exhaleCountdown,
            nextPhase: FullTestPhase.exhaling,
            from: 8,
            resetBase: false, // 🚨 KEEP the same baseline for the Hold phase!
          );
          return;
        }
      }

      // ---------------------------------------------------------
      // THE FIX: THE DATA DAM
      // If we are currently counting down (Inhale prep), ignore data.
      // 🚨 EXCEPTION: We ALLOW data during 'exhaleCountdown' because that is our 8-second Hold Phase!
      if (!_testStarted && state.phase != FullTestPhase.exhaleCountdown) return;
      // ---------------------------------------------------------

      final slashMatch = _slashNum.firstMatch(clean);
      final curlyMatch = _curlyNum.firstMatch(clean);

      // 4) BASE CAPTURE (Only happens the moment the timer hits 0)
      if (!_baseCaptured) {
        if (slashMatch != null) {
          _base = double.parse(slashMatch.group(1)!);
          _baseCaptured = true;
          d("Captured Fresh Base (slash): $_base for ${state.phase.name}");
          return;
        } else if (curlyMatch != null) {
          _base = double.parse(curlyMatch.group(1)!);
          _baseCaptured = true;
          d("Captured Fresh Base (curly fallback): $_base for ${state.phase.name}");
          return;
        }
      }

      // 5) DATA PROCESSING ({})
      if (!_baseCaptured || curlyMatch == null) return;

      final value = double.parse(curlyMatch.group(1)!);

      if (state.phase == FullTestPhase.inhaling) {
        _processInhaleData(value);
      } else if (state.phase == FullTestPhase.exhaling) {
        _processExhaleData(value);
      } else if (state.phase == FullTestPhase.exhaleCountdown) {
        // 🚨 Target the hold phase!
        _processHoldData(value);
      }
    });
  }

  // 🚨 ADDED: Cloned directly from main test hold logic with grace periods
  void _processHoldData(double value) {
    final holdStart = _holdStartAt;
    if (holdStart == null) return;

    final elapsedHold = DateTime.now().difference(holdStart);

    // Give them a 1.5 second grace period to let the ball drop back to 0
    if (elapsedHold < const Duration(milliseconds: 1500)) return;

    // Tolerance relaxed slightly to 2.5 to avoid false positives from natural sensor drift
    if (value > (_base + 2.5)) {
      _finishFail("Exhale detected during hold");
      return;
    }

    if (value < (_base - 2.5)) {
      _finishFail("Inhale detected during hold");
      return;
    }
  }

  // 🚨 REWRITTEN: Exact clone of standalone Inhale logic
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

    final inhaleProgress = signed < 0 ? (-signed) : 0.0;
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

  // 🚨 REWRITTEN: Exact clone of standalone Exhale logic
  void _processExhaleData(double value) {
    if (value < _base - 1.5) {
      _finishFail("Inhale detected instead of exhale");
      return;
    }

    final signed = Thresholds.calculateBlowPercentage1(
      _base,
      value,
      breathingSettings.exhale.threshold.toDouble(),
    );

    final exhaleProgress = signed > 0 ? signed : 0.0;
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
      _finishFail("Device not responding. Please try again.");
    });
  }

  void restartAfterFailWithPercent() {
    if (_disposed) return;
    d("Restarting Full Test Flow...");

    _stopTimers();
    _pauseNeedTicker();
    _secondTimer?.cancel();

    // Reset everything
    _resetPhaseTracking(
        resetBase: true); // 🚨 Wipe base completely on a fresh restart
    _batteryDiedDuringTest = false; // 🚨 Reset flag on retries
    _flowStopped = false;
    _waitingHandshakeAck = false;
    _testStarted = false;
    _exitSent = false;
    _holdStartAt = null;

    // Ensure Cubit drops all stale data and waits for confirmation
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
      _finishFail("Failed to reset device.");
    });
  }

  void startCounter({
    required FullTestPhase countdownPhase,
    required FullTestPhase nextPhase,
    int from = 5,
    bool resetBase = false, // 🚨 Added to control the baseline
  }) {
    if (_disposed) return;

    // Crucial: Clear the base so we capture a fresh one when timer hits 0
    _resetPhaseTracking(resetBase: resetBase);
    _testStarted = false;

    // 🚨 Mark the exact time the hold phase starts
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

    if (state.phase == FullTestPhase.inhaling) {
      d("Inhale Passed! Sending '2' (Hold).");
      if (repo.isConnected) repo.sendData("2");
      _resetPhaseTracking(resetBase: false); // 🚨 Keep base for the hold phase!
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

  void _finishFail(String reason) {
    if (_disposed || _flowStopped) return;
    d("Test Failed: $reason. Forcing Exit (&).");

    _flowStopped = true;
    _testStarted = false;
    _stopTimers();
    _pauseNeedTicker();

    emit(state.copyWith(
      isFailed: true,
      failReason: reason,
    ));

    // Force stream closure on failure
    if (repo.isConnected) {
      try {
        repo.sendData("&");
      } catch (_) {}
    }
  }

  // 🚨 Modified to let us keep the baseline between phases
  void _resetPhaseTracking({bool resetBase = false}) {
    _armed = false;
    _everReachedBand = false;
    _needAccumulated = Duration.zero;
    _needLastTickAt = null;
    _dropFailTriggered = false;

    if (resetBase) {
      _baseCaptured = false;
      _base = 0;
    }

    _pauseNeedTicker();
    _outOfBandTimer?.cancel();
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
  }

  void stopFlow() {
    d("Forcing Full Test Flow to Stop");
    _flowStopped = true;
    _testStarted = false;
    _dataSub?.cancel();
    _connSub?.cancel();
    _secondTimer?.cancel();
  }

  Future<void> cancelTest() async {
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
