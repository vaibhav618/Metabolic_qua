class OtpState {
  final int? receivedOtp;
  final int? enteredOtp;
  final int secondsRemaining;
  final bool canResend;
  final bool isResending;
  final bool isVerifying;
  final String? errorText;
  final bool isSuccess;
  final dynamic profile;

  const OtpState({
    this.receivedOtp,
    this.enteredOtp,
    this.secondsRemaining = 60,
    this.canResend = false,
    this.isResending = false,
    this.isVerifying = false,
    this.errorText,
    this.isSuccess = false,
    this.profile,
  });

  OtpState copyWith({
    int? receivedOtp,
    int? enteredOtp,
    int? secondsRemaining,
    bool? canResend,
    bool? isResending,
    bool? isVerifying,
    String? errorText,
    bool? isSuccess,
    dynamic profile,
  }) {
    return OtpState(
      receivedOtp: receivedOtp ?? this.receivedOtp,
      enteredOtp: enteredOtp ?? this.enteredOtp,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      canResend: canResend ?? this.canResend,
      isResending: isResending ?? this.isResending,
      isVerifying: isVerifying ?? this.isVerifying,
      errorText: errorText,
      isSuccess: isSuccess ?? this.isSuccess,
      profile: profile ?? this.profile,
    );
  }
}
