import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/week_range.dart';
import 'test_history_event.dart';
import 'test_history_state.dart';
import 'test_history_repository.dart';

class TestHistoryBloc extends Bloc<TestHistoryEvent, TestHistoryState> {
  final TestHistoryRepository repository;

  TestHistoryBloc({required this.repository})
      : super(TestHistoryState.initial()) {
    on<TestHistoryInit>(_onInit);
    on<TestHistoryPrevWeek>(_onPrevWeek);
    on<TestHistoryNextWeek>(_onNextWeek);
  }

  Future<void> _onInit(
      TestHistoryInit event, Emitter<TestHistoryState> emit) async {
    // ✅ EXACT same logic as your _buildWeeks()
    try {
      DateTime? start = event.dietPlanStrategyModel.planStartDate;
      DateTime? end = event.dietPlanStrategyModel.planEndDate;

      // if any is null, your code would throw inside try and go catch
      // so we mimic that by forcing exception
      if (start == null || end == null) {
        throw Exception("Null plan dates");
      }

      if (end.isBefore(start)) {
        end = start;
      }

      final weeks = _generateWeekRanges(start, end);

      final safeWeeks =
      weeks.isEmpty ? [WeekRange(start: start, end: end)] : weeks;

      final initialIndex = _computeInitialWeekIndex(safeWeeks);

      emit(state.copyWith(
        weeks: safeWeeks,
        planStart: start,
        planEnd: end,
        currentWeekIndex: initialIndex,
        loading: true,
        error: null,
      ));

      // ✅ EXACT same fetchTests payload
      final tests = await repository.fetchTests(
        dietitianId: event.clientProfileModel.dietitianId,
        profileId: event.clientProfileModel.profileId,
        dietPlanId: event.dietPlanStrategyModel.id,
      );

      emit(state.copyWith(
        allTests: tests,
        loading: false,
        error: null,
      ));
    } catch (e) {
      // ✅ EXACT same catch behavior as your UI
      emit(state.copyWith(
        weeks: [],
        planStart: null,
        planEnd: null,
        loading: false,
        allTests: [],
        error: "No valid plan dates found",
      ));
    }
  }

  void _onPrevWeek(
      TestHistoryPrevWeek event, Emitter<TestHistoryState> emit) {
    if (state.currentWeekIndex > 0) {
      emit(state.copyWith(currentWeekIndex: state.currentWeekIndex - 1));
    }
  }

  void _onNextWeek(
      TestHistoryNextWeek event, Emitter<TestHistoryState> emit) {
    final nextIndex = state.currentWeekIndex + 1;

    final canGoNext = nextIndex < state.weeks.length &&
        !_isFutureWeekIndex(state.weeks, nextIndex);

    if (canGoNext) {
      emit(state.copyWith(currentWeekIndex: nextIndex));
    }
  }

  // ---------- SAME helper logic ----------

  List<WeekRange> _generateWeekRanges(DateTime start, DateTime end) {
    final List<WeekRange> weeks = [];
    DateTime currentStart = start;

    while (!currentStart.isAfter(end)) {
      DateTime currentEnd = currentStart.add(const Duration(days: 6));
      if (currentEnd.isAfter(end)) currentEnd = end;

      weeks.add(WeekRange(start: currentStart, end: currentEnd));
      currentStart = currentEnd.add(const Duration(days: 1));
    }

    return weeks;
  }

  int _computeInitialWeekIndex(List<WeekRange> weeks) {
    if (weeks.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < weeks.length; i++) {
      final w = weeks[i];
      final start = DateTime(w.start.year, w.start.month, w.start.day);
      final end = DateTime(w.end.year, w.end.month, w.end.day);

      if (!today.isBefore(start) && !today.isAfter(end)) {
        return i;
      }
    }

    final firstStart = DateTime(
        weeks.first.start.year, weeks.first.start.month, weeks.first.start.day);
    final lastEnd = DateTime(
        weeks.last.end.year, weeks.last.end.month, weeks.last.end.day);

    if (today.isBefore(firstStart)) return 0;
    if (today.isAfter(lastEnd)) return weeks.length - 1;

    return 0;
  }

  bool _isFutureWeekIndex(List<WeekRange> weeks, int index) {
    if (index < 0 || index >= weeks.length) return false;
    final w = weeks[index];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = DateTime(w.start.year, w.start.month, w.start.day);

    return weekStart.isAfter(today);
  }
}
