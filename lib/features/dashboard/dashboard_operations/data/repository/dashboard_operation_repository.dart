// dashboard_operation_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardOperationRepository {
  final String baseUrl;

  DashboardOperationRepository({
    this.baseUrl = 'https://humorstech.com/dietitian/api/app/',
  });

  Future<void> insertWeightLog(
      String profileId,
      double weightKg,
      String loggedBy,
      String loggedById,
      String? notes,
      ) async {
    final uri = Uri.parse('${baseUrl}insert_weight_log.php');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'profile_id': profileId,
        'weight_kg': weightKg,
        'logged_by': loggedBy,
        'logged_by_id': loggedById,
        "target_weight" : 0,
        "weight_change_type" : "weight_loss",
        'notes': notes,
      }),
    );


    print(response.body.toString());

    if (response.statusCode != 200) {
      throw Exception('Failed to insert weight log');
    }

    final Map<String, dynamic> jsonRes = jsonDecode(response.body);

    if (jsonRes['status'] != true) {
      throw Exception(jsonRes['message']?.toString() ?? 'Insert failed');
    }
  }
}
