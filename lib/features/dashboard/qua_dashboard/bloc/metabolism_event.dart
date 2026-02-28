// EVENTS




import '../data/models/metabolism_score.dart';

abstract class MetabolismEvent {}
class FetchMetabolismData extends MetabolismEvent {
  final String dietitianId;
  final String profileId;
  FetchMetabolismData(this.dietitianId, this.profileId);
}

// STATES
abstract class MetabolismState {}
class MetabolismInitial extends MetabolismState {}
class MetabolismLoading extends MetabolismState {}
class MetabolismLoaded extends MetabolismState {
  final List<MetabolismScore> scores;
  MetabolismLoaded(this.scores);
}
class MetabolismError extends MetabolismState {
  final String message;
  MetabolismError(this.message);
}