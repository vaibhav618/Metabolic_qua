// lib/features/metabolism_test/data/sources/test_data_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TestDataApi {
  // Change this to your actual endpoint
  static const String baseUrl = 'https://humorstech.com/humors_app/app_final/dieticianapp/api/fetch_test_data_by_date.php';

  final http.Client _client;
  TestDataApi({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchByProfileAndDate({
    required String profileId,
    required String dateYMD, // YYYY-MM-DD
  }) async {
    final resp = await _client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'profile_id': profileId,
        'date': dateYMD,
      },
    );


    print(resp.body.toString());

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final decoded = json.decode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }
    if (decoded['success'] != true) {
      final msg = decoded['message'] ?? 'Unknown API error';
      throw Exception(msg);
    }
    return decoded;
  }
}
