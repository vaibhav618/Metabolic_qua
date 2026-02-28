import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_gate_state.dart';

class BluetoothGateCubit extends Cubit<BluetoothGateState> {
  StreamSubscription<BluetoothAdapterState>? _sub;
  BluetoothAdapterState _btState = BluetoothAdapterState.unknown;

  BluetoothGateCubit() : super(const BluetoothGateState()) {
    _sub = FlutterBluePlus.adapterState.listen((s) {
      _btState = s;
      if (_btState == BluetoothAdapterState.on) {
        if (state.dialog != BluetoothGateDialogType.none || state.isChecking) {
          emit(state.copyWith(
            isChecking: false,
            dialog: BluetoothGateDialogType.none,
            shouldNavigateNext: true,
          ));
        }
      }
    });

    FlutterBluePlus.adapterState.first.then((s) => _btState = s);
  }

  bool get isBluetoothOn => _btState == BluetoothAdapterState.on;

  Future<void> onOkPressed() async {
    if (state.isChecking) return;
    emit(state.copyWith(isChecking: true, shouldNavigateNext: false));

    try {
      final s = await FlutterBluePlus.adapterState.first;
      _btState = s;

      if (_btState == BluetoothAdapterState.on) {
        emit(state.copyWith(isChecking: false, shouldNavigateNext: true));
        return;
      }

      if (Platform.isAndroid) {
        emit(state.copyWith(isChecking: false, dialog: BluetoothGateDialogType.androidTurnOn));
      } else {
        emit(state.copyWith(isChecking: false, dialog: BluetoothGateDialogType.iosWait));
      }
    } catch (_) {
      emit(state.copyWith(isChecking: false));
    }
  }

  Future<void> recheckIfOn() async {
    try {
      final s = await FlutterBluePlus.adapterState.first;
      _btState = s;

      if (_btState == BluetoothAdapterState.on) {
        emit(state.copyWith(
          dialog: BluetoothGateDialogType.none,
          shouldNavigateNext: true,
        ));
      }
    } catch (_) {}
  }

  Future<void> requestTurnOnAndroid() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {}
  }

  void resetNavigationFlag() {
    if (state.shouldNavigateNext) {
      emit(state.copyWith(shouldNavigateNext: false));
    }
  }

  void closeDialog() {
    if (state.dialog != BluetoothGateDialogType.none) {
      emit(state.copyWith(dialog: BluetoothGateDialogType.none));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
