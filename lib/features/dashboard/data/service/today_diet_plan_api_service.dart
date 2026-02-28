import 'dart:convert';
import 'package:http/http.dart' as http;

class TodayDietPlanApiService {
  final String baseUrl;
  TodayDietPlanApiService({
    this.baseUrl = "https://humorstech.com/dietitian/api/app",
  });

  Future<Map<String, dynamic>> fetchDietPlanRaw({
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
  }) async {
    final uri = Uri.parse("$baseUrl/get_diet_plan.php");

    final body = jsonEncode({
      "login_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
    });

    final res = await http.post(
      uri,
      headers: const {"Content-Type": "application/json"},
      body: body,
    );


    print(res.body);

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
    if (res.body.isEmpty) {
      throw Exception("Empty response body");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected response shape");
    }

    return decoded;
  }
}
