import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _apiUrl = 'https://humorstech.com/humors_app/app_final/dieticianapp/api/send_email_otp.php';

  static Future<Map<String, dynamic>> sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        body: {
          'email': email,
          'otp': otp,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          return {
            'success': true,
            'message': jsonData['message'],
            'otp': jsonData['otp'],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Failed to send OTP.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Client error: ${e.message}',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }
}
