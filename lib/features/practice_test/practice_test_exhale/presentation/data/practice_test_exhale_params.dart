import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../../../client-dashboard/data/model/client_profile_model.dart';

class PracticeTestExhaleParams {
  final BreathingSettings breathingSettings;
  final ClientProfileModel clientProfileModel;
  PracticeTestExhaleParams(
      {required this.breathingSettings, required this.clientProfileModel});
}
