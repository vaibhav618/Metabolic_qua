import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../core/url-manager/url_manager.dart';

class TestHistoryRepository {


  TestHistoryRepository();

  Future<List<Map<String, dynamic>>> fetchTests({
    required String dietitianId,
    required String profileId,
    required dynamic dietPlanId,
  }) async {
    final uri = Uri.parse(UrlManager().urlGetCompleteTestHistory);

    final body = {
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
    };

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("application" + dietitianId);
    print("application" + profileId);
    print("application" + dietPlanId);

    if (res.statusCode != 200) return [];

    final decoded = jsonDecode(res.body);

    if (decoded is! Map || decoded["success"] != true) return [];

    final testsList = decoded["tests"];
    if (testsList is List) {
      return testsList
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }
}
