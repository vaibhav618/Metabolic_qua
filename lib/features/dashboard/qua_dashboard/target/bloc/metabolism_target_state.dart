import 'package:equatable/equatable.dart';
import '../data/models/metabolism_target_model.dart';

sealed class MetabolismTargetState extends Equatable {
  const MetabolismTargetState();
  @override
  List<Object?> get props => [];
}

class MetabolismTargetInitial extends MetabolismTargetState {}

class MetabolismTargetLoading extends MetabolismTargetState {}

class MetabolismTargetLoaded extends MetabolismTargetState {
  final MetabolismTargetModel data;
  const MetabolismTargetLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class MetabolismTargetError extends MetabolismTargetState {
  final String message;
  const MetabolismTargetError(this.message);

  @override
  List<Object?> get props => [message];
}
