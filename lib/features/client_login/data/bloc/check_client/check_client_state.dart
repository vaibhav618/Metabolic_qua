



import '../../../../../client-dashboard/data/model/client_profile_model.dart';

abstract class CheckClientState {}

class CheckClientInitial extends CheckClientState {}

class CheckClientLoading extends CheckClientState {}

class CheckClientSuccess extends CheckClientState {
  final ClientProfileModel profile;

  CheckClientSuccess(this.profile);
}

class CheckClientFailure extends CheckClientState {
  final String message;

  CheckClientFailure(this.message);
}
