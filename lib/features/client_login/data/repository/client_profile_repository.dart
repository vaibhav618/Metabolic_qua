import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../client-dashboard/data/model/client_profile_model.dart';



class ClientProfileRepository {
  Future<ClientProfileModel> checkClientProfile({
    required String phoneNo,
    required String email,
  }) async {
    final url = Uri.parse("https://humorstech.com/humors_app/app_final/dieticianapp/api/check_client_profile.php");

    final response = await http.post(url, body: {
      'phone_no': phoneNo,
      'email': email,
    });

    final jsonBody = json.decode(response.body);

    if (response.statusCode == 200 && jsonBody['success'] == true) {
      return ClientProfileModel.fromJson(jsonBody['data']);
    } else {
      throw Exception(jsonBody['message'] ?? "Client profile not found");
    }
  }
}
