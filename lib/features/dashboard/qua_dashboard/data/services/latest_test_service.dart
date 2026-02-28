import 'dart:convert';
import 'package:http/http.dart' as http;

class LatestTestService {

  Future<Map<String, dynamic>> fetchLatestTestRaw({
    required String dietitianId,
    required String profileId,
    required String date, // YYYY-MM-DD
  }) async {

    print(date);

    final res = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_scores_data_by_date.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "dietitian_id": dietitianId,
        "profile_id": profileId,
        "date": date,
      }),
    );




    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid API response");
    }
    return decoded;
  }
}
