// lib/features/log_food/data/repository/fetch_food_log_by_day_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/food_log_day.dart';

class LoggedFoodService {
  static const String _url =
      "https://humorstech.com/dietitian/api/app/fetch_food_log_by_day.php";

  static Future<List<FoodLogDay>> fetchPlanDays({
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
  }) async {
    final res = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "dietician_id": dieticianId,
        "profile_id": profileId,
        "diet_plan_id": dietPlanId,
        // dates are ignored server-side; plan window is enforced there
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final top = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (top['success'] != true) {
      throw Exception(top['error'] ?? 'Unknown API error');
    }

    final data = top['data'] as Map<String, dynamic>;
    final days = (data['days'] as List? ?? [])
        .map((e) => FoodLogDay.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return days;
  }
}
