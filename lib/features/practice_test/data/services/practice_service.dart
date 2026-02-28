import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PracticeService {
  static const String _baseUrl = "https://humorstech.com/dietitian/api/app";

  Future<bool> checkNeedsPractice(String profileId) async {
    debugPrint("💡 [API CALL] Checking practice status for: $profileId");

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_practice_test_status.php"),
        headers: {
          "Content-Type": "application/json"
        }, // 👈 Tells PHP to expect JSON
        body: jsonEncode({"profile_id": profileId}), // 👈 Converts data to JSON
      );

      debugPrint("💡 [API RESPONSE CODE] ${response.statusCode}");
      debugPrint("💡 [API RESPONSE BODY] ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final bool hasPracticed =
            data['status'] == true || data['status'] == "true";
        debugPrint("💡 [LOGIC CHECK] Has Practiced? $hasPracticed");

        return !hasPracticed;
      }

      debugPrint(
          "💡 [WARNING] Server returned ${response.statusCode}, defaulting to practice.");
      return true;
    } catch (e) {
      debugPrint("💡 [ERROR] API Call Failed: $e");
      return true;
    }
  }

  Future<void> markPracticeAsDone(String profileId) async {
    debugPrint("💡 [API CALL] Marking practice as done for: $profileId");

    // Notice we don't use try/catch here!
    // We want the error to bubble up to your UI button so it shows the red Snackbar.
    final response = await http.post(
      Uri.parse("$_baseUrl/update_practice_test.php"),
      headers: {
        "Content-Type": "application/json"
      }, // 👈 Tells PHP to expect JSON
      body: jsonEncode({
        "profile_id": profileId,
        "status": true, // 👈 Converts data to JSON
      }),
    );

    debugPrint("💡 [API UPDATE RESPONSE] ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == false) {
        // If PHP says success: false, trigger the button's error state
        throw Exception(data['message'] ?? "Server rejected update");
      }
    } else {
      throw Exception("Server returned ${response.statusCode}");
    }
  }
}
