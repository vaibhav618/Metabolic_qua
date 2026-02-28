abstract class TestTimerState {}

class TestTimerInitial extends TestTimerState {}

class TestTimerInProgress extends TestTimerState {
  final Duration remainingTime;
  TestTimerInProgress(this.remainingTime);
}

class TestTimerCompleted extends TestTimerState {}

class TestTimerExpired extends TestTimerState {}
