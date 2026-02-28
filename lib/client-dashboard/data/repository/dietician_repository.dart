import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/client-dashboard/data/model/dietitian_model.dart';

import '../../../core/url-manager/url_manager.dart';

class DietitianRepository {


  Future<DietitianModel> fetchDietitian() async {
    final response = await http.get(Uri.parse(UrlManager().urlGetDietitianDetails));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        return DietitianModel.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception('Failed to load dietitian');
    }
  }
}
