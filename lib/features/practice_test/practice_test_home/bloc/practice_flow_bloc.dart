import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../domain/enums/practice_test.dart';

enum PracticeStepStatus { locked, available, completed }

class PracticeFlowState extends Equatable {
  final Map<PracticeTestSteps, PracticeStepStatus> status;

  final bool isConnected;
  final String lastRx;
  final String? bleError;

  const PracticeFlowState({
    required this.status,
    this.isConnected = false,
    this.lastRx = "",
    this.bleError,
  });

  bool get allCompleted =>
      status.values.every((s) => s == PracticeStepStatus.completed);

  PracticeStepStatus stepStatus(PracticeTestSteps step) =>
      status[step] ?? PracticeStepStatus.locked;

  bool isCompleted(PracticeTestSteps step) =>
      stepStatus(step) == PracticeStepStatus.completed;

  bool isEnabled(PracticeTestSteps step) {
    final s = stepStatus(step);
    return s == PracticeStepStatus.available || s == PracticeStepStatus.completed;
  }

  PracticeFlowState copyWith({
    Map<PracticeTestSteps, PracticeStepStatus>? status,
    bool? isConnected,
    String? lastRx,
    String? bleError,
  }) {
    return PracticeFlowState(
      status: status ?? this.status,
      isConnected: isConnected ?? this.isConnected,
      lastRx: lastRx ?? this.lastRx,
      bleError: bleError,
    );
  }

  @override
  List<Object?> get props => [status, isConnected, lastRx, bleError];
}

abstract class PracticeFlowEvent extends Equatable {
  const PracticeFlowEvent();
  @override
  List<Object?> get props => [];
}

class PracticeFlowInit extends PracticeFlowEvent {
  const PracticeFlowInit();
}

class PracticeFlowMarkCompleted extends PracticeFlowEvent {
  final PracticeTestSteps step;
  const PracticeFlowMarkCompleted(this.step);

  @override
  List<Object?> get props => [step];
}

class PracticeFlowReset extends PracticeFlowEvent {
  const PracticeFlowReset();
}

class _BleConnectedChanged extends PracticeFlowEvent {
  final bool connected;
  const _BleConnectedChanged(this.connected);

  @override
  List<Object?> get props => [connected];
}

class _BleDataReceived extends PracticeFlowEvent {
  final String data;
  const _BleDataReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class _BleError extends PracticeFlowEvent {
  final String message;
  const _BleError(this.message);

  @override
  List<Object?> get props => [message];
}

class PracticeFlowBloc extends Bloc<PracticeFlowEvent, PracticeFlowState> {
  final BluetoothRepository repo;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<String>? _rxSub;

  PracticeFlowBloc({required this.repo}) : super(_initialState()) {
    on<PracticeFlowInit>((event, emit) {
      emit(_recomputeLocks(state));
      _bindBle();
      emit(state.copyWith(isConnected: repo.isConnected, bleError: null));
    });

    on<PracticeFlowMarkCompleted>((event, emit) {
      final next = Map<PracticeTestSteps, PracticeStepStatus>.from(state.status);
      next[event.step] = PracticeStepStatus.completed;
      emit(_recomputeLocks(state.copyWith(status: next)));
    });

    on<PracticeFlowReset>((event, emit) {
      emit(_initialState().copyWith(isConnected: repo.isConnected));
    });

    on<_BleConnectedChanged>((event, emit) {
      var nextState = state.copyWith(isConnected: event.connected, bleError: null);

      if (event.connected) {
        final next = Map<PracticeTestSteps, PracticeStepStatus>.from(nextState.status);
        next[PracticeTestSteps.connect] = PracticeStepStatus.completed;
        nextState = _recomputeLocks(nextState.copyWith(status: next));
      }

      emit(nextState);
    });

    on<_BleDataReceived>((event, emit) {
      emit(state.copyWith(lastRx: event.data, bleError: null));
    });

    on<_BleError>((event, emit) {
      emit(state.copyWith(bleError: event.message));
    });

    add(const PracticeFlowInit());
  }

  static PracticeFlowState _initialState() {
    return const PracticeFlowState(
      status: {
        PracticeTestSteps.connect: PracticeStepStatus.available,
        PracticeTestSteps.inhaleTest: PracticeStepStatus.locked,
        PracticeTestSteps.exhaleTest: PracticeStepStatus.locked,
        PracticeTestSteps.fullTest: PracticeStepStatus.locked,
      },
      isConnected: false,
      lastRx: "",
      bleError: null,
    );
  }

  void _bindBle() {
    _connSub?.cancel();
    _rxSub?.cancel();

    _connSub = repo.connectionStatusStream().listen(
          (connected) => add(_BleConnectedChanged(connected)),
      onError: (e) => add(_BleError(e.toString())),
    );

    _rxSub = repo.receivedDataStream().listen(
          (data) {
        final clean = data.trim();
        if (clean.isEmpty) return;
        add(_BleDataReceived(clean));
      },
      onError: (e) => add(_BleError(e.toString())),
    );
  }

  void send(String command) {
    try {
      repo.sendData(command);
    } catch (e) {
      add(_BleError(e.toString()));
    }
  }

  PracticeFlowState _recomputeLocks(PracticeFlowState input) {
    final s = Map<PracticeTestSteps, PracticeStepStatus>.from(input.status);

    final connectDone = s[PracticeTestSteps.connect] == PracticeStepStatus.completed;
    final inhaleDone = s[PracticeTestSteps.inhaleTest] == PracticeStepStatus.completed;
    final exhaleDone = s[PracticeTestSteps.exhaleTest] == PracticeStepStatus.completed;

    if (!connectDone) {
      s[PracticeTestSteps.connect] = PracticeStepStatus.available;

      if (s[PracticeTestSteps.inhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.inhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return input.copyWith(status: s);
    }

    if (!inhaleDone) {
      if (s[PracticeTestSteps.inhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.inhaleTest] = PracticeStepStatus.available;
      }
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.locked;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return input.copyWith(status: s);
    }

    if (!exhaleDone) {
      if (s[PracticeTestSteps.exhaleTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.exhaleTest] = PracticeStepStatus.available;
      }
      if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
        s[PracticeTestSteps.fullTest] = PracticeStepStatus.locked;
      }
      return input.copyWith(status: s);
    }

    if (s[PracticeTestSteps.fullTest] != PracticeStepStatus.completed) {
      s[PracticeTestSteps.fullTest] = PracticeStepStatus.available;
    }

    return input.copyWith(status: s);
  }

  @override
  Future<void> close() async {
    await _connSub?.cancel();
    await _rxSub?.cancel();
    return super.close();
  }
}