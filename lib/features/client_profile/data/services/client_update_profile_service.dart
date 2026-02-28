import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../client-dashboard/data/model/client_profile_model.dart';


class ClientUpdateProfileService {
  static const _url = 'https://humorstech.com/humors_app/app_final/dieticianapp/api/update_client.php';

  static Future<ClientProfileModel?> updateProfile({
    required String profileId,
    Map<String, String> updates = const {},
  }) async {
    final body = {'profile_id': profileId, ...updates};
    final res = await http.post(Uri.parse(_url), body: body);
    if (res.statusCode != 200) return null;

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    if (jsonMap['success'] == true && jsonMap['data'] != null) {
      return ClientProfileModel.fromJson(jsonMap['data']);
    }
    return null;
  }
}
