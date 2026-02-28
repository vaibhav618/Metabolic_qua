// lib/features/metabolism_test/bloc/test_data_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'test_data_event.dart';
import 'test_data_state.dart';
import '../data/repositories/test_data_repository.dart';

class TestDataBloc extends Bloc<TestDataEvent, TestDataState> {
  final TestDataRepository repo;

  TestDataBloc({required this.repo}) : super(TestDataInitial()) {
    on<FetchTestData>(_onFetch);
  }

  Future<void> _onFetch(FetchTestData event, Emitter<TestDataState> emit) async {
    emit(TestDataLoading());
    try {
      final records = await repo.getForProfileOnDate(
        profileId: event.profileId,
        date: event.date,
      );
      if (records.isEmpty) {
        emit(TestDataEmpty());
      } else {
        emit(TestDataLoaded(records));
      }
    } catch (e) {
      emit(TestDataError(e.toString()));
    }
  }
}
