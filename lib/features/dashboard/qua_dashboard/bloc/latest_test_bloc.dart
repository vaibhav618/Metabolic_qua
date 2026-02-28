import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/latest_test_repository.dart';
import 'latest_test_event.dart';
import 'latest_test_state.dart';


class LatestTestBloc extends Bloc<LatestTestEvent, LatestTestState> {
  final LatestTestRepository repo;

  LatestTestBloc({required this.repo}) : super(LatestTestInitial()) {
    on<FetchLatestTest>((event, emit) async {
      emit(LatestTestLoading());
      try {
        final data = await repo.fetchLatestTest(
          dietitianId: event.dietitianId,
          profileId: event.profileId,
          date: event.date,
        );
        emit(LatestTestLoaded(data)); // data may be null
      } catch (e) {
        emit(LatestTestError(e.toString()));
      }
    });
  }
}
