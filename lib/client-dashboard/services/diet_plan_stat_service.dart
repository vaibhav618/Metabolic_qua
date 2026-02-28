import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/plan_stats.dart';

class DietPlanStatService {


  Future<DietPlanStatApi> fetchPlanStats({
    required String dietitianId,
    required String clientId,
    required String dietPlanId,
  }) async {
    final resp = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_diet_plan_statistics.php"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dietitian_id': dietitianId,
        'client_id': clientId,
        'diet_plan_id': dietPlanId,
      }),
    );






    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    print("resp :" + resp.statusCode.toString());

    final Map<String, dynamic> jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
    return DietPlanStatApi.fromJson(jsonMap);
  }
}
