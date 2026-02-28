import 'package:flutter_bloc/flutter_bloc.dart';
// ⬅️ Import the repository

import '../../repository/client_profile_repository.dart';
import 'check_client_event.dart';
import 'check_client_state.dart';

class CheckClientBloc extends Bloc<CheckClientEvent, CheckClientState> {
  final ClientProfileRepository repository;

  CheckClientBloc(this.repository) : super(CheckClientInitial()) {
    on<CheckClientProfileEvent>((event, emit) async {
      emit(CheckClientLoading());
      try {
        final profile = await repository.checkClientProfile(
          phoneNo: event.phoneNo,
          email: event.email,
        );
        emit(CheckClientSuccess(profile));
      } catch (e) {
        emit(CheckClientFailure(e.toString()));
      }
    });
  }
}
