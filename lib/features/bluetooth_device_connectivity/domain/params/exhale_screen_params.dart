import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';

class ExhaleScreenParams {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final String baseValue;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  ExhaleScreenParams({
    required this.clientProfileModel,
    required this.baseValue,
    required this.dietPlanStrategyModel, required this.minRange, required this.maxRange,
    required this.breathingSettings,
  });
}
