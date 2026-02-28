import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/notification_model.dart';



class NotificationRepository {
  final String baseUrl ="https://humorstech.com/dietitian/api/app";

  NotificationRepository();

  /// Fetch all notifications for a client / dietitian
  Future<NotificationModel> fetchNotifications(String targetId) async {
    try {
      final url = Uri.parse("$baseUrl/fetch_notification.php");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"target_id": "profile7"}),
      );


      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        return NotificationModel.fromJson(jsonData);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch notifications: $e");
    }
  }

  /// Mark a single notification as seen
  Future<bool> markAsSeen(int notificationId) async {
    try {
      final url = Uri.parse("$baseUrl/mark_notification_seen.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": notificationId}),
      );




      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["success"] == true;
      }

      return false;
    } catch (e) {
      throw Exception("Failed to update seen status: $e");
    }
  }

  /// Mark ALL notifications of a target_id as seen
  Future<bool> markAllAsSeen(String targetId) async {
    try {
      final url = Uri.parse("$baseUrl/mark_all_notifications_seen.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"target_id": "profile7"}),
      );


      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["success"] == true;
      }

      return false;
    } catch (e) {
      throw Exception("Failed to update all notifications: $e");
    }
  }

  /// Get ONLY unseen notification count (lightweight API)
  /// Get unseen notification count using fetch_notification.php
  Future<int> getUnseenCount(String targetId) async {
    try {
      final url = Uri.parse("$baseUrl/fetch_notification.php");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"target_id": targetId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // ✅ 1) If backend already sends total_not_seen_count
        if (jsonData["total_not_seen_count"] != null) {
          return int.tryParse(jsonData["total_not_seen_count"].toString()) ?? 0;
        }

        // ✅ 2) Fallback: calculate from grouped_notifications > items
        int unseenCount = 0;

        if (jsonData["grouped_notifications"] != null) {
          final grouped = jsonData["grouped_notifications"] as Map<String, dynamic>;

          grouped.forEach((key, value) {
            // If backend gives not_seen_count per group, use it
            if (value["not_seen_count"] != null) {
              unseenCount += int.tryParse(value["not_seen_count"].toString()) ?? 0;
            } else if (value["items"] != null) {
              // Otherwise, count from items with seen_status == not_seen
              final items = value["items"] as List<dynamic>;
              for (final item in items) {
                if (item["seen_status"] == "not_seen") {
                  unseenCount++;
                }
              }
            }
          });
        }

        return unseenCount;
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch unseen notification count: $e");
    }
  }


}
