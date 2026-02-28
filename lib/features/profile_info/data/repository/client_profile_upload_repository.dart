import 'dart:io';
import 'package:http/http.dart' as http;

Future<bool> uploadProfileImage(String imagePath) async {
  try {
    if (!File(imagePath).existsSync()) {
      return false;
    }

    final uri = Uri.parse("https://humorstech.com/humors_app/app_final/dieticianapp/api/create_client.php");
    final request = http.MultipartRequest('POST', uri)
      ..fields['dietitian_id'] = 'diet001'
      ..fields['phone_no'] = '999999991'
      ..fields['email'] = 'test@exmle.com'
      ..fields['profile_name'] = 'John Doe'
      ..fields['age'] = '30'
      ..fields['gender'] = 'male'
      ..fields['height'] = '170'
      ..fields['weight'] = '68'
      ..fields['region'] = 'North'
      ..fields['location'] = 'Delhi'
      ..fields['password'] = '123456'
      ..files.add(await http.MultipartFile.fromPath(
        'profile_image',
        imagePath,
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();


    return response.statusCode == 200; // success check
  } catch (e) {
    return false;
  }
}
