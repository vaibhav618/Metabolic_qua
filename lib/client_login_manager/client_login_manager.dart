import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../client-dashboard/data/model/client_profile_model.dart';


class ClientLoginManager{
  Future<bool> saveClientProfile(ClientProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(profile.toJson());
      final result = await prefs.setString('client_profile', jsonString);
      return result;
    } catch (e) {
      return false;
    }
  }
  Future<ClientProfileModel?> loadClientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('client_profile');
    if (jsonString == null) return null;

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return ClientProfileModel.fromJson(jsonMap);
  }

  Future<bool> clearClientProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove('client_profile');
      return result;
    } catch (e) {
      return false;
    }
  }
}