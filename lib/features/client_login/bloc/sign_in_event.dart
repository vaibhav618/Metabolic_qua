abstract class SignInEvent {}

class EmailChanged extends SignInEvent {
  final String email;
  EmailChanged(this.email);
}

class DomainSelected extends SignInEvent {
  final String domain;
  DomainSelected(this.domain);
}

class ValidateAndSendOtp extends SignInEvent {
  ValidateAndSendOtp();
}