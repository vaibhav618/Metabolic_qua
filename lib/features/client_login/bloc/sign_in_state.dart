class SignInState {
  final String email;
  final List<String> filteredDomains;
  final String? errorText;
  final bool isOtpSending;
  final bool isSuccess;
  final int? otp;

  SignInState({
    this.email = '',
    this.filteredDomains = const [],
    this.errorText,
    this.isOtpSending = false,
    this.isSuccess = false,
    this.otp,
  });

  SignInState copyWith({
    String? email,
    List<String>? filteredDomains,
    String? errorText,
    bool? isOtpSending,
    bool? isSuccess,
    int? otp,
  }) {
    return SignInState(
      email: email ?? this.email,
      filteredDomains: filteredDomains ?? this.filteredDomains,
      errorText: errorText, // Allow setting to null
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isSuccess: isSuccess ?? this.isSuccess,
      otp: otp ?? this.otp,
    );
  }
}