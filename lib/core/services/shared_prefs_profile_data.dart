import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

class ClientProfilePrefs {
  static const _key = 'client_profile_model';

  static Future<void> saveClientProfile(ClientProfileModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(model.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<ClientProfileModel?> getClientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    try {
      final jsonMap = jsonDecode(jsonString);
      return ClientProfileModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
