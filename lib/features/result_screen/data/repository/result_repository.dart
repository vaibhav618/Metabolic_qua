// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/result_model.dart';

// class ResultRepository {
//   Future<ResultModel> fetchResults(String loginId, String profileId) async {
//     final url = Uri.parse('https://humorstech.com/humors_app/app_final/fetch_history3.php?login_id=$loginId&profile_id=$profileId');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return ResultModel.fromJson(data['data'][0]);
//     } else {
//       throw Exception('Failed to load results');
//     }
//   }
// }

import 'package:respyr_dietitian/features/result_screen/data/models/result_model.dart';

class ResultRepository {
  Future<ResultModel> fetchResults() async {
    await Future.delayed(Duration(seconds: 1));

    return ResultModel.dummy();
  }
}
