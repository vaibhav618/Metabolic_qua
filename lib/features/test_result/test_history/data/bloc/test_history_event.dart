import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';

abstract class TestHistoryEvent extends Equatable {
  const TestHistoryEvent();
  @override
  List<Object?> get props => [];
}

class TestHistoryInit extends TestHistoryEvent {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;

  const TestHistoryInit({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
  });

  @override
  List<Object?> get props => [clientProfileModel, dietPlanStrategyModel];
}

class TestHistoryPrevWeek extends TestHistoryEvent {}

class TestHistoryNextWeek extends TestHistoryEvent {}
