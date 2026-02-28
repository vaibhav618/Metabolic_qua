import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/bloc/score_trend_event.dart';
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/bloc/score_trend_state.dart';
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/data/repository/score_trend_repository.dart';

class ScoreTrendBloc extends Bloc<ScoreTrendEvent, ScoreTrendState> {
  final ScoreTrendRepository repository;

  ScoreTrendBloc(this.repository) : super(ScoreTrendInitial()) {
    on<FetchMetabolismData>(_onFetchMetabolismData);
  }

  void _onFetchMetabolismData(
      FetchMetabolismData event,
      Emitter<ScoreTrendState> emit,
      ) async {
    // Emit loading state before fetching
    emit(ScoreTrendLoading());
    try {
      final scores = await repository.fetchScores(event.profileId);

      if (scores.isEmpty) {
        // Emit NoTestDataFound state if no data is found
        emit(NoTestDataFound("No data found for this Profile ID."));
      } else {
        // Emit loaded state with the fetched data
        emit(ScoreTrendLoaded(scores));
      }
    } catch (e) {
      // Emit error state if fetching fails
      emit(ScoreTrendError(e.toString()));
    }
  }
}
