// lib/features/tracking/weight_tracking/presentation/bloc/weight_log_state.dart

import 'package:equatable/equatable.dart';
import '../data/model/weight_log_model.dart';

abstract class WeightLogState extends Equatable {
  const WeightLogState();

  @override
  List<Object?> get props => [];
}

class WeightLogInitial extends WeightLogState {}

class WeightLogLoading extends WeightLogState {}

class WeightLogLoaded extends WeightLogState {
  final List<WeightLogModel> logs;

  const WeightLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class WeightLogError extends WeightLogState {
  final String message;

  const WeightLogError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 🔥 New States for Delete Feature
class WeightLogDeleting extends WeightLogState {}

class WeightLogDeleted extends WeightLogState {
  final String message;

  const WeightLogDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class WeightLogDeleteError extends WeightLogState {
  final String message;

  const WeightLogDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
