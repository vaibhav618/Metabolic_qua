// features/log_food/data/repository/fetch_food_log_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Adjust this to your actual fetch endpoint path.
const String FETCH_FOOD_LOG_URL =
    "https://humorstech.com/dietitian/api/app/fetch_food_log.php";

class FoodLogFetchApi {
  /// Returns a Set of keys like "meal_title||meal_name" (lowercased, trimmed)
  static Future<Set<String>> fetchLoggedKeys({
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
    required DateTime date, // expect local date
  }) async {
    final String dateStr =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    final res = await http.post(
      Uri.parse(FETCH_FOOD_LOG_URL),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        "dietician_id": dieticianId,
        "profile_id": profileId,
        "diet_plan_id": dietPlanId,
        "date": dateStr,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Fetch logs failed: HTTP ${res.statusCode}");
    }

    final body = utf8.decode(res.bodyBytes);
    final jsonMap = json.decode(body) as Map<String, dynamic>;
    if (jsonMap['success'] != true) {
      throw Exception(jsonMap['error'] ?? 'Fetch logs failed');
    }

    final List dataFlat = (jsonMap['data_flat'] as List?) ?? const [];
    final keys = <String>{};
    for (final row in dataFlat) {
      final map = row as Map<String, dynamic>;
      final title = (map['meal_title'] ?? '').toString().trim().toLowerCase();
      final name  = (map['meal_name']  ?? '').toString().trim().toLowerCase();
      if (title.isNotEmpty && name.isNotEmpty) {
        keys.add("$title||$name");
      }
    }
    return keys;
  }

  /// Helper to make the same key used above.
  static String makeKey(String mealTitle, String mealName) =>
      "${mealTitle.trim().toLowerCase()}||${mealName.trim().toLowerCase()}";
}
