import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../common/widgets/threshold.dart';
import '../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'practice_test_inhale_state.dart';

class PracticeTestInhaleCubit extends Cubit<PracticeTestInhaleState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (!kDebug) return;
    debugPrint("[PRACTICE_INHALE] $msg");
  }

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _finishTimer;
  Timer? _secondTimer;

  bool _disposed = false;
  bool _startSent = false;
  bool _testStarted = false;
  bool _cancelled = false;
  bool _flowStopped = false;

  // 🚨 NEW: Flag to silently track low battery during an active test
  bool _lowBatteryDetectedDuringTest = false;

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  bool _baseCaptured = false;
  double _base = 0;

  bool _armed = false;
  static const double _armAt = 10.0;

  double get _minBand => breathingSettings.inhale.minBand.toDouble();
  double get _maxBand => breathingSettings.inhale.maxBand.toDouble();

  Duration get _inhaleNeed =>
      Duration(milliseconds: breathingSettings.inhale.timeMs);

  Duration get _inhaleAccept {
    final need = _inhaleNeed;
    if (need <= const Duration(milliseconds: 500)) return need;
    return need - const Duration(milliseconds: 500);
  }

  static const Duration _failOutOfBand = Duration(seconds: 2);

  bool _everReachedBand = false;

  Timer? _inhaleNeedTicker;
  Duration _inhaleNeedAccumulated = Duration.zero;
  DateTime? _inhaleNeedLastTickAt;

  Timer? _outOfBandTimer;

  static const double _dropToZeroThreshold = 1.0;
  bool _dropFailTriggered = false;

  int _packetCount = 0;

  bool _waitingInhaleAck = false;
  bool _deviceReadyForInhale = false;
  Timer? _inhaleAckRetryTimer;
  Timer? _inhaleAckTimeoutTimer;

  bool _waitingPercentAck = false;
  Timer? _percentRetryTimer;
  Timer? _percentTimeoutTimer;

  static const Duration _retryEvery = Duration(milliseconds: 500);
  static const Duration _timeout = Duration(seconds: 3);

  PracticeTestInhaleCubit(this.repo, this.breathingSettings)
      : super(const PracticeTestInhaleState()) {
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));
    _startInhaleHandshake();
  }

  bool get _canSaveAbortTime =>
      _testStarted ||
      state.startCounterStarted ||
      state.startCounterFinished ||
      state.inhaleStarted ||
      _waitingInhaleAck ||
      _waitingPercentAck;

  void _listen() {
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (_disposed) return;

      emit(state.copyWith(isConnected: connected, error: null));

      if (!connected) {
        final flowRunning = _testStarted ||
            state.startCounterStarted ||
            state.startCounterFinished ||
            state.inhaleStarted ||
            _waitingInhaleAck ||
            _waitingPercentAck;

        if (flowRunning && !state.inhaleFailed && !state.inhaleFinished) {
          if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();
          _finishDisconnect(
              "Device disconnected. Please reconnect and try again.");
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      if (data.isEmpty) return;

      final clean = data.trim();
      emit(state.copyWith(receivedData: clean, error: null));

      if (_waitingPercentAck) {
        if (clean == "%") {
          _waitingPercentAck = false;
          _stopPercentTimers();
          _resetForFreshStart();
          _startInhaleHandshake();
        }
        return;
      }

      if (_waitingInhaleAck && !_deviceReadyForInhale) {
        if (clean.toLowerCase() == "inhale") {
          _deviceReadyForInhale = true;
          _waitingInhaleAck = false;
          _stopInhaleAckTimers();
          startCounter(from: 5);
        }
        return;
      }

      if (!_testStarted) return;
      if (state.inhaleFailed || state.inhaleFinished) return;

      final slashMatch = _slashNum.firstMatch(clean);
      final curlyMatch = _curlyNum.firstMatch(clean);

      // 🚨 FIX: Fallback to curly braces if the slash packet was sent during the countdown
      if (!_baseCaptured) {
        if (slashMatch != null) {
          _base = double.parse(slashMatch.group(1)!);
          _baseCaptured = true;
          emit(state.copyWith(
              baseValueReceived: true, blowExhaleBaseValue: _base));
          return;
        } else if (curlyMatch != null) {
          _base = double.parse(curlyMatch.group(1)!);
          _baseCaptured = true;
          emit(state.copyWith(
              baseValueReceived: true, blowExhaleBaseValue: _base));
          return;
        }
        return;
      }

      if (curlyMatch == null) return;

      final inhaleValue = double.parse(curlyMatch.group(1)!);

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d("pkt=$_packetCount raw=$inhaleValue base=$_base");
      }

      // 🚨 UPDATED RULE: Relaxed to 1.5 to absorb natural sensor rebound when dropping the ball
      if (inhaleValue > _base + 1.5) {
        unawaited(_setCancelOrDisconnectFlag());
        _finishFail("Exhale detected instead of inhale");
        return;
      }

      final signed = Thresholds.calculateInhalePercentage(
        _base,
        inhaleValue,
        breathingSettings.inhale.threshold.toDouble(),
      );

      final inhaleProgress = signed < 0 ? (-signed) : 0.0;
      final startedNow = inhaleProgress >= _armAt;

      emit(state.copyWith(
        progressSigned: signed,
        progress: startedNow ? inhaleProgress : 0,
        inhaleStarted: startedNow ? true : state.inhaleStarted,
        inhaleFinished: state.inhaleFinished,
      ));

      if (!_armed && startedNow) _armed = true;

      if (_armed &&
          !_dropFailTriggered &&
          inhaleProgress <= _dropToZeroThreshold) {
        _dropFailTriggered = true;
        _finishFail("Inhale dropped to 0");
        return;
      }

      if (_armed && !state.inhaleFinished) {
        _applyBandRules(inhaleProgress);
      }
    });
  }

  void _startInhaleHandshake() {
    if (_disposed || _cancelled || _flowStopped) return;
    if (!repo.isConnected) return;
    if (_waitingInhaleAck || _deviceReadyForInhale) return;

    _waitingInhaleAck = true;

    void sendTilde() {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      try {
        repo.sendData("~");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    sendTilde();

    _inhaleAckRetryTimer?.cancel();
    _inhaleAckRetryTimer = Timer.periodic(_retryEvery, (_) {
      if (!_waitingInhaleAck || _deviceReadyForInhale) return;
      sendTilde();
    });

    _inhaleAckTimeoutTimer?.cancel();
    _inhaleAckTimeoutTimer = Timer(_timeout, () {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!_waitingInhaleAck || _deviceReadyForInhale) return;

      _stopInhaleAckTimers();
      _waitingInhaleAck = false;
      _finishFail("No response from device. Please try again.");
    });
  }

  void restartAfterFailWithPercent() {
    if (_disposed || _cancelled) return;
    // 🚨 THE FIX: If disconnected, force the UI to navigate back to the practice menu
    if (!repo.isConnected) {
      d("Cannot restart. Device disconnected. Forcing exit.");
      emit(state.copyWith(navigateBack: true));
      return;
    }

    _flowStopped = false;
    _testStarted = false;

    emit(state.copyWith(
      inhaleFailed: false,
      inhaleFinished: false,
      inhaleSuccess: false,
      inhaleFailReason: "",
      startCounterStarted: false,
      startCounterFinished: false,
      startCounter: 0,
      startCounterMillis: 0,
      startCounterTotalMillis: 0,
      startCounterEndsAtEpochMs: 0,
      progress: 0,
      progressSigned: 0,
      inBandSeconds: 0,
      inhaleNeedRunning: false,
      inhaleNeedStartsAtEpochMs: 0,
      inhaleNeedEndsAtEpochMs: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      error: null,
      navigateBack: false,
      inhaleStarted: false,
    ));

    _sendPercentAndWaitAck();
  }

  void _sendPercentAndWaitAck() {
    if (_waitingPercentAck) return;

    _waitingPercentAck = true;

    void sendPercent() {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      try {
        repo.sendData("%");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    sendPercent();

    _percentRetryTimer?.cancel();
    _percentRetryTimer = Timer.periodic(_retryEvery, (_) {
      if (!_waitingPercentAck) return;
      sendPercent();
    });

    _percentTimeoutTimer?.cancel();
    _percentTimeoutTimer = Timer(_timeout, () {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!_waitingPercentAck) return;

      _waitingPercentAck = false;
      _stopPercentTimers();
      emit(state.copyWith(error: "No response for % from device"));
    });
  }

  void startCounter({int from = 5}) {
    if (_disposed) return;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

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
      inhaleStarted: false,
      inhaleFinished: false,
      inhaleSuccess: false,
      inhaleFailed: false,
      inhaleFailReason: "",
      inBandSeconds: 0,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedStartsAtEpochMs: 0,
      inhaleNeedEndsAtEpochMs: 0,
      progress: 0,
      progressSigned: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      error: null,
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
    if (!_deviceReadyForInhale) return;

    _startSent = true;

    try {
      repo.sendData("1");
      _testStarted = true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _applyBandRules(double progressAbs) {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;

    final inBand = (progressAbs >= _minBand && progressAbs <= _maxBand);

    if (inBand && !_everReachedBand) {
      _everReachedBand = true;

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(
        inhaleNeedRunning: true,
        inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
        inhaleNeedStartsAtEpochMs: nowMs,
        inhaleNeedEndsAtEpochMs: 0,
      ));

      _startInhaleNeedTickerIfNeeded();
    }

    if (!_everReachedBand) return;

    if (inBand) {
      _cancelOutOfBandFailTimer();
    } else {
      _startOutOfBandFailTimerIfNeeded("Out of range for 2 seconds");
    }
  }

  void _startInhaleNeedTickerIfNeeded() {
    if (_inhaleNeedTicker != null) return;

    _inhaleNeedLastTickAt = DateTime.now();

    if (!state.inhaleNeedRunning) {
      emit(state.copyWith(inhaleNeedRunning: true));
    }

    _inhaleNeedTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished)
        return;

      final now = DateTime.now();
      final last = _inhaleNeedLastTickAt ?? now;
      _inhaleNeedLastTickAt = now;

      _inhaleNeedAccumulated += now.difference(last);

      final seconds = (_inhaleNeedAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _inhaleNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_inhaleNeedAccumulated >= _inhaleAccept) {
        _finishInhaleSuccess();
      }
    });
  }

  void _pauseInhaleNeedTicker({required bool setRunningFalse}) {
    _inhaleNeedTicker?.cancel();
    _inhaleNeedTicker = null;
    _inhaleNeedLastTickAt = null;

    if (setRunningFalse && state.inhaleNeedRunning) {
      emit(state.copyWith(inhaleNeedRunning: false));
    }
  }

  void _startOutOfBandFailTimerIfNeeded(String reason) {
    if (_outOfBandTimer != null) return;
    _outOfBandTimer = Timer(_failOutOfBand, () {
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished)
        return;
      _finishFail(reason);
    });
  }

  void _cancelOutOfBandFailTimer() {
    _outOfBandTimer?.cancel();
    _outOfBandTimer = null;
  }

  void _finishInhaleSuccess() {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;

    _flowStopped = true;
    _testStarted = false;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: true,
      inhaleFailed: false,
      // 🚨 NEW: Pass the warning string to the UI if the battery died during the test
      inhaleFailReason:
          _lowBatteryDetectedDuringTest ? "POST_TEST_LOW_BATTERY" : "",
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs: nowMs,
    ));

    if (repo.isConnected) repo.sendData("2");
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopInhaleAckTimers();

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _stopPercentTimers();
    _waitingPercentAck = false;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: reason,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs:
          (state.inhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
    ));

    if (repo.isConnected) repo.sendData("2");
  }

  void _finishDisconnect(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopInhaleAckTimers();
    _stopPercentTimers();
    _waitingPercentAck = false;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: reason,
    ));

    if (repo.isConnected) repo.sendData("&");
  }

  void _resetAllTracking() {
    _armed = false;
    _everReachedBand = false;
    _inhaleNeedAccumulated = Duration.zero;
    _inhaleNeedLastTickAt = null;
    _dropFailTriggered = false;
    _lowBatteryDetectedDuringTest = false; // 🚨 NEW: Reset the flag on retries
    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _packetCount = 0;
  }

  void _resetForFreshStart() {
    _startSent = false;
    _testStarted = false;
    _flowStopped = false;

    _deviceReadyForInhale = false;
    _waitingInhaleAck = false;
    _stopInhaleAckTimers();

    _baseCaptured = false;
    _base = 0;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _resetAllTracking();
  }

  void _stopInhaleAckTimers() {
    _inhaleAckRetryTimer?.cancel();
    _inhaleAckTimeoutTimer?.cancel();
    _inhaleAckRetryTimer = null;
    _inhaleAckTimeoutTimer = null;
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

    _stopInhaleAckTimers();
    _stopPercentTimers();
    _waitingPercentAck = false;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    if (repo.isConnected && !state.inhaleFailed) {
      try {
        // repo.sendData("&");
        repo.sendData("2");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    if (!state.startCounterFinished) {
      try {
        // repo.sendData("&");
        repo.sendData("&");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: "Aborted by user.",
      navigateBack: true,
    ));
  }

  Future<void> sendAbort() async {
    if (_disposed) return;
    if (_canSaveAbortTime) await _setCancelOrDisconnectFlag();

    try {
      if (repo.isConnected) repo.sendData("&");
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
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
    _disposed = true;

    _finishTimer?.cancel();
    _secondTimer?.cancel();

    _stopInhaleAckTimers();
    _stopPercentTimers();

    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
