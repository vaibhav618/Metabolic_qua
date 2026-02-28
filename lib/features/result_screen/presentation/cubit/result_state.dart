import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/result_screen/data/models/result_model.dart';

abstract class ResultState extends Equatable {
  const ResultState();
  @override
  List<Object?> get props => [];
}

class ResultInitial extends ResultState {}

class ResultLoading extends ResultState {}

class ResultLoaded extends ResultState {
  final ResultModel result;

  const ResultLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class ResultError extends ResultState {
  final String message;

  const ResultError(this.message);

  @override
  List<Object?> get props => [message];
}
