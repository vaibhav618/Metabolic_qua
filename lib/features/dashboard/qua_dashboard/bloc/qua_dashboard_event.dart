import 'package:equatable/equatable.dart';

abstract class QuaDashboardEvent extends Equatable {
  const QuaDashboardEvent();
  @override
  List<Object?> get props => [];
}

class QuaLoadClientAndDietitian extends QuaDashboardEvent {
  final String email;
  const QuaLoadClientAndDietitian({required this.email});
  @override
  List<Object?> get props => [email];
}

class QuaRefreshClientAndDietitian extends QuaDashboardEvent {
  final String email;
  const QuaRefreshClientAndDietitian({required this.email});
  @override
  List<Object?> get props => [email];
}

class QuaUpdateWeight extends QuaDashboardEvent {
  final String profileId;
  final double weightKg;
  final String email;

  const QuaUpdateWeight({
    required this.profileId,
    required this.weightKg,
    required this.email,
  });

  @override
  List<Object?> get props => [profileId, weightKg, email];
}

class QuaReset extends QuaDashboardEvent {
  const QuaReset();
}
