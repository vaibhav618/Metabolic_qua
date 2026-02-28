import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/breath_setting_model.dart';

class BreathingConfigService {
  static const String _url =
      'https://humorstech.com/dietitian/api/app/breath_config.php';

  static const Duration _timeout = Duration(seconds: 10);

  static Future<BreathingSettings> fetchBreathingSettings() async {
    try {
      final response =
      await http.get(Uri.parse(_url)).timeout(_timeout);

      if (response.statusCode != 200) {
        return BreathingSettings.defaults();
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return BreathingSettings.defaults();
      }

      final settingsJson = decoded['breathing_settings'];

      if (settingsJson == null) {
        return BreathingSettings.defaults();
      }

      return BreathingSettings.fromJson(settingsJson);
    } catch (e) {
      return BreathingSettings.defaults();
    }
  }

}
