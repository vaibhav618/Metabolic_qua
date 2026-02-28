import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodLogApi {
  static const String _baseUrl =
      "https://humorstech.com/dietitian/api/app/insert_food_log.php";

  /// Inserts a food log entry and returns the decoded JSON response
  static Future<Map<String, dynamic>> insertFoodLog({
    required String dieticianId,
    required String profileId,
    required String dietPlanId,
    required String mealTitle,
    required String mealName,
    required String mealValues,

    // NEW:
    String? mealDate,   // "YYYY-MM-DD HH:MM:SS" or "YYYY-MM-DD"
    String? mealDay,    // "monday".."sunday"

    // Optional legacy field (not needed by new PHP)
    String? dttm,
  }) async {
    final Map<String, dynamic> body = {
      "dietician_id": dieticianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "meal_title": mealTitle,
      "meal_name": mealName,
      "meal_values": mealValues,
      // NEW columns:
      if (mealDate != null && mealDate.isNotEmpty) "meal_date": mealDate,
      if (mealDay != null && mealDay.isNotEmpty)   "meal_day": mealDay,
      // Optional legacy:
      if (dttm != null && dttm.isNotEmpty) "dttm": dttm,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "error": "HTTP Error: ${response.statusCode}",
          "body": response.body
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
