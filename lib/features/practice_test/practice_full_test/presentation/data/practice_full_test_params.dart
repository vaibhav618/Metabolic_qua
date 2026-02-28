import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import '../../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';

class PracticeFullTestParams {
  final BreathingSettings breathingSettings;
  final ClientProfileModel clientProfileModel;

  PracticeFullTestParams({
    required this.breathingSettings,
    required this.clientProfileModel,
  });
}
