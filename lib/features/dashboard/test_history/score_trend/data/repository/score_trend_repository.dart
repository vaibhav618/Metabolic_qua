import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/data/model/score_trend_model.dart';

/// Handles the actual network request logic.
class ScoreTrendRepository {
  final String apiUrl = 'https://humorstech.com/dietitian/api/app/get_scores_data.php';

  Future<List<ScoreTrendModel>> fetchScores(String profileId) async {
    final Map<String, dynamic> body = {'profile_id': "profile3"};
    final uri = Uri.parse(apiUrl);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );





      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success' && jsonResponse['data'] is List) {
          final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
          return dataList.map((json) => ScoreTrendModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (jsonResponse['status'] == 'error' && jsonResponse['message'] != null) {
          if (jsonResponse['message'] == 'No test data found for profile_id: ${profileId}.') {
            return []; // Return empty list if no data found
          }
          throw Exception(jsonResponse['message']);
        }

        throw Exception('API response was valid but did not contain expected data.');
      } else if (response.statusCode == 404) {
        return []; // Return empty list if data is not found
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error: Could not connect to the API.');
    } catch (e) {
      // Catch general errors (e.g., JSON decoding error, custom exceptions)
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}
