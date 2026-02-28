// bottom_sheets/bloc/dietitian_link_bloc.dart

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'dietitian_link_event.dart';
import 'dietitian_link_state.dart';

class DietitianLinkBloc extends Bloc<DietitianLinkEvent, DietitianLinkState> {
  final DietitianRepository dietitianRepository;

  DietitianLinkBloc({DietitianRepository? dietitianRepository})
      : dietitianRepository = dietitianRepository ?? DietitianRepository(),
        super(DietitianLinkState.initial()) {
    on<FetchDietitianByCode>(_onFetchDietitianByCode);
    on<ConfirmDietitianLink>(_onConfirmDietitianLink);
    on<ResetDietitianLinkFlow>(_onResetFlow);
  }

  Future<void> _onResetFlow(
      ResetDietitianLinkFlow event,
      Emitter<DietitianLinkState> emit,
      ) async {
    emit(DietitianLinkState.initial());
  }

  Future<void> _onFetchDietitianByCode(
      FetchDietitianByCode event,
      Emitter<DietitianLinkState> emit,
      ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(state.copyWith(
        errorMessage: "Please enter reference code",
        successMessage: null,
        clearDietitian: true,
      ));
      return;
    }

    emit(state.copyWith(
      isLookupLoading: true,
      errorMessage: null,
      successMessage: null,
      clearDietitian: true,
    ));

    try {
      final dietitian = await dietitianRepository.fetchDietitian(code);

      if (dietitian == null) {
        emit(state.copyWith(
          isLookupLoading: false,
          errorMessage: "No dietitian found for this reference code.",
          successMessage: null,
          clearDietitian: true,
        ));
      } else {
        emit(state.copyWith(
          isLookupLoading: false,
          dietitian: dietitian,
          errorMessage: null,
          successMessage: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLookupLoading: false,
        errorMessage: "Failed to fetch dietitian: ${e.toString()}",
        successMessage: null,
        clearDietitian: true,
      ));
    }
  }

  Future<void> _onConfirmDietitianLink(
      ConfirmDietitianLink event,
      Emitter<DietitianLinkState> emit,
      ) async {
    emit(state.copyWith(
      isLinkLoading: true,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      final body = jsonEncode({
        "profile_id": event.profileId,
        "dietitian_id": event.dietitianId,
      });

      final resp = await http.post(
        Uri.parse(
          "https://humorstech.com/dietitian/api/app/insert_link_request.php",
        ),
        headers: const {
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (resp.statusCode != 200) {
        emit(state.copyWith(
          isLinkLoading: false,
          errorMessage: "HTTP ${resp.statusCode}: ${resp.body}",
          successMessage: null,
        ));
        return;
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) {
        emit(state.copyWith(
          isLinkLoading: false,
          errorMessage: "Invalid JSON response",
          successMessage: null,
        ));
        return;
      }

      final success = decoded["success"] == true;
      final msg = decoded["message"]?.toString() ?? "Unknown response";

      if (success) {
        emit(state.copyWith(
          isLinkLoading: false,
          errorMessage: null,
          successMessage: msg,
        ));
      } else {
        emit(state.copyWith(
          isLinkLoading: false,
          errorMessage: msg,
          successMessage: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLinkLoading: false,
        errorMessage: "Request failed: ${e.toString()}",
        successMessage: null,
      ));
    }
  }
}
