import '../model/diet_plan_strategy_model.dart';
import '../services/diet_plan_service.dart';

class CategorizedPlans {
  final List<DietPlanStrategyModel> active;
  final List<DietPlanStrategyModel> completed;
  final List<DietPlanStrategyModel> cancelled;
  final List<DietPlanStrategyModel> other;

  const CategorizedPlans({
    required this.active,
    required this.completed,
    required this.cancelled,
    required this.other,
  });
}

class DietPlanRepository {
  final DietPlanService service;
  DietPlanRepository(this.service);

  Future<CategorizedPlans> getPlans({
    required String dietitianId,
    required String clientId,
  }) async {
    final json = await service.fetchPlans(dietitianId: dietitianId, clientId: clientId);
    if (json['success'] != true) {
      throw Exception(json['message']?.toString() ?? 'Unknown API error');
    }

    final data = json['data'];


    List<DietPlanStrategyModel> parseList(dynamic v) {
      if (v is List) {
        return v.map((e) => DietPlanStrategyModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return <DietPlanStrategyModel>[];
    }

    // Case A: already categorized
    if (data is Map<String, dynamic>) {
      return CategorizedPlans(
        active: parseList(data['active']),
        completed: parseList(data['completed']),
        cancelled: parseList(data['cancelled']),
        other: parseList(data['other']),
      );
    }

    // Case B: flat list -> categorize here
    if (data is List) {
      final all = parseList(data);
      final active = <DietPlanStrategyModel>[];
      final completed = <DietPlanStrategyModel>[];
      final cancelled = <DietPlanStrategyModel>[];
      final other = <DietPlanStrategyModel>[];

      for (final p in all) {
        switch (p.status) {
          case 'active': active.add(p); break;
          case 'completed': completed.add(p); break;
          case 'cancelled':
          case 'canceled': cancelled.add(p); break;
          default: other.add(p); break;
        }
      }
      return CategorizedPlans(
        active: active,
        completed: completed,
        cancelled: cancelled,
        other: other,
      );
    }

    throw Exception('Unexpected response format');
  }
}
