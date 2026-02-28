import 'package:equatable/equatable.dart';

class AccountSettingState extends Equatable {
  final String name;
  final String mobileNumber;
  final String email;
  final bool isLoading;

  const AccountSettingState({
    required this.email,
    required this.name,
    required this.mobileNumber,
    this.isLoading = false,
  });

  AccountSettingState copyWith({
    String? name,
    String? mobileNumber,
    String? email,
    bool? isLoading,
  }) {
    return AccountSettingState(
      email: email ?? this.email,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [name, email, mobileNumber, isLoading];
}
