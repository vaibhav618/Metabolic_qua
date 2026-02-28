import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/client_profile_model.dart';

class ClientRepository {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://humorstech.com/humors_app/app_final/dieticianapp/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );

  Future<List<ClientProfileModel>> fetchClients(String profileId) async {
    try {
      final response = await dio.post(
        'get_clients.php',
        data: {
          'profile_id': profileId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          // let us inspect non-200 responses instead of throwing
          validateStatus: (_) => true,
        ),
      );

      // Helpful debug:
      print('HTTP ${response.statusCode} -> ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }



      // Some hosts return string body; normalize to Map
      final body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data as Map<String, dynamic>;

      if (body['success'] == true) {
        final List list = body['data'] ?? [];



        return list.map((e) => ClientProfileModel.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to load clients');
      }
    } catch (e) {
      throw Exception('Client fetch failed: $e');
    }
  }
}
