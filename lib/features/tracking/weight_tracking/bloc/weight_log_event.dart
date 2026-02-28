// lib/features/tracking/weight_tracking/presentation/bloc/weight_log_event.dart

import 'package:equatable/equatable.dart';

abstract class WeightLogEvent extends Equatable {
  const WeightLogEvent();

  @override
  List<Object?> get props => [];
}

// Load all logs by profile id
class LoadWeightLogs extends WeightLogEvent {
  final String profileId;

  const LoadWeightLogs(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

// 🔥 Delete a log by id AND profile id
class DeleteWeightLog extends WeightLogEvent {
  final int id;
  final String profileId;

  const DeleteWeightLog({
    required this.id,
    required this.profileId,
  });

  @override
  List<Object?> get props => [id, profileId];
}
