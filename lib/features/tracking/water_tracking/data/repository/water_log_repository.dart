import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/water_log_data.dart';

class WaterLogRepository {
  final String baseUrl;

  WaterLogRepository({required this.baseUrl});

  /// Fetch full water history for profile (all days)
  Future<List<WaterLogData>> fetchWaterHistory({
    required String profileId,
  }) async {
    final url = Uri.parse('$baseUrl/get_water_history.php');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'profile_id': profileId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load water logs: HTTP ${response.statusCode}',
      );
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);

    if (jsonBody['status'] != true) {
      throw Exception(jsonBody['message'] ?? 'Failed to load water logs');
    }

    final List<dynamic> daysJson = jsonBody['days'] ?? [];

    return daysJson
        .map((e) => WaterLogData.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
