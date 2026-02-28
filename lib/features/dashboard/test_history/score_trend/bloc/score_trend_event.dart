abstract class ScoreTrendEvent {}

/// Event to trigger the data fetch for a specific profile ID.
class FetchMetabolismData extends ScoreTrendEvent {
  final String profileId;
  FetchMetabolismData(this.profileId);
}