import 'dart:convert';
import 'package:http/http.dart' as http;

class DietPlanService {
  final http.Client _client;

  DietPlanService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchPlans({
    required String dietitianId,
    required String clientId,
  }) async {
    final uri = Uri.parse(
      "https://humorstech.com/humors_app/app_final/dieticianapp/api/fetch_diet_plan_strategy.php",
    );

    final res = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'dietitian_id': dietitianId,
        'client_id': clientId,
      },
    );



    print(res.body);
    print(dietitianId);
    print(clientId);


    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception("Invalid JSON: ${res.body}");
      }
    }

    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
