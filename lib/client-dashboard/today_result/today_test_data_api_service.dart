import 'dart:convert';
import 'package:http/http.dart' as http;

class TodayTestDataApiService {
  final String baseUrl;

  TodayTestDataApiService({
    this.baseUrl = "https://humorstech.com/dietitian/api/app",
  });

  /// Fetch test data for a given date (YYYY-MM-DD) and profile/dietitian.
  Future<Map<String, dynamic>> fetchForDay({
    required String dietitianId,
    required String profileId,
    required String dateYYYYMMDD,
  }) async {
    final uri = Uri.parse("$baseUrl/get_test_data_by_date1.php");

    // Prepare JSON body
    final body = jsonEncode({
      "dietitian_id": dietitianId,
      "profile_id": profileId,
      "date": dateYYYYMMDD,
    });

    // Send as raw JSON (PHP reads php://input)
    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );


    // Basic HTTP error check
    if (resp.statusCode != 200) {
      throw Exception("HTTP ${resp.statusCode}: ${resp.reasonPhrase}");
    }

    // Decode JSON
    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid JSON structure");
    }

    // Validate success field
    if (decoded['success'] != true) {
      throw Exception(decoded['error']?.toString() ?? "API returned success=false");
    }

    return decoded;
  }
}
