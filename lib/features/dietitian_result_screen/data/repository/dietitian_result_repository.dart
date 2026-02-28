// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/result_model.dart';

// class ResultRepository {
//   Future<ResultModel> fetchResults(String loginId, String profileId) async {
//     final url = Uri.parse('https://humorstech.com/humors_app/app_final/fetch_history3.php?login_id=$loginId&profile_id=$profileId');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return ResultModel.fromJson(data['data'][0]);
//     } else {
//       throw Exception('Failed to load results');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/dietitian_result_model.dart';

class DietitianResultRepository {
  Future<DietitianResultModel> fetchResults({
    required double acetone,
    required double ethanol,
    required double hydrogen,
    required bool diabetic,
    required String goal,
    int debug = 1,
    required String dietitianId,
    required String profileId,
  }) async {
    final url = Uri.parse(
      'https://humorstech.com/dietitian/api/app/daily_result_new.php',
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
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        return DietitianResultModel.fromJson(data);
      } else {
        throw Exception("API Error: ${data['message']}");
      }
    } else {
      throw Exception("Network Error: ${response.statusCode}");
    }
  }
}
