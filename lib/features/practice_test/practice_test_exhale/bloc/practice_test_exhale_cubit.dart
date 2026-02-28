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
  Timer? _startRetryTimer; // 🚨 Added for Cold Heater fix
  DateTime? _startSentAt; // 🚨 Added for Safe Abort fix

  bool _disposed = false;
  bool _startSent = false;
  bool _testStarted = false;
  bool _cancelled = false;
  bool _flowStopped = false;

  // 🚨 NEW: Flag to silently track low battery during an active test
  bool _batteryDiedDuringTest = false;

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

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

    // THE FIX: Wait 500ms for Inhale Cubit to die, then send '^' directly
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

      final clean = data.trim();

      // 🚨 SILENT CATCH: Note the low battery, but DO NOT return or fail.
      // Let the code continue so the test can finish on backup power.
      if (clean.contains("ERROR") && clean.contains("003")) {
        _batteryDiedDuringTest = true;
        return; // Ignore this specific packet so Regex doesn't break, let next packet flow
      }

      d("Data received: '$clean'");
      emit(state.copyWith(receivedData: clean, error: null));

      // --- AGGRESSIVE HANDSHAKE FIX ---
      // We know the device sends '%' or 'blownow' when it accepts '^'
      if (!_deviceReadyForExhale) {
        final isRawData =
            _slashNum.hasMatch(clean) || _curlyNum.hasMatch(clean);
        final lower = clean.toLowerCase();

        // 🚨 REMOVED the '%' check here! Now it MUST wait for the hardware to say "blownow"
        if (lower.contains("exhale") || lower.contains("blow") || isRawData) {
          d("Device is READY. Starting 5-second counter.");
          _deviceReadyForExhale = true;
          _waitingExhaleAck = false;
          _waitingPercentAck = false;
          _stopExhaleAckTimers();
          _stopPercentTimers();
          startCounter(from: 5);

          if (!isRawData) return;
        }
      }

      if (_waitingPercentAck && clean == "%") {
        _waitingPercentAck = false;
        _stopPercentTimers();
        _resetForFreshStart();
        _startExhaleHandshake();
        return;
      }

      if (!_testStarted) return;
      if (state.exhaleFailed || state.exhaleFinished) return;

      final slashMatch = _slashNum.firstMatch(clean);
      final curlyMatch = _curlyNum.firstMatch(clean);

      // 🚨 FIX: Fallback to curly braces if the slash was missed during the countdown
      if (!_baseCaptured) {
        if (slashMatch != null) {
          _base = double.parse(slashMatch.group(1)!);
          _baseCaptured = true;
          _startRetryTimer?.cancel(); // 🚨 Stop retrying! Data is flowing
          emit(state.copyWith(
              baseValueReceived: true, blowExhaleBaseValue: _base));
          return;
        } else if (curlyMatch != null) {
          _base = double.parse(curlyMatch.group(1)!);
          _baseCaptured = true;
          _startRetryTimer?.cancel(); // 🚨 Stop retrying! Data is flowing
          emit(state.copyWith(
              baseValueReceived: true, blowExhaleBaseValue: _base));
          return;
        }
        return;
      }

      if (curlyMatch == null) return;

      final exhaleValue = double.parse(curlyMatch.group(1)!);

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d("pkt=$_packetCount raw=$exhaleValue base=$_base");
      }

      if (exhaleValue < _base - 1.5) {
        unawaited(_setCancelOrDisconnectFlag());
        _finishFail("Inhale detected instead of exhale");
        return;
      }

      final signed = Thresholds.calculateBlowPercentage1(
        _base,
        exhaleValue,
        breathingSettings.exhale.threshold.toDouble(),
      );

      final exhaleProgress = signed > 0 ? signed : 0.0;
      final startedNow = exhaleProgress >= _armAt;

      emit(state.copyWith(
        progressSigned: signed,
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
    });
  }

  void _startExhaleHandshake() {
    if (_disposed || _cancelled || _flowStopped) return;
    if (!repo.isConnected) return;
    if (_waitingExhaleAck || _deviceReadyForExhale) return;

    _waitingExhaleAck = true;

    void sendCaret() {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!repo.isConnected) return;
      try {
        d("Sending Exhale Start Command (^)");
        repo.sendData("^");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    }

    sendCaret();

    _exhaleAckRetryTimer?.cancel();
    _exhaleAckRetryTimer = Timer.periodic(_retryEvery, (_) {
      if (!_waitingExhaleAck || _deviceReadyForExhale) return;
      sendCaret();
    });

    _exhaleAckTimeoutTimer?.cancel();
    _exhaleAckTimeoutTimer = Timer(_timeout, () {
      if (_disposed || _cancelled || _flowStopped) return;
      if (!_waitingExhaleAck || _deviceReadyForExhale) return;

      _stopExhaleAckTimers();
      _waitingExhaleAck = false;
      _finishFail("No response from device. Please try again.");
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
    _startRetryTimer?.cancel();
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
    _startSentAt = DateTime.now(); // Record start time for safe aborts

    void sendStartCmd() {
      if (!repo.isConnected || _disposed || _cancelled || _baseCaptured) return;
      d("Sending Stream Start Command (1)...");
      try {
        repo.sendData("1");
      } catch (_) {}
    }

    sendStartCmd();

    // 🚨 THE FIX: Keep sending '1' every 1.5s until the cold heater responds!
    _startRetryTimer?.cancel();
    _startRetryTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_baseCaptured ||
          _disposed ||
          _cancelled ||
          _flowStopped ||
          !repo.isConnected) {
        timer.cancel();
        return;
      }
      d("Hardware ignored start command (heater warming up). Retrying (1)...");
      sendStartCmd();
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

    if (repo.isConnected) repo.sendData("2");
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.exhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _startRetryTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _stopExhaleAckTimers();

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
      exhaleNeedRunning: false,
      exhaleNeedTotalMillis: _exhaleNeed.inMilliseconds,
      exhaleNeedEndsAtEpochMs:
          (state.exhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
    ));

    if (repo.isConnected) repo.sendData("2");
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
    _startRetryTimer?.cancel();
    _pauseExhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
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
    _waitingPercentAck = false;

    _pauseExhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();

    if (repo.isConnected && !state.exhaleFailed) {
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

    _pauseExhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();

    _connSub?.cancel();
    _dataSub?.cancel();

    return super.close();
  }
}
