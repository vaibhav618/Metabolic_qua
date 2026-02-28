import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../client-dashboard/extras/device_info_manager.dart';
import '../core/url-manager/url_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class FCMService {
  static StreamSubscription<String>? _refreshSub;

  /// Call this once in main() after Firebase.initializeApp()
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Foreground notifications
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'Used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  /// Save token to your server
  static Future<void> saveTokenToServer(String userId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final String? fcmToken = await _waitForFcmToken(messaging);

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint("FCM token is null or empty");
        return;
      }

      final deviceId = await DeviceInfoManager().getDeviceId();
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown';
      final url = Uri.parse(UrlManager().urlSaveFcmToken);

      // Save initial token
      await http.post(url, body: {
        'user_id': userId,
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'platform': platform,
      });

      debugPrint("FCM Token saved: $fcmToken");

      // Listen for refresh
      _refreshSub?.cancel();
      _refreshSub = messaging.onTokenRefresh.listen((newToken) async {
        await http.post(url, body: {
          'user_id': userId,
          'device_id': deviceId,
          'fcm_token': newToken,
          'platform': platform,
        });
        debugPrint("FCM Token refreshed + saved");
      });
    } catch (e, s) {
      debugPrint("Error saving token: $e\n$s");
    }
  }

  static Future<String?> _waitForFcmToken(FirebaseMessaging messaging) async {
    const int maxAttempts = 12;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        final msg = e.toString();
        if (!msg.contains('apns-token-not-set')) rethrow;
        debugPrint("Attempt $attempt: APNs not ready yet");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }
}

/// Background handler (killed / background)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
