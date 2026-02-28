import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_event.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_repository.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_state.dart';

class TodayTestDataBloc extends Bloc<TodayTestDataEvent, TestDataState> {
  final TodayTestDataRepository repo;

  String? _dietitianId;
  String? _lastProfileId;
  DateTime? _lastDate;

  TodayTestDataBloc(this.repo) : super(const TestDataState()) {
    on<LoadTestDataForDay>(_onLoad);
    on<RefreshTestData>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadTestDataForDay event,
      Emitter<TestDataState> emit,
      ) async {
    emit(state.copyWith(
      status: TestDataStatus.loading,
      errorMessage: null,
    ));

    try {
      _lastProfileId = event.profileId;
      _dietitianId = event.dietitianId;
      _lastDate = event.date;

      final result = await repo.fetchDay(
        profileId: event.profileId,
        dietitianId: event.dietitianId,
        date: event.date,
      );

      if (result == null) {
        emit(state.copyWith(
          status: TestDataStatus.empty,
          result: null,
        ));
      } else {
        emit(state.copyWith(
          status: TestDataStatus.success,
          result: result,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TestDataStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
      RefreshTestData event,
      Emitter<TestDataState> emit,
      ) async {
    final profileId = _lastProfileId;
    final dietitianId = _dietitianId;
    if (profileId == null || dietitianId == null) return;

    add(LoadTestDataForDay(
      profileId: profileId,
      date: _lastDate,
      dietitianId: dietitianId,
    ));
  }
}
