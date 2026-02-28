import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

class DietitianRepository {
  Future<DietitianDetailModel?> fetchDietitian(String identifier) async {
    final String baseUrl =
        "https://humorstech.com/humors_app/app_final/dieticianapp/api/get_dietician.php";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"identifier": identifier},
    );


    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return DietitianDetailModel.fromJson(jsonResponse);
      }
    }

    return null;
  }
}