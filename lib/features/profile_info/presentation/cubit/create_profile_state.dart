import 'package:equatable/equatable.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';

abstract class CreateProfileState extends Equatable {
  const CreateProfileState();
  @override
  List<Object?> get props => [];
}

class CreateProfileInitial extends CreateProfileState {
  const CreateProfileInitial();
}

class CreateProfileLoading extends CreateProfileState {
  const CreateProfileLoading();
}

class CreateProfileSuccess extends CreateProfileState {
  final ClientProfileModel profile;
  final String message;
  const CreateProfileSuccess({
    required this.profile,
    this.message = 'Client created successfully',
  });

  @override
  List<Object?> get props => [profile, message];
}

class CreateProfileFailure extends CreateProfileState {
  final String error;
  final int? statusCode; // optional: HTTP code if available
  const CreateProfileFailure(this.error, {this.statusCode});

  @override
  List<Object?> get props => [error, statusCode];
}
