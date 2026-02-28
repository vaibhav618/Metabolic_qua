import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';

abstract class DietitianDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DietitianDashboardInitial extends DietitianDashboardState {}

class DietitianDashboardLoading extends DietitianDashboardState {}

class DietitianDashboardLoaded extends DietitianDashboardState {
  final DietitianDashboardMealModel meal;

  DietitianDashboardLoaded({required this.meal});

  @override
  List<Object?> get props => [meal];
}

class DietitianDashboardSwipeSuccess extends DietitianDashboardState {}

class DietitianDashboardSwipeReset extends DietitianDashboardState {}

class DietitianDashboardError extends DietitianDashboardState {
  final String message;

  DietitianDashboardError({required this.message});
  @override
  List<Object?> get props => [message];
}
