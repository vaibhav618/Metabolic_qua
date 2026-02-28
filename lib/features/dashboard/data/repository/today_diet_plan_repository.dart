import 'dart:convert';
import '../../../../client-dashboard/extras/get_today_key.dart';
import '../service/today_diet_plan_api_service.dart';


class TodayDietPlanRepository {
  final TodayDietPlanApiService api;
  TodayDietPlanRepository(this.api);

  Future<Map<String, dynamic>> fetchTodayDiet({
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
  }) async {
    final decoded = await api.fetchDietPlanRaw(
      dietitianId: dietitianId,
      profileId: profileId,
      dietPlanId: dietPlanId,
    );

    final dataList = decoded['data'] as List? ?? [];
    if (dataList.isEmpty) throw Exception('No data in response');

    final first = dataList.first as Map<String, dynamic>;

    // diet_json can come as Map or String
    dynamic dj = first['diet_json'] ?? {};
    Map<String, dynamic> dietJson = {};
    if (dj is String) {
      try {
        dietJson = jsonDecode(dj) as Map<String, dynamic>;
      } catch (_) {
        dietJson = {};
      }
    } else if (dj is Map) {
      dietJson = Map<String, dynamic>.from(dj);
    }

    if (dietJson.isEmpty) throw Exception("diet_json empty");

    final todayKey = TodayKey().todayKey();
    final today = (dietJson[todayKey] ?? {}) as Map<String, dynamic>;

    // If API returns only one day
    if (today.isEmpty && dietJson.isNotEmpty) {
      final keys =
      dietJson.keys.map((e) => e.toString().toLowerCase()).toList();
      if (keys.length == 1) {
        final k = keys.first;
        return {
          'dayKey': k,
          'totals': dietJson[k]?['totals'] ?? const {},
          'meals': dietJson[k]?['meals'] ?? const [],
        };
      }
    }

    return {
      'dayKey': todayKey,
      'totals': today['totals'] ?? const {},
      'meals': today['meals'] ?? const [],
    };
  }
}
