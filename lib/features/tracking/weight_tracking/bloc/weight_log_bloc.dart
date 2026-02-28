// lib/features/tracking/weight_tracking/presentation/bloc/weight_log_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/weight_log_repository.dart';
import 'weight_log_event.dart';
import 'weight_log_state.dart';

class WeightLogBloc extends Bloc<WeightLogEvent, WeightLogState> {
  final WeightLogRepository repository;

  WeightLogBloc({required this.repository}) : super(WeightLogInitial()) {
    on<LoadWeightLogs>(_onLoadWeightLogs);
    on<DeleteWeightLog>(_onDeleteWeightLog);
  }

  Future<void> _onLoadWeightLogs(
      LoadWeightLogs event,
      Emitter<WeightLogState> emit,
      ) async {
    emit(WeightLogLoading());

    try {
      final logs = await repository.fetchWeightLogs(event.profileId);
      emit(WeightLogLoaded(logs));
    } catch (e) {
      emit(WeightLogError(e.toString()));
    }
  }

  Future<void> _onDeleteWeightLog(
      DeleteWeightLog event,
      Emitter<WeightLogState> emit,
      ) async {
    emit(WeightLogDeleting());

    try {
      // Call delete API in repository (you need to implement this)
      await repository.deleteWeightLog(
        id: event.id,
        profileId: event.profileId,
      );


      emit(const WeightLogDeleted("Weight log deleted successfully"));

      // Refresh the list after delete
      final logs = await repository.fetchWeightLogs(event.profileId);
      emit(WeightLogLoaded(logs));
    } catch (e) {
      emit(WeightLogDeleteError(e.toString()));
    }
  }
}
