import 'package:flutter_bloc/flutter_bloc.dart';

import 'water_log_event.dart';
import 'water_log_state.dart';
import '../data/model/water_intake_data.dart';
import '../data/model/water_log_data.dart';
import '../data/repository/water_log_repository.dart';

class WaterLogBloc extends Bloc<WaterLogEvent, WaterLogState> {
  final WaterLogRepository repository;

  WaterLogBloc({required this.repository}) : super(WaterChartInitial()) {
    on<LoadWaterLog>(_onLoadWaterChart);
    on<SelectWaterLogDay>(_onSelectWaterLogDay);
  }

  Future<void> _onLoadWaterChart(
      LoadWaterLog event,
      Emitter<WaterLogState> emit,
      ) async {
    // ✅ Only show loader when caller wants it
    if (event.showLoader) {
      emit(WaterChartLoading());
    }

    try {
      // 1) Fetch FULL history from API
      final List<WaterLogData> logs = await repository.fetchWaterHistory(
        profileId: event.profileId,
      );

      // 2) Map WaterLogData -> WaterIntakeDay (keep target from API)
      final List<WaterIntakeDay> chartDays = logs.map((log) {
        final double consumedLiters = log.totalLiters; // from API (L)
        final double targetLiters = log.targetLiters;   // from API (L)

        return WaterIntakeDay(
          date: log.date,
          targetLiters: targetLiters,
          consumedLiters: consumedLiters,
        );
      }).toList();

      // Sort by date ascending just to be safe
      chartDays.sort((a, b) => a.date.compareTo(b.date));

      // Base target if we need to create dummy days
      double baseTargetLiters;
      if (chartDays.isNotEmpty) {
        baseTargetLiters = chartDays.last.targetLiters;
      } else {
        // fallback from global target in ML
        baseTargetLiters = event.targetWaterInML / 1000.0;
      }

      // 3) Ensure "today" exists in the list
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int todayIndex = chartDays.indexWhere((d) {
        final dt = d.date;
        final onlyDate = DateTime(dt.year, dt.month, dt.day);
        return onlyDate == today;
      });

      if (todayIndex == -1) {
        // No entry for today -> add a dummy day with 0 L consumed
        chartDays.add(
          WaterIntakeDay(
            date: today,
            targetLiters: baseTargetLiters,
            consumedLiters: 0,
          ),
        );
        chartDays.sort((a, b) => a.date.compareTo(b.date));
      }

      // Recalculate today's index after maybe inserting it
      todayIndex = chartDays.indexWhere((d) {
        final dt = d.date;
        final onlyDate = DateTime(dt.year, dt.month, dt.day);
        return onlyDate == today;
      });

      // 4) Add +3 future days from the last date (after sorting)
      if (chartDays.isNotEmpty) {
        final lastDate = chartDays.last.date;
        final DateTime lastOnlyDate =
        DateTime(lastDate.year, lastDate.month, lastDate.day);

        for (int i = 1; i <= 3; i++) {
          final nextDate = lastOnlyDate.add(Duration(days: i));

          final exists = chartDays.any((d) {
            final dt = d.date;
            final only = DateTime(dt.year, dt.month, dt.day);
            return only == nextDate;
          });

          if (!exists) {
            chartDays.add(
              WaterIntakeDay(
                date: nextDate,
                targetLiters: baseTargetLiters,
                consumedLiters: 0,
              ),
            );
          }
        }

        chartDays.sort((a, b) => a.date.compareTo(b.date));
      }

      // 5) Default selected index = today's index (guaranteed to exist)
      final int defaultSelectedIndex = todayIndex;

      emit(
        WaterChartLoaded(
          days: chartDays,
          targetWaterInML: event.targetWaterInML,
          selectedIndex: defaultSelectedIndex,
        ),
      );
    } catch (e) {
      emit(WaterChartError(e.toString()));
    }
  }

  void _onSelectWaterLogDay(
      SelectWaterLogDay event,
      Emitter<WaterLogState> emit,
      ) {
    final currentState = state;
    if (currentState is WaterChartLoaded && currentState.days.isNotEmpty) {
      int idx = event.index; //

      if (idx < 0) idx = 0;
      if (idx >= currentState.days.length) {
        idx = currentState.days.length - 1;
      }

      emit(currentState.copyWith(selectedIndex: idx));
    }
  }
}
