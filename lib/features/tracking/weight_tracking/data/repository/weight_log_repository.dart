// lib/features/tracking/weight_tracking/data/repository/weight_log_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/weight_log_model.dart';

class WeightLogRepository {
  final String baseUrl;

  WeightLogRepository({
    this.baseUrl = 'https://humorstech.com/dietitian/api/app/',
  });


  /// Fetch all weight logs by profile_id
  Future<List<WeightLogModel>> fetchWeightLogs(String profileId) async {
    final uri = Uri.parse('${baseUrl}get_weight_logs.php');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'profile_id': profileId}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Request failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> jsonRes = jsonDecode(response.body);

    // 🟢 IMPORTANT:
    // If backend says "No weight logs found", treat as EMPTY LIST, not error
    if (jsonRes['status'] != true) {
      final msg = jsonRes['message']?.toString() ?? '';
      if (msg.toLowerCase().contains('no weight logs')) {
        return <WeightLogModel>[]; // just return empty
      }
      throw Exception(msg.isNotEmpty ? msg : 'Unknown error');
    }

    final List data = jsonRes['data'] as List;
    return data.map((e) => WeightLogModel.fromJson(e)).toList();
  }



  /// 🔥 Delete a specific log by [id] & [profileId]
  Future<void> deleteWeightLog({
    required int id,
    required String profileId,
  }) async {
    final uri = Uri.parse('${baseUrl}delete_weight_log.php');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'profile_id': profileId,
      }),
    );



    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode} ${response.reasonPhrase}');
    }

    final Map<String, dynamic> jsonRes = jsonDecode(response.body);

    if (jsonRes['status'] != true) {
      throw Exception(jsonRes['message']?.toString() ?? 'Delete failed');
    }
  }
}
