import 'package:equatable/equatable.dart';

sealed class LatestTestEvent extends Equatable {
  const LatestTestEvent();
  @override
  List<Object?> get props => [];
}

class FetchLatestTest extends LatestTestEvent {
  final String dietitianId;
  final String profileId;
  final String date; // YYYY-MM-DD

  const FetchLatestTest({
    required this.dietitianId,
    required this.profileId,
    required this.date,
  });

  @override
  List<Object?> get props => [dietitianId, profileId, date];
}
