import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/metabolism_score_repository.dart';
import 'metabolism_event.dart';

class MetabolismBloc extends Bloc<MetabolismEvent, MetabolismState> {
  final MetabolismRepository repository;

  MetabolismBloc(this.repository) : super(MetabolismInitial()) {
    on<FetchMetabolismData>((event, emit) async {
      emit(MetabolismLoading());
      try {
        final scores = await repository.fetchScores(event.dietitianId, event.profileId);
        emit(MetabolismLoaded(scores));
      } catch (e) {
        emit(MetabolismError(e.toString()));
      }
    });
  }
}