import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/data/model/score_trend_model.dart';

abstract class ScoreTrendState extends Equatable {
  const ScoreTrendState();

  @override
  List<Object?> get props => [];
}

class ScoreTrendInitial extends ScoreTrendState {}

class ScoreTrendLoading extends ScoreTrendState {}

class ScoreTrendError extends ScoreTrendState {
  final String message;

  const ScoreTrendError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScoreTrendLoaded extends ScoreTrendState {
  final List<ScoreTrendModel> scores;

  const ScoreTrendLoaded(this.scores);

  @override
  List<Object?> get props => [scores];
}

class NoTestDataFound extends ScoreTrendState {
  final String message;

  const NoTestDataFound(this.message);

  @override
  List<Object?> get props => [message];
}
