import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

import '../model/test_result_data_model_v2.dart';

class GeneratingResultRepository {
  Future<GeneratingResultModel> fetchResults({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    int debug = 1,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
  }) async {
    final url = Uri.parse(
      'https://humorstech.com/dietitian/api/app/daily_result_new_v2.php',
    );

    final body = {
      "acetone": acetone,
      "ethanol": ethanol,
      "hydrogen": hydrogen,
      "diabetic": diabetic,
      "goal": goal,
      "debug": debug,
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "min_range": minRange,
      "max_range": maxRange
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        return GeneratingResultModel.fromJson(data);
      } else {
        throw Exception("API Error: ${data['message']}");
      }
    } else {
      throw Exception("Network Error: ${response.statusCode}");
    }
  }

  Future<TestResultResponse> fetchResultsNew({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    int debug = 1,
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
    required double minRange,
    required double maxRange,
    required ClientProfileModel client,
  }) async {
    final url = Uri.parse(
      'https://humorstech.com/dietitian/api/app/daily_result_new_v2.php',
    );

    final body = {
      "acetone": acetone,
      "ethanol": ethanol,
      "hydrogen": hydrogen,
      "diabetic": diabetic,
      "goal": goal,
      "debug": debug,
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "diet_plan_id": dietPlanId,
      "min_range": minRange,
      "max_range": maxRange,
      "height_cm": client.height,
      "weight_kg": client.weight,
      "sex": client.gender.toLowerCase(),
      "activity": "light",
      "device_id": profileId.toLowerCase(),
      "strict_ai": 0,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        return TestResultResponse.fromJson(data);
      } else {
        throw Exception("API Error: ${data['message']}");
      }
    } else {
      throw Exception("Network Error: ${response.statusCode}");
    }
  }
}
