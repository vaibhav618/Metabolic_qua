import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/processor/bluetooth_blow_processor.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_exhale_state.dart';

class BluetoothExhaleCubit extends Cubit<BluetoothExhaleState> {
  final BluetoothBlowProcessor processor;
  final BluetoothRepository repo;
  final String baseValue;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (kDebug) {
      // ignore: avoid_print
      print("[EXHALE_CUBIT] $msg");
    }
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  bool _disposed = false;
  bool _startSent = false;
  bool _exhaleSucceeded = false;

  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');
  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');

  double get _minRange => breathingSettings.exhale.minBand.toDouble();
  double get _maxRange => breathingSettings.exhale.maxBand.toDouble();

  Duration get _holdTotalMs =>
      Duration(milliseconds: breathingSettings.exhale.timeMs);
  Duration get _holdAcceptMs =>
      _holdTotalMs - const Duration(milliseconds: 500);

  static const double _stopProgressThreshold = 0.0;
  static const double _inhaleDrop = 1;
  static const int _startTimeoutSec = 30;

  Timer? _holdTicker;
  DateTime? _lastHoldTickAt;

  int _holdRemainingMs = 0;
  int _inRangeAccumMs = 0;

  final List<double> _blowValues = [];

  bool _finalized = false;
  bool _timeSaved = false;
  bool _failed = false;

  bool _abortSent = false;

  Timer? _startTimeoutTicker;
  Timer? _startTimeoutTimer;

  bool _exhaleDetected = false;

  // 🚨 NEW: Track the last emitted progress to stop UI stuttering!
  double _lastEmittedProgress = -1.0;

  // 🚨 NEW: Track the smoothed value for the low-pass filter
  double _smoothedProgress = 0.0;

  // 🚨 FIX 1: Bulletproof parsing for the passed-in baseValue
  double get _baseDouble {
    String cleanBase = baseValue.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanBase.isNotEmpty) {
      return double.tryParse(cleanBase) ?? 0.0;
    }
    return 0.0;
  }

  BluetoothExhaleCubit({
    required this.processor,
    required this.repo,
    required this.baseValue,
    required this.breathingSettings,
  }) : super(const BluetoothExhaleState()) {
    _init();
  }

  void _init() {
    processor.reset();
    processor.processBlowData(
      baseValue,
      (val) => Thresholds.calculateThresholdPercentage(val),
      (baseVal, blowVal) => Thresholds.calculateBlowPercentage1(
          baseVal, blowVal, breathingSettings.exhale.threshold.toDouble()),
    );

    _holdRemainingMs = _holdTotalMs.inMilliseconds;
    _inRangeAccumMs = 0;
    _blowValues.clear();

    _disposed = false;
    _finalized = false;
    _timeSaved = false;
    _exhaleSucceeded = false;
    _startSent = false;
    _failed = false;
    _abortSent = false;
    _exhaleDetected = false;
    _lastEmittedProgress = -1.0; // Reset throttle
    _smoothedProgress = 0.0; // Reset smoothed value

    _cancelStartTimeoutTimers();

    emit(state.copyWith(
      isConnected: repo.isConnected,
      progress: 0,
      holdSecondsLeft: (_holdRemainingMs / 1000).ceil().clamp(1, 9999),
      exhaleStarted: false,
      inRange: false,
      exhaleSuccess: false,
      exhaleFailed: false,
      analysisReady: false,
      blowValues: const [],
      inRangeDurationMs: 0,
      navigateToDashboard: false,
      cancelTest: false,
      error: null,
      startTimeoutRunning: false,
      startTimeoutLeftSec: _startTimeoutSec,
    ));

    _connSub = repo.connectionStatusStream().listen((connected) {
      if (_disposed) return;

      emit(state.copyWith(isConnected: connected));

      if (!connected) {
        _pauseHoldCountdown();
        _cancelStartTimeoutTimers();
        emit(state.copyWith(error: "Device disconnected. Please reconnect."));
        return;
      }

      _sendStartExhaleOnce();
    });

    _dataSub = repo.receivedDataStream().listen(_onData);

    _sendStartExhaleOnce();
  }

  void _sendStartExhaleOnce() {
    if (_disposed || _startSent || _finalized) return;

    if (!repo.isConnected) {
      d("cannot send 3, not connected");
      return;
    }

    try {
      d("SEND '3'");
      repo.sendData("3");
      _startSent = true;
      _startStartTimeoutTimers();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _startStartTimeoutTimers() {
    _cancelStartTimeoutTimers();

    emit(state.copyWith(
      startTimeoutRunning: true,
      startTimeoutLeftSec: _startTimeoutSec,
    ));

    int left = _startTimeoutSec;

    _startTimeoutTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || _finalized || _failed) return;
      if (_exhaleDetected ||
          state.exhaleStarted ||
          state.exhaleSuccess ||
          state.exhaleFailed) return;

      left = (left - 1).clamp(0, _startTimeoutSec);
      emit(state.copyWith(startTimeoutLeftSec: left));

      if (left <= 0) {
        _startTimeoutTicker?.cancel();
        _startTimeoutTicker = null;
      }
    });

    _startTimeoutTimer = Timer(const Duration(seconds: _startTimeoutSec), () {
      if (_disposed || _finalized || _failed) return;
      if (_exhaleDetected ||
          state.exhaleStarted ||
          state.exhaleSuccess ||
          state.exhaleFailed) return;

      _failed = true;
      _fail(
          reason:
              "Timeout: No exhale detected within $_startTimeoutSec seconds.");
    });
  }

  void _cancelStartTimeoutTimers() {
    _startTimeoutTicker?.cancel();
    _startTimeoutTicker = null;

    _startTimeoutTimer?.cancel();
    _startTimeoutTimer = null;

    if (state.startTimeoutRunning) {
      emit(state.copyWith(
        startTimeoutRunning: false,
        startTimeoutLeftSec: _startTimeoutSec,
      ));
    }
  }

  void _sendAbortOnce({required String why}) {
    if (_abortSent) {
      d("Skip '&' (already sent) | $why");
      return;
    }
    _abortSent = true;

    if (!repo.isConnected) {
      d("Skip '&' (not connected) | $why");
      return;
    }

    try {
      d("SEND '&' | $why");
      repo.sendData("&");
    } catch (_) {
      d("Error sending '&' | $why");
    }
  }

  void _onData(String data) {
    if (_disposed || _finalized || data.isEmpty) return;
    if (_failed) return;

    final clean = data.trim();

    // 🚨 REMOVED the unthrottled emit(receivedData) from here to stop the spam

    if (_exhaleSucceeded) {
      if (clean.toLowerCase().contains("analize") ||
          clean.toLowerCase().contains("analyze")) {
        emit(state.copyWith(analysisReady: true));
      }
      return;
    }

    // =======================================================================
    // 🚨 FIX 2: BULLETPROOF STRING PARSING
    // =======================================================================
    bool isCurly = clean.contains('{') || clean.contains('}');
    if (!isCurly) return; // Ignore non-pressure packets

    String numberString = clean.replaceAll(RegExp(r'[^0-9.]'), '');
    if (numberString.isEmpty) return;

    double blowVal = 0.0;
    try {
      blowVal = double.parse(numberString);
    } catch (e) {
      return;
    }

    if (blowVal < 700 || blowVal > 1150) return; // Widened safety bounds
    // =======================================================================

    final base = _baseDouble;

    // exhale detection: value > base + 0.5 (filters out ambient room noise)
    if (!_exhaleDetected && blowVal > base + 0.5) {
      _exhaleDetected = true;
      d("Exhale detected: $blowVal > $base");
      _cancelStartTimeoutTimers();
    }

    // once detected, if <= base => stopped exhaling => FAIL
    if (_exhaleDetected && blowVal <= base + 0.5) {
      _failed = true;
      _fail(reason: "Exhale stopped too early.");
      return;
    }

    // inhale detected anytime
    if (blowVal < (base - _inhaleDrop)) {
      _failed = true;
      _fail(reason: "Oops! You inhaled instead of exhaling.");
      return;
    }

    _blowValues.add(blowVal);

    double progress = 0;
    if (blowVal > base) {
      progress = Thresholds.calculateBlowPercentage1(
          base, blowVal, breathingSettings.exhale.threshold.toDouble());
    }

    // 🚨 NOISE GATE: Pin the ball to the bottom (0.0) until the actual breath breaks the noise threshold.
    // This stops the ball from "floating" or vibrating while waiting for you to blow.
    if (!_exhaleDetected) {
      progress = 0.0;
    }

    _handleProgress(progress, clean);
  }

  void _handleProgress(double rawProgress, String cleanData) {
    if (_disposed || _finalized) return;
    if (_failed) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    // =======================================================================
    // 🚨 FAST SYMMETRIC SMOOTHING
    // 80% reaction speed for both UP and DOWN.
    // Fast and tight response both ways, hiding just the micro-jitter.
    // =======================================================================
    const double alpha = 0.80;
    if (_lastEmittedProgress < 0) {
      _smoothedProgress = rawProgress;
    } else {
      _smoothedProgress =
          (rawProgress * alpha) + (_smoothedProgress * (1.0 - alpha));
    }

    final nowInRange =
        (_smoothedProgress >= _minRange && _smoothedProgress <= _maxRange);
    final newlyStarted = !state.exhaleStarted && nowInRange;

    _lastEmittedProgress = _smoothedProgress;

    emit(state.copyWith(
      progress: _smoothedProgress,
      inRange: nowInRange,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      receivedData: cleanData,
      error: null,
      exhaleStarted: newlyStarted ? true : state.exhaleStarted,
    ));

    if (newlyStarted) {
      _cancelStartTimeoutTimers();
      _resumeHoldCountdown();
      return;
    }

    if (state.exhaleStarted && _smoothedProgress <= _stopProgressThreshold) {
      _failed = true;
      _fail(reason: "Exhale failed: you stopped exhaling.");
      return;
    }

    if (!state.exhaleStarted) return;

    if (nowInRange) {
      _resumeHoldCountdown();
    } else {
      _pauseHoldCountdown();
    }
  }

  void _resumeHoldCountdown() {
    if (_inRangeAccumMs >= _holdAcceptMs.inMilliseconds) return;
    if (_holdTicker != null) return;

    _lastHoldTickAt = DateTime.now();

    // 100ms emission is fine here because it's a controlled 10Hz, not tied to BLE packet spam
    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _finalized) return;
      if (_failed) return;
      if (state.exhaleFailed || state.exhaleSuccess) return;

      _lastHoldTickAt ??= DateTime.now();
      final now = DateTime.now();
      final dt = now.difference(_lastHoldTickAt!).inMilliseconds;
      _lastHoldTickAt = now;

      _inRangeAccumMs += dt;

      _holdRemainingMs -= dt;
      if (_holdRemainingMs < 0) _holdRemainingMs = 0;

      final secondsLeft = (_holdRemainingMs / 1000).ceil().clamp(1, 9999);

      emit(state.copyWith(
        holdSecondsLeft: secondsLeft,
        inRangeDurationMs: _inRangeAccumMs,
      ));

      if (_inRangeAccumMs >= _holdAcceptMs.inMilliseconds) {
        _holdTicker?.cancel();
        _holdTicker = null;
        _holdRemainingMs = 0;
        _markSuccess();
        return;
      }

      if (_holdRemainingMs <= 0) {
        _holdTicker?.cancel();
        _holdTicker = null;
        _markSuccess();
      }
    });
  }

  void _pauseHoldCountdown() {
    _holdTicker?.cancel();
    _holdTicker = null;
    _lastHoldTickAt = null;
  }

  void _markSuccess() {
    if (_disposed || _finalized) return;
    if (_failed) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    if (repo.isConnected) {
      try {
        d("SEND '/' (success)");
        repo.sendData("/");
      } catch (_) {}
    }

    _exhaleSucceeded = true;

    emit(state.copyWith(
      exhaleSuccess: true,
      exhaleFailed: false,
      error: null,
      holdSecondsLeft: 1,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
    ));
  }

  Future<void> _fail({required String reason}) async {
    if (_disposed || _finalized) return;
    if (state.exhaleFailed || state.exhaleSuccess) return;

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    await _saveCancelTimeOnce();
    _sendAbortOnce(why: "fail");

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: reason,
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: false,
      startTimeoutRunning: false,
    ));
  }

  Future<void> cancelTest() async {
    if (_disposed || _finalized) return;

    _finalized = true;
    _failed = true;

    emit(state.copyWith(cancelTest: true));

    _pauseHoldCountdown();
    _cancelStartTimeoutTimers();

    _sendAbortOnce(why: "cancelTest");
    await _saveCancelTimeOnce();

    emit(state.copyWith(
      exhaleSuccess: false,
      exhaleFailed: true,
      error: "Aborted by user.",
      inRangeDurationMs: _inRangeAccumMs,
      blowValues: List<double>.unmodifiable(_blowValues),
      navigateToDashboard: true,
      cancelTest: true,
      startTimeoutRunning: false,
    ));
  }

  Future<void> _saveCancelTimeOnce() async {
    if (_timeSaved) return;
    _timeSaved = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cancel_or_disconnect_time',
      DateTime.now().toIso8601String(),
    );

    d("Saved cancel_or_disconnect_time");
  }

  @override
  Future<void> close() {
    _disposed = true;

    _holdTicker?.cancel();
    _cancelStartTimeoutTimers();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
