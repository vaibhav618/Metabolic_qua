import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../common/widgets/threshold.dart';
import '../../../data/model/breath_setting_model.dart';
import 'bluetooth_inhale_new_state.dart';

class BluetoothInhaleCubitNew extends Cubit<BluetoothInhaleCubitNewState> {
  final BluetoothRepository repo;
  final BreathingSettings breathingSettings;

  static const bool kDebug = true;
  void d(String msg) {
    if (kDebug) {
      // ignore: avoid_print
      print("[INHALE_CUBIT] $msg");
    }
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

  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  bool _baseCaptured = false;
  double _base = 0;

  bool _armed = false;
  static const double _armAt = 10.0;

  double get _minBand => breathingSettings.inhale.minBand.toDouble();
  double get _maxBand => breathingSettings.inhale.maxBand.toDouble();

  Duration get _inhaleNeed => Duration(milliseconds: breathingSettings.inhale.timeMs);

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

  // ---------------- HOLD RULES ----------------
  Duration get _holdNeed {
    final int ms = breathingSettings.hold.timeMs;
    if (ms <= 0) return const Duration(seconds: 8);
    return Duration(milliseconds: ms);
  }

  bool _holdActive = false;
  bool _holdDone = false;
  Timer? _holdTicker;
  DateTime? _holdStartAt;

  static const Duration _holdStartCheckingAfter = Duration(seconds: 1);
  static const double _holdRawTolerance = 3.0;

  int _packetCount = 0;

  // (kept same even if not used now)
  Timer? _exhaleTimer;
  bool _exhaleTimerRunning = false;

  BluetoothInhaleCubitNew(this.repo, this.breathingSettings)
      : super(const BluetoothInhaleCubitNewState()) {
    d("Cubit init | connected=${repo.isConnected}");
    _listen();
    emit(state.copyWith(isConnected: repo.isConnected));
    startCounter(from: 5);
  }

  bool get _canSaveAbortTime => state.holdStarted || _holdActive || state.holdFinished;

  void _listen() {
    _connSub = repo.connectionStatusStream().listen((connected) async {
      if (_disposed) return;

      d("Connection status changed -> $connected");
      emit(state.copyWith(isConnected: connected, error: null));

      if (!connected) {
        final bool flowRunning =
            _testStarted ||
                state.startCounterStarted ||
                state.startCounterFinished ||
                state.inhaleStarted ||
                _holdActive ||
                state.holdStarted;

        if (flowRunning && !state.inhaleFailed && !state.inhaleFinished) {
          d("DISCONNECT during test");

          if (_canSaveAbortTime) {
            await setCancelOrDisconnectFlag();
          }

          _finishFail("Device disconnected. Please reconnect and try again.");
        }
      }
    });

    _dataSub = repo.receivedDataStream().listen((data) {
      if (_disposed || _cancelled || _flowStopped) return;
      if (data.isEmpty || !_testStarted) return;
      if (!repo.isConnected) return;

      if (state.inhaleFailed) return;
      if (state.inhaleFinished && !_holdActive) return;

      final clean = data.trim();
      emit(state.copyWith(receivedData: clean, error: null));

      final slashMatch = _slashNum.firstMatch(clean);
      final curlyMatch = _curlyNum.firstMatch(clean);

      // ---------------- BASE CAPTURE ----------------
      if (!_baseCaptured && slashMatch != null) {
        _base = double.parse(slashMatch.group(1)!);
        _baseCaptured = true;

        d("Base captured: /$_base/");

        emit(state.copyWith(
          baseValueReceived: true,
          blowExhaleBaseValue: _base,
        ));
        return;
      }

      if (!_baseCaptured || curlyMatch == null) return;

      final inhaleValue = double.parse(curlyMatch.group(1)!);

      _packetCount++;
      if (_packetCount <= 8 || _packetCount % 25 == 0) {
        d(
          "Packet #$_packetCount | raw={$inhaleValue} | base=$_base | hold=$_holdActive done=$_holdDone inhaleFinished=${state.inhaleFinished}",
        );
      }

      if (_holdDone) return;

      // ---------------- HOLD PHASE ----------------
      if (_holdActive) {
        final delta = inhaleValue - _base;

        emit(state.copyWith(
          progressSigned: delta,
          progress: delta.abs(),
        ));

        final holdStart = _holdStartAt;
        if (holdStart == null) return;

        final elapsedHold = DateTime.now().difference(holdStart);

        if (elapsedHold < _holdStartCheckingAfter) return;

        if (inhaleValue > (_base + 1.5)) {
          emit(state.copyWith(holdBreathViolation: "Exhale detected during hold"));
          unawaited(setCancelOrDisconnectFlag());
          _finishFail("Exhale detected during hold");
          return;
        }

        if (inhaleValue < (_base - 1.5)) {
          emit(state.copyWith(holdBreathViolation: "Inhale detected during hold"));
          unawaited(setCancelOrDisconnectFlag());
          _finishFail("Inhale detected during hold");
          return;
        }

        return;
      }

      // ---------------- INHALE PHASE ----------------
      // ✅ UPDATED RULE (as you asked):
      // If value goes ABOVE base => exhaled => inhale must FAIL immediately.
      if (inhaleValue > _base + 1.5) {
        d("FAIL: Exhale detected during inhale | raw=$inhaleValue base=$_base");
        unawaited(setCancelOrDisconnectFlag());
        _finishFail("Exhale detected instead of inhale");
        return;
      }

      // (kept same, now basically not needed but no harm)
      _cancelExhaleFailTimer();

      final signed = Thresholds.calculateInhalePercentage(
        _base,
        inhaleValue,
        breathingSettings.inhale.threshold.toDouble(),
      );
      final inhaleProgress = signed < 0 ? (-signed) : 0.0;
      final bool startedNow = inhaleProgress >= _armAt;

      emit(state.copyWith(
        progressSigned: signed,
        progress: startedNow ? inhaleProgress : 0,
        inhaleStarted: startedNow ? true : state.inhaleStarted,
        inhaleFinished: state.inhaleFinished,
      ));

      if (!_armed && startedNow) {
        _armed = true;
        d("Inhale armed at ${inhaleProgress.toStringAsFixed(2)}");
      }

      if (_armed && !_dropFailTriggered && inhaleProgress <= _dropToZeroThreshold) {
        _dropFailTriggered = true;
        d("FAIL: dropped near zero");
        _finishFail("Inhale dropped to 0");
        return;
      }

      if (_armed && !state.inhaleFinished) {
        _applyBandRules(inhaleProgress);
      }
    });
  }

  // kept same
  void _startExhaleFailTimerIfNeeded() {
    if (_exhaleTimerRunning) return;
    _exhaleTimerRunning = true;

    _exhaleTimer?.cancel();
    _exhaleTimer = Timer(const Duration(milliseconds: 700), () {
      _exhaleTimerRunning = false;
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;
      _finishFail("Exhale detected instead of inhale");
    });
  }

  // kept same
  void _cancelExhaleFailTimer() {
    _exhaleTimer?.cancel();
    _exhaleTimer = null;
    _exhaleTimerRunning = false;
  }

  void startCounter({int from = 5}) {
    if (_disposed) return;

    d("startCounter(from=$from)");

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
      navigateToDashboard: false,
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
      holdStarted: false,
      holdFinished: false,
      holdSeconds: 0,
      progress: 0,
      progressSigned: 0,
      baseValueReceived: false,
      blowExhaleBaseValue: 0,
      holdBreathViolation: "",
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
    if (_disposed || _cancelled || _flowStopped || _startSent || !repo.isConnected) return;
    _startSent = true;
    d("SEND '1' start");
    send("1");
    _testStarted = true;
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
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;

      final now = DateTime.now();
      final last = _inhaleNeedLastTickAt ?? now;
      _inhaleNeedLastTickAt = now;

      _inhaleNeedAccumulated += now.difference(last);

      final seconds = (_inhaleNeedAccumulated.inMilliseconds / 1000.0)
          .clamp(0.0, _inhaleNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(inBandSeconds: seconds));

      if (_inhaleNeedAccumulated >= _inhaleAccept) {
        _finishInhaleSuccessStartHold();
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
      if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;
      _finishFail(reason);
    });
  }

  void _cancelOutOfBandFailTimer() {
    _outOfBandTimer?.cancel();
    _outOfBandTimer = null;
  }

  void _finishInhaleSuccessStartHold() {
    if (_disposed || _cancelled || _flowStopped || state.inhaleFinished) return;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: true,
      inhaleFailed: false,
      inhaleFailReason: "",
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs: nowMs,
      holdStarted: true,
      holdFinished: false,
      holdSeconds: 0,
    ));

    send("2");
    _startHoldTicker();
  }

  void _startHoldTicker() {
    _holdActive = true;
    _holdDone = false;
    _holdStartAt = DateTime.now();

    _holdTicker?.cancel();
    _holdTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed || _cancelled || _flowStopped) return;

      final start = _holdStartAt;
      if (start == null) return;

      final elapsed = DateTime.now().difference(start);
      final sec = (elapsed.inMilliseconds / 1000.0)
          .clamp(0.0, _holdNeed.inMilliseconds / 1000.0);

      emit(state.copyWith(holdSeconds: sec));

      if (elapsed >= _holdNeed) {
        _holdTicker?.cancel();
        _holdTicker = null;

        _holdActive = false;
        _holdDone = true;

        emit(state.copyWith(holdFinished: true));
      }
    });
  }

  void _finishFail(String reason) {
    if (_disposed || _cancelled || state.inhaleFailed) return;

    _flowStopped = true;
    _testStarted = false;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();
    _holdTicker = null;
    _holdActive = false;
    _holdDone = false;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: reason,
      inhaleNeedRunning: false,
      inhaleNeedTotalMillis: _inhaleNeed.inMilliseconds,
      inhaleNeedEndsAtEpochMs: (state.inhaleNeedStartsAtEpochMs == 0) ? 0 : nowMs,
      holdStarted: false,
      holdFinished: false,
    ));

    if (repo.isConnected) {
      send("&");
    }
  }

  void _resetAllTracking() {
    _armed = false;
    _everReachedBand = false;

    _inhaleNeedAccumulated = Duration.zero;
    _inhaleNeedLastTickAt = null;

    _dropFailTriggered = false;

    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();
    _holdTicker = null;

    _holdActive = false;
    _holdDone = false;
    _holdStartAt = null;

    _packetCount = 0;
  }

  void send(String command) {
    if (_disposed || _cancelled) return;
    try {
      repo.sendData(command);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> cancelTest() async {

    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    if (repo.isConnected) {
      try {
       if(!state.inhaleFailed) repo.sendData("&");
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    } else {
      d("CANCEL: skip '&' (not connected)");
    }


    if (_disposed) return;
    if (_cancelled) return;

    _cancelled = true;
    _flowStopped = true;
    _testStarted = false;

    d("CANCEL TEST called | canSaveTime=$_canSaveAbortTime");

    _finishTimer?.cancel();
    _secondTimer?.cancel();
    _finishTimer = null;
    _secondTimer = null;

    _pauseInhaleNeedTicker(setRunningFalse: true);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();
    _holdTicker = null;
    _holdActive = false;
    _holdDone = false;



    emit(state.copyWith(
      inhaleFinished: true,
      inhaleSuccess: false,
      inhaleFailed: true,
      inhaleFailReason: "Aborted by user.",
      navigateToDashboard: true,
    ));
  }

  Future<void> sendAbort() async {
    if (_disposed) return;

    if (_canSaveAbortTime) {
      await setCancelOrDisconnectFlag();
    }

    try {
      if (repo.isConnected) {
        d("SEND '&' (abort)");
        repo.sendData("&");
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> setCancelOrDisconnectFlag() async {
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

    _pauseInhaleNeedTicker(setRunningFalse: false);
    _cancelOutOfBandFailTimer();
    _cancelExhaleFailTimer();

    _holdTicker?.cancel();

    _connSub?.cancel();
    _dataSub?.cancel();
    return super.close();
  }
}
