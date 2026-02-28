import 'package:equatable/equatable.dart';
import '../model/client_profile_model.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object> get props => [];
}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final ClientProfileModel client;
  const ClientLoaded(this.client);

  @override
  List<Object> get props => [client];
}

class ClientError extends ClientState {
  final String message;
  const ClientError(this.message);

  @override
  List<Object> get props => [message];
}


class ClientNotificationUpdateSuccess extends ClientState {
  final bool isEnabled;
  const ClientNotificationUpdateSuccess(this.isEnabled);
}

class ClientNotificationUpdateFailure extends ClientState {
  final String error;
  const ClientNotificationUpdateFailure(this.error);
}