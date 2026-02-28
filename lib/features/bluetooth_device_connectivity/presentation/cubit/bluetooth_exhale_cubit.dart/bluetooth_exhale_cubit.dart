import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/processor/bluetooth_blow_processor.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/common/widgets/threshold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_exhale_state.dart';

class BluetoothExhaleCubit extends Cubit<BluetoothExhaleState> {
  final BluetoothBlowProcessor processor;
  final BluetoothRepository repo;
  final AudioHelper audioHelper;
  final String baseValue;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _dataSub;
  Timer? _countdownTimer;

  bool _isDisposed = false;

  BluetoothExhaleCubit({
    required this.processor,
    required this.repo,
    required this.baseValue,
    required this.audioHelper,
  }) : super(const BluetoothExhaleState()) {
    init();
  }

  void init() {
    processor.reset();
    processor.processBlowData(
      baseValue,
      (val) => Thresholds.calculateThresholdPercentage(val),
      (baseVal, blowVal) =>
          Thresholds.calculateBlowPercentage(baseVal, blowVal),
    );

    _connSub = repo.connectionStatusStream().listen(_handleBluetoothConnection);
    _dataSub = repo.receivedDataStream().listen(_onBluetoothDataReceived);

    if (repo.isConnected) _handleBluetoothConnection(true);
  }

  void _handleBluetoothConnection(bool connected) {
    if (_isDisposed) return;

    emit(state.copyWith(isConnected: connected));

    if (connected) {
      print("✅ Bluetooth Connected");

      _startCountdown();
    } else {
      print("❌ Bluetooth Disconnected");
      _countdownTimer?.cancel();
      audioHelper.stopAudio();
      if (state.activeDialog == ActiveDialog.none) {
        emit(state.copyWith(activeDialog: ActiveDialog.disconnect));
      }
    }
  }

  Future<void> setCancelOrDisconnectFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    await prefs.setString('cancel_or_disconnect_time', now.toIso8601String());
  }

  void sendAbort() {
    repo.sendData("&");
  }

  void dialogDismissed() {
    emit(
      state.copyWith(
        activeDialog: ActiveDialog.none,
        exhaleSessionTimeout: false,
        exhaleImproper: false,
      ),
    );
  }

  void _onBluetoothDataReceived(String data) {
    if (_isDisposed || data.isEmpty) return;

    if (state.exhaleSessionTimeout) {
      return;
    }

    processor.processBlowData(
      data,
      (val) => Thresholds.calculateThresholdPercentage(val),
      (baseVal, blowVal) =>
          Thresholds.calculateBlowPercentage(baseVal, blowVal),
    );

    if (processor.isAbort && state.activeDialog == ActiveDialog.none) {
      emit(
        state.copyWith(
          exhaleImproper: processor.isImproperBlow,
          exhaleComplete: processor.isBlowComplete,
          activeDialog: ActiveDialog.improper,
        ),
      );
      stop();
      return;
    }

    final progress = processor.blowP;

    if(progress! <= 10){
      emit(
        state.copyWith(
          progress: 0,
          thresholdPercentage: processor.thresholdPercentage,
        ),
      );
    }
    emit(
      state.copyWith(
        progress: progress,
        thresholdPercentage: processor.thresholdPercentage,
      ),
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    int seconds = state.secondsRemaining;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || state.exhaleComplete) {
        timer.cancel();
        return;
      }

      if (seconds > 0) {
        seconds--;
        emit(state.copyWith(secondsRemaining: seconds));
      } else {
        if (state.activeDialog == ActiveDialog.none) {
          emit(
            state.copyWith(
              exhaleSessionTimeout: true,
              activeDialog: ActiveDialog.timeout,
            ),
          );
          repo.sendData("&");
        }
        timer.cancel();
      }
    });
  }

  void abortBlow() {
    repo.sendData("&");
  }

  void stop() {
    _isDisposed = true;
    _connSub?.cancel();
    _dataSub?.cancel();
    _countdownTimer?.cancel();
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
