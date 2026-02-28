import 'package:equatable/equatable.dart';

abstract class TodayTestDataEvent extends Equatable {
  const TodayTestDataEvent();
  @override
  List<Object?> get props => [];
}

class LoadTestDataForDay extends TodayTestDataEvent {
  final String profileId;
  final String dietitianId;
  final DateTime? date; // optional specific day

  const LoadTestDataForDay({required this.dietitianId,required this.profileId, this.date});

  @override
  List<Object?> get props => [profileId, date];
}

class RefreshTestData extends TodayTestDataEvent {
  const RefreshTestData();
}
