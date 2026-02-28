import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/metabolism_score.dart';


class MetabolismRepository {
  final String apiUrl = "https://humorstech.com/dietitian/api/app/calender_score_data.php";

  Future<List<MetabolismScore>> fetchScores(String dietitianId, String profileId) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        "dietitian_id": dietitianId,
        "profile_id": profileId,
      }),
    );



    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        List<dynamic> data = result['data'];
        return data.map((item) => MetabolismScore.fromJson(item)).toList();
      } else {
        throw Exception(result['message']);
      }
    } else {
      throw Exception("Failed to connect to server");
    }
  }
}