import 'package:equatable/equatable.dart';

class OtpState extends Equatable {
  final String otp;
  final bool isLoading;
  final bool isVerified;
  final int resendSeconds;
  final String error;

  const OtpState({
    this.otp = '',
    this.isLoading = false,
    this.isVerified = false,
    this.resendSeconds = 0,
    this.error = '',
  });

  OtpState copyWith({
    String? otp,
    bool? isLoading,
    bool? isVerified,
    int? resendSeconds,
    String? error,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      isVerified: isVerified ?? this.isVerified,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [otp, isLoading, isVerified, resendSeconds, error];
}
