import 'package:equatable/equatable.dart';

import '../repositories/diet_plan_repository.dart';

enum LoadStatus { initial, loading, success, failure }

class DietPlanState extends Equatable {
  final LoadStatus status;
  final CategorizedPlans? data;
  final String? error;
  final String filter; // all/active/completed/cancelled/other

  const DietPlanState({
    this.status = LoadStatus.initial,
    this.data,
    this.error,
    this.filter = 'all',
  });

  DietPlanState copyWith({
    LoadStatus? status,
    CategorizedPlans? data,
    String? error,
    String? filter,
  }) {
    return DietPlanState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [status, data, error, filter];
}
