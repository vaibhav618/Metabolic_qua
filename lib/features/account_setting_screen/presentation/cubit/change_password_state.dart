import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  final String newPassword;
  final String confirmPassword;
  final bool isSuccess;
  final bool passwordMatch;
  final bool showErrors;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool hasMinLength;
  final bool submittedSuccessfully;

  const ChangePasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.isSuccess = false,
    this.passwordMatch = true,
    this.showErrors = false,
    this.hasUppercase = false,
    this.hasNumber = false,
    this.hasSpecialChar = false,
    this.hasMinLength = false,
    this.submittedSuccessfully = false,
  });

  ChangePasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? isSuccess,
    bool? passwordMatch,
    bool? showErrors,
    bool? hasUppercase,
    bool? hasNumber,
    bool? hasSpecialChar,
    bool? hasMinLength,
    bool? submittedSuccessfully,
  }) {
    return ChangePasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSuccess: isSuccess ?? this.isSuccess,
      passwordMatch: passwordMatch ?? this.passwordMatch,
      showErrors: showErrors ?? this.showErrors,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasNumber: hasNumber ?? this.hasNumber,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      submittedSuccessfully:
          submittedSuccessfully ?? this.submittedSuccessfully,
    );
  }

  @override
  List<Object?> get props => [
    newPassword,
    confirmPassword,
    isSuccess,
    passwordMatch,
    showErrors,
    hasUppercase,
    hasNumber,
    hasSpecialChar,
    hasMinLength,
    submittedSuccessfully,
  ];
}
