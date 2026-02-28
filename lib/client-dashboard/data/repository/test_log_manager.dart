
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/url-manager/url_manager.dart';
import '../model/insert_test_log_model.dart';
import '../model/test_log_exception.dart';
import '../model/test_log_model.dart';
import '../model/test_log_status_model.dart';



// final service = TestLogService();
//
// // 1) Insert (only when test taken)
// final insert = await service.insertTestLog(
// dietPlanId: "DP001",
// clientId: "C001",
// testTaken: true,
// testId: "T123",
// );
// // insert.success, insert.insertedId, insert.message







class TestLogService {
  final http.Client _client;
   TestLogService({http.Client? client}) : _client = client ??  http.Client();

  /// Insert a test log. Only sends to server when [testTaken] is true.
  /// Returns [InsertLogResult] with id if created, or a message when skipped.
  Future<InsertLogResult> insertTestLog({
    required String dietPlanId,
    required String clientId,
    required bool testTaken,
    String? testId, // required when testTaken == true
  }) async {
    final uri = Uri.parse(UrlManager().urlSaveTestLog);
    final payload = <String, dynamic>{
      "diet_plan_id": dietPlanId,
      "client_id": clientId,
      "test_taken": testTaken, // server normalizes boolean
      if (testTaken) "test_id": (testId ?? ""),
    };

    try {
      final res = await _client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> body = _decodeBody(res);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return InsertLogResult(
          success: body["success"] == true,
          message: (body["message"] ?? "").toString(),
          insertedId: (body["data"] is Map && body["data"]?["id"] != null)
              ? int.tryParse(body["data"]["id"].toString())
              : null,
        );
      } else {
        throw TestLogException("${body["message"] ?? "Insert failed"} (HTTP ${res.statusCode})");
      }
    } catch (e) {
      throw TestLogException(e.toString());
    }
  }

  /// Check if a log exists for a client on a specific date (YYYY-MM-DD).
  /// Optional dietPlanId to narrow search.
  Future<TestLogStatus> getTestLogStatus({
    required String clientId,
    required String dateYmd, // "YYYY-MM-DD"
    String? dietPlanId,
  }) async {

    final uri = Uri.parse(UrlManager().urlGetTestLogStatus);

    final payload = <String, dynamic>{
      "client_id": clientId,
      "date": dateYmd,
      if (dietPlanId != null && dietPlanId.isNotEmpty) "diet_plan_id": dietPlanId,
    };

    try {
      // Can be GET or POST; using POST with JSON
      final res = await _client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> body = _decodeBody(res);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = body["data"];
        return TestLogStatus(
          success: body["success"] == true,
          message: (body["message"] ?? "").toString(),
          hasLog: body["has_log"] == true,
          log: (data is Map<String, dynamic>) ? TestLog.fromJson(data) : null,
        );
      } else {
        throw TestLogException("${body["message"] ?? "Fetch failed"} (HTTP ${res.statusCode})");
      }
    } catch (e) {
      throw TestLogException(e.toString());
    }
  }

  Map<String, dynamic> _decodeBody(http.Response res) {
    try {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return {"success": false, "message": "Invalid JSON response", "raw": res.body};
    }
  }
}







