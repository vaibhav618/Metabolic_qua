import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../core/url-manager/url_manager.dart';

Future<ClientProfileModel?> checkClientProfile({required String userEmail}) async {
  final url = Uri.parse(UrlManager().urlUserCheckProfile);


  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": userEmail}),
    );



    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }


    final success = jsonBody['success'] == true;
    if (!success) {
      return null;
    }

    // Ensure token exists
    final token = jsonBody['token'];
    if (token == null || token is! String || token.isEmpty) {
      return null;
    }


    try {
      // Decode JWT
      final Map<String, dynamic> decoded = JwtDecoder.decode(token);

      if (!decoded.containsKey('profile')) {
        return null;
      }

      final profileJson = decoded['profile'];
      if (profileJson is! Map<String, dynamic>) {
        return null;
      }

      // Create ClientProfileModel from decoded profile
      final client = ClientProfileModel.fromJson(profileJson);

      return client;
    } catch (e) {
      return null;
    }
  } catch (e) {
    return null;
  }
}
