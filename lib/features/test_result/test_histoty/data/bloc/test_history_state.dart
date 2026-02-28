import 'package:equatable/equatable.dart';
import '../../data/week_range.dart';

class TestHistoryState extends Equatable {
  final List<WeekRange> weeks;
  final int currentWeekIndex;
  final DateTime? planStart;
  final DateTime? planEnd;

  final bool loading;
  final String? error;

  final List<Map<String, dynamic>> allTests;

  const TestHistoryState({
    required this.weeks,
    required this.currentWeekIndex,
    required this.planStart,
    required this.planEnd,
    required this.loading,
    required this.allTests,
    this.error,
  });

  factory TestHistoryState.initial() {
    return const TestHistoryState(
      weeks: [],
      currentWeekIndex: 0,
      planStart: null,
      planEnd: null,
      loading: false,
      allTests: [],
      error: null,
    );
  }

  TestHistoryState copyWith({
    List<WeekRange>? weeks,
    int? currentWeekIndex,
    DateTime? planStart,
    DateTime? planEnd,
    bool? loading,
    String? error,
    List<Map<String, dynamic>>? allTests,
  }) {
    return TestHistoryState(
      weeks: weeks ?? this.weeks,
      currentWeekIndex: currentWeekIndex ?? this.currentWeekIndex,
      planStart: planStart ?? this.planStart,
      planEnd: planEnd ?? this.planEnd,
      loading: loading ?? this.loading,
      error: error,
      allTests: allTests ?? this.allTests,
    );
  }

  @override
  List<Object?> get props =>
      [weeks, currentWeekIndex, planStart, planEnd, loading, error, allTests];
}
