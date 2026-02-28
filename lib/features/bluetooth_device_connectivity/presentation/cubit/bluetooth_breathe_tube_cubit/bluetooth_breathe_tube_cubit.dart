import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothBreatheTubeCubit extends Cubit<BluetoothBreatheTubeState> {
  final BluetoothRepository repo;
  final AudioHelper audioHelper;

  StreamSubscription<bool>? connSub;
  Timer? _progressTimer;

  BluetoothBreatheTubeCubit(this.repo, this.audioHelper)
    : super(const BluetoothBreatheTubeState()) {
    init();
  }

  // ----------------- INIT -----------------
  void init() {
    connSub = repo.connectionStatusStream().listen((connected) {
      print("📡 Bluetooth Breathe Tube connection: $connected");
      if (state.isCompleted) return;
      emit(state.copyWith(isBluetoothConnected: connected));

      if (connected) {
        if (!_isProgressRunning && state.progress < 1.0) {
          _startProgress();
        }
      } else {
        _pauseProgress();
        _showDisconnectedDialog();
      }
    });

    final initiallyConnected = repo.isConnected;
    emit(state.copyWith(isBluetoothConnected: initiallyConnected));

    if (initiallyConnected && !_isProgressRunning) {
      _startProgress();
    }
  }

  bool get _isProgressRunning => _progressTimer?.isActive ?? false;

  // ----------------- PROGRESS -----------------
  void _startProgress() {
    const durationMs = 5000;
    const stepMs = 50;
    const steps = durationMs ~/ stepMs;
    const increment = 1.0 / steps;

    audioHelper.playPlaceBreatheTube();
    _progressTimer?.cancel();

    _progressTimer = Timer.periodic(const Duration(milliseconds: stepMs), (
      timer,
    ) {
      if (!state.isBluetoothConnected) {
        timer.cancel();
        audioHelper.stopAudio();
        return;
      }

      final next = (state.progress + increment).clamp(0.0, 1.0);
      emit(state.copyWith(progress: next));

      if (next >= 1.0) {
        timer.cancel();
        audioHelper.stopAudio();
        emit(state.copyWith(isCompleted: true));
      }
    });
  }

  void _pauseProgress() {
    _progressTimer?.cancel();
    audioHelper.stopAudio();
  }

  // ----------------- DIALOGS -----------------
  void _showDisconnectedDialog() {
    if (!state.isDialogShown) {
      emit(state.copyWith(isDialogShown: true));
    }
  }

  /// Called when any dialog (disconnect or cancel) is closed.
  void dialogDismissed() {
    emit(state.copyWith(isDialogShown: false));
    audioHelper.stopAudio();
  }

  // ----------------- INTERNET HANDLER -----------------
  void handleInternetChanged(bool hasInternet) {
    emit(state.copyWith(hasInternet: hasInternet));

    if (!hasInternet) {
      _pauseProgress();
    } else if (state.isBluetoothConnected &&
        !_isProgressRunning &&
        state.progress < 1.0) {
      _startProgress();
    }
  }

  // ----------------- CONNECTION -----------------
  Future<void> connectById(String id) async {
    try {
      await repo.connectById(id);
    } catch (e) {
      print("❌ connectById failed: $e");
      _showDisconnectedDialog();
    }
  }

  void abortProcess() {
    if (state.isBluetoothConnected) repo.sendData("&");
  }

  Future<void> disconnect() async {
    try {
      await repo.disconnect();
    } catch (e) {
      print("⚠️ disconnect failed: $e");
    } finally {
      _pauseProgress();
      emit(state.copyWith(isBluetoothConnected: false));
    }
  }

  // // ----------------- CLEANUP -----------------
  @override
  Future<void> close() {
    _pauseProgress();
    connSub?.cancel();
    return super.close();
  }
}
