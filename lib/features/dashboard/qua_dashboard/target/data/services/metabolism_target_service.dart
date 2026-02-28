import 'dart:convert';
import 'package:http/http.dart' as http;

class MetabolismTargetService {

  MetabolismTargetService();

  Future<Map<String, dynamic>> fetchTarget({
    required int age,
    required String gender,
    required double heightCm,
    required double currentWeight,
    required bool diabetic,
  }) async {
    final uri = Uri.parse(
      "https://respyr.in/metabolism_target_get"
          "?age=$age"
          "&gender=$gender"
          "&height_cm=$heightCm"
          "&current_weight_kg=$currentWeight"
          "&diabetic=$diabetic",
    );




    final res = await http.get(uri);



    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    return jsonDecode(res.body);
  }
}
