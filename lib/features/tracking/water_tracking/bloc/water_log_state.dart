import 'package:equatable/equatable.dart';

import '../data/model/water_intake_data.dart';

abstract class WaterLogState extends Equatable {
  const WaterLogState();

  @override
  List<Object?> get props => [];
}

class WaterChartInitial extends WaterLogState {}

class WaterChartLoading extends WaterLogState {}

class WaterChartLoaded extends WaterLogState {
  final List<WaterIntakeDay> days;      // full history
  final double targetWaterInML;         // client target (for chart)
  final int selectedIndex;              // currently selected day in `days`

  const WaterChartLoaded({
    required this.days,
    required this.targetWaterInML,
    required this.selectedIndex,
  });

  WaterChartLoaded copyWith({
    List<WaterIntakeDay>? days,
    double? targetWaterInML,
    int? selectedIndex,
  }) {
    return WaterChartLoaded(
      days: days ?? this.days,
      targetWaterInML: targetWaterInML ?? this.targetWaterInML,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [days, targetWaterInML, selectedIndex];
}

class WaterChartError extends WaterLogState {
  final String message;

  const WaterChartError(this.message);

  @override
  List<Object?> get props => [message];
}
