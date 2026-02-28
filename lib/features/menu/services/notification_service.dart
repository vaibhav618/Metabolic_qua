import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://humorstech.com/humors_app/app_final/dieticianapp/api/',
    ),
  );

  Future<bool> updateNotification({
    required String profileId,
    required bool isEnabled,
  }) async {
    try {
      final res = await _dio.post(
        'update_notification_status.php',
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'profile_id': profileId,
          'is_notification_enabled': isEnabled ? 1 : 0,
        },
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
