abstract class OtpEvent {}

class StartTimer extends OtpEvent {}

class TimerTicked extends OtpEvent {
  final int seconds;
  TimerTicked(this.seconds);
}

class OtpInputChanged extends OtpEvent {
  final String code;
  OtpInputChanged(this.code);
}

class ResendOtpRequested extends OtpEvent {
  final String email;
  ResendOtpRequested(this.email);
}

class VerifyOtpRequested extends OtpEvent {
  final String email;
  VerifyOtpRequested(this.email);
}