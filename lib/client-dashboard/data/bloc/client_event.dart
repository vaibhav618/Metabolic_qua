import 'package:equatable/equatable.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object> get props => [];
}

class FetchClientProfile extends ClientEvent {
  final String profileId;

  const FetchClientProfile({required this.profileId});

  @override
  List<Object> get props => [profileId];
}


class UpdateNotificationEvent extends ClientEvent {
  final String profileId;
  final bool isEnabled;
  UpdateNotificationEvent({required this.profileId, required this.isEnabled});
}