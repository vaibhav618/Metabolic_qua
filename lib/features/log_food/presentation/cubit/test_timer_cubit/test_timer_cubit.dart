import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_state.dart';

class TestTimerCubit extends Cubit<TestTimerState> {
  Timer? _timer;
  TestTimerCubit() : super(TestTimerInitial());
  void startTest() {
    emit(TestTimerInProgress(const Duration(minutes: 5)));

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is TestTimerInProgress) {
        final newTime = currentState.remainingTime - Duration(seconds: 1);

        if (newTime.inSeconds <= 0) {
          _timer?.cancel();
          emit(TestTimerExpired());
        } else {
          emit(TestTimerInProgress(newTime));
        }
      }
    });
  }

  void completeTest() {
    _timer?.cancel();
    emit(TestTimerCompleted());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
