import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

import '../../data/model/test_result_data_model_v2.dart';

class ResultScreenParams {
  final GeneratingResultModel result;
  final ClientProfileModel clientProfileModel;

  ResultScreenParams({required this.result, required this.clientProfileModel});
}

class ResultScreenParamsNew {
  final TestResultResponse result;
  final ClientProfileModel clientProfileModel;

  ResultScreenParamsNew({required this.result, required this.clientProfileModel});
}

