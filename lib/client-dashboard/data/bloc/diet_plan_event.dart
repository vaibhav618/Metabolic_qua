import 'package:equatable/equatable.dart';

abstract class DietPlanEvent extends Equatable {
  const DietPlanEvent();
  @override
  List<Object?> get props => [];
}

class FetchPlans extends DietPlanEvent {
  final String dietitianId;
  final String clientId;
  const FetchPlans({required this.dietitianId, required this.clientId});

  @override
  List<Object?> get props => [dietitianId, clientId];
}

class ChangeFilter extends DietPlanEvent {
  final String filter; // all/active/completed/cancelled/other
  const ChangeFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class RefreshPlans extends DietPlanEvent {
  const RefreshPlans();
}
