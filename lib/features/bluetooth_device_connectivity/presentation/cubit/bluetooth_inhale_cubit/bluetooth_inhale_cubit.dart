import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/processor/bluetooth_blow_processor.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothInhaleCubit extends Cubit<BluetoothInhaleState> {
  final BluetoothRepository repo;
  final AudioHelper audioHelper;
  final BluetoothBlowProcessor processor;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;

  Timer? _startTimer;
  Timer? _holdTimer;

  bool _isDispose = false;

  // ✅ stop everything once blownow received
  bool _sessionStopped = false;

  // inhale base (also used as exhale base value storage)
  bool _baseCaptured = false;
  double _base = 0;

  // perfect samples
  static const int _targetPerfect = 20;
  static const double _minProgressForPerfect = 80;
  static const double _minDeltaForPerfect = 1.0;

  int _perfectCount = 0;
  double _lastPerfect = -999;

  // HOLD improper blow counters
  int inHoldBlowCounter = 0; // counts consecutive BAD samples
  bool improperBlowCalled = false;

  // ✅ ignore first 5 curly packets during hold
  int _holdCurlyCount = 0;

  // command guards
  bool _inhaleStartSent = false;
  bool _inhaleStopSent = false;

  // ✅ after hold finished, we wait for blownow (base is already captured earlier in inhale)
  bool _waitingForExhaleBase = false;
  bool _blowNowReceived = false;

  // packet regex
  final RegExp _slashNum = RegExp(r'^\s*/\s*(\d+(?:\.\d+)?)\s*/\s*$');
  final RegExp _curlyNum = RegExp(r'^\s*\{\s*(\d+(?:\.\d+)?)\s*\}\s*$');

  BluetoothInhaleCubit(this.repo, this.audioHelper, this.processor)
      : super(const BluetoothInhaleState()) {
    init();
  }

  void init() {
    processor.reset();
    _connSub = repo.connectionStatusStream().listen(_handleConn);
    _dataSub = repo.receivedDataStream().listen(_onData);

    if (repo.isConnected) {
      _handleConn(true);
    }
  }

  // ---------------------------
  // ✅ START COUNTER (5..0)
  // ---------------------------
  void startStartCounter({int from = 5}) {
    if (_isDispose) return;

    _startTimer?.cancel();
    _holdTimer?.cancel();

    // reset session
    _sessionStopped = false;

    _inhaleStartSent = false;
    _inhaleStopSent = false;

    _baseCaptured = false;
    _base = 0;

    _perfectCount = 0;
    _lastPerfect = -999;

    _waitingForExhaleBase = false;
    _blowNowReceived = false;

    // ✅ RESET IMPROPER BLOW
    inHoldBlowCounter = 0;
    improperBlowCalled = false;
    _holdCurlyCount = 0;

    emit(state.copyWith(
      startCounter: from,
      startCountdownFrom: from,
      startCounterFinished: false,
      inhaleStarted: false,
      inhaleFinished: false,
      progress: 0,
      perfectSamples: 0,
      holdStarted: false,
      holdFinished: false,
      holdCounter: 0,
      blowExhaleBaseValue: "",
      navigateToExhaleScreen: false,
      improperBlow: false,
      isDialogShown: false,
    ));

    _startTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isDispose || _sessionStopped) {
        t.cancel();
        return;
      }

      final next = state.startCounter - 1;

      if (next <= 0) {
        t.cancel();
        emit(state.copyWith(startCounter: 0, startCounterFinished: true));
        _startInhaleCommand();
      } else {
        emit(state.copyWith(startCounter: next));
      }
    });
  }

  // ---------------------------
  // ✅ SEND "1" (inhale start)
  // ---------------------------
  void _startInhaleCommand() {
    if (_inhaleStartSent || _isDispose || _sessionStopped) return;
    _inhaleStartSent = true;

    sendData(command: "1");
    emit(state.copyWith(inhaleStarted: true));

    // reset inhale calculations
    _baseCaptured = false;
    _base = 0;
    _perfectCount = 0;
    _lastPerfect = -999;
    _inhaleStopSent = false;

    emit(state.copyWith(perfectSamples: 0, progress: 0));
  }

  // ---------------------------
  // ✅ SEND "2" (inhale stop) + start hold
  // ---------------------------
  void _stopInhaleAndStartHold() {
    if (_inhaleStopSent || _isDispose || _sessionStopped) return;
    _inhaleStopSent = true;

    sendData(command: "2");
    emit(state.copyWith(inhaleFinished: true));

    _startHoldCounter(from: 5);
  }

  // ---------------------------
  // ✅ HOLD COUNTER (5..0)
  // ---------------------------
  void _startHoldCounter({required int from}) {
    _holdTimer?.cancel();

    // ✅ reset hold packet counters at start of hold
    _holdCurlyCount = 0;
    inHoldBlowCounter = 0;

    emit(state.copyWith(
      holdStarted: true,
      holdFinished: false,
      holdCounter: from,
    ));

    int remaining = from;

    _holdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isDispose || _sessionStopped) {
        t.cancel();
        return;
      }

      remaining -= 1;
      emit(state.copyWith(holdCounter: remaining));

      if (remaining <= 0) {
        t.cancel();

        emit(state.copyWith(
          holdStarted: false,
          holdFinished: true,
          holdCounter: 0,
        ));

        // ✅ after hold done -> send exhale start ONLY if NOT improper
        if (!improperBlowCalled) {
          _waitingForExhaleBase = true;
          _blowNowReceived = false;
          sendData(command: "3");
        }
      }
    });
  }

  // ---------------------------
  // ✅ CONNECTION HANDLING
  // ---------------------------
  void _handleConn(bool connected) {
    if (_isDispose) return;

    emit(state.copyWith(isBluetoothConnected: connected));

    if (!connected) {
      _startTimer?.cancel();
      _holdTimer?.cancel();
      audioHelper.stopAudio();
      if (!state.isDialogShown) showDisconnectedDialog();
    }
  }

  // ---------------------------
  // ✅ DATA HANDLING
  // ---------------------------
  void _onData(String data) {
    if (_isDispose || data.isEmpty || _sessionStopped) return;

    final clean = data.trim();
    final normalized = clean.toLowerCase();

    final slashMatch = _slashNum.firstMatch(clean); // /919.43/
    final curlyMatch = _curlyNum.firstMatch(clean); // {931} or {919.25}

    // ✅ AFTER HOLD: wait ONLY for blownow
    if (_waitingForExhaleBase) {
      if (normalized.contains("blownow") &&
          !_blowNowReceived &&
          !state.improperBlow &&
          !improperBlowCalled) {
        _blowNowReceived = true;
        _sessionStopped = true;

        _startTimer?.cancel();
        _holdTimer?.cancel();

        emit(state.copyWith(navigateToExhaleScreen: true));
        stop();
        return;
      }

      // ignore all other packets while waiting for blownow
      return;
    }

    // ✅ IMPROPER BLOW CHECK DURING HOLD (inhale completed)
    if (_baseCaptured &&
        state.holdStarted &&
        !state.holdFinished &&
        state.inhaleFinished &&
        !_waitingForExhaleBase &&
        state.holdCounter > 0 &&
        curlyMatch != null) {
      _holdCurlyCount++;

      // ✅ ignore first 5 curly packets in hold
      if (_holdCurlyCount <= 5) return;

      final holdValue = double.parse(curlyMatch.group(1)!);

      const double allowedPlus = 1.0; // only +1 ok now

      final isBad = holdValue > (_base + allowedPlus);

      // ✅ count only consecutive bad packets
      if (isBad) {
        inHoldBlowCounter++;
      } else {
        inHoldBlowCounter = 0;
      }

      // ✅ trigger improper if 3 consecutive bad packets
      if (inHoldBlowCounter >= 3 && !improperBlowCalled) {
        improperBlowCalled = true;

        emit(state.copyWith(improperBlow: true));

        // stop hold timer (optional but safer)
        _holdTimer?.cancel();

        // show dialog if your UI uses isDialogShown for this
        showImproperDialog();
      }
    }

    // ✅ INHALE PHASE processing
    if (!state.inhaleStarted || state.holdFinished) return;

    // inhale base: /917.51/
    if (!_baseCaptured && slashMatch != null && !_blowNowReceived) {
      _base = double.parse(slashMatch.group(1)!);
      _baseCaptured = true;

      emit(state.copyWith(blowExhaleBaseValue: clean));
      return;
    }

    // inhale values: {931} or {919.25}
    if (_baseCaptured && curlyMatch != null && !_blowNowReceived) {
      final inhaleValue = double.parse(curlyMatch.group(1)!);

      final raw = Thresholds.calculateInhalePercentage(_base, inhaleValue, 6.0);

      // keep your original logic
      if (raw > 0) return;

      final p = raw.abs().clamp(0.0, 100.0);

      emit(state.copyWith(progress: p));

      if (p > _minProgressForPerfect) {
        _perfectCount++;
        _lastPerfect = p;

        emit(state.copyWith(perfectSamples: _perfectCount));

        if (_perfectCount >= _targetPerfect) {
          _stopInhaleAndStartHold();
        }
      }
    }
  }

  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    await prefs.setString('cancel_or_disconnect_time', now.toIso8601String());
  }

  // ---------------------------
  // ✅ PUBLIC METHODS
  // ---------------------------
  void sendData({required String command}) => repo.sendData(command);

  void sendAbort() => repo.sendData("&");

  void showDisconnectedDialog() => emit(state.copyWith(isDialogShown: true));

  void showImproperDialog() => emit(state.copyWith(isDialogShown: true));

  void dialogDismissed() => emit(state.copyWith(isDialogShown: false));

  // ---------------------------
  // ✅ STOP
  // ---------------------------
  void stop() {
    _isDispose = true;
    _sessionStopped = true;

    _connSub?.cancel();
    _dataSub?.cancel();
    _startTimer?.cancel();
    _holdTimer?.cancel();
    audioHelper.stopAudio();
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
