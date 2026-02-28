import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/menu/services/notification_service.dart';
import '../repository/client_repository.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository repository;

  ClientBloc(this.repository) : super(ClientInitial()) {
    // Fetch a single client profile by profileId
    on<FetchClientProfile>((event, emit) async {
      emit(ClientLoading());
      try {
        final clients = await repository.fetchClients(event.profileId);

        if (clients.isNotEmpty) {
          emit(ClientLoaded(clients.first));
        } else {
          emit(ClientError("No profile found"));
        }
      } catch (e) {
        emit(ClientError(e.toString()));
      }
    });

    // Update notification setting for a profile
    on<UpdateNotificationEvent>((event, emit) async {
      try {
        final success = await NotificationService().updateNotification(
          profileId: event.profileId,
          isEnabled: event.isEnabled,
        );

        if (success) {
          // Notify UI about success (you’re already doing optimistic UI in the widget)
          emit(ClientNotificationUpdateSuccess(event.isEnabled));
        } else {
          emit(ClientNotificationUpdateFailure("Failed to update notification"));
        }
      } catch (e) {
        emit(ClientNotificationUpdateFailure(e.toString()));
      }
    });
  }
}
