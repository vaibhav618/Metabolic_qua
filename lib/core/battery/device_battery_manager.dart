import 'package:shared_preferences/shared_preferences.dart';

class DeviceBatteryManager {
  static const String _keyDeviceBatteryPercentage = "device_battery_percentage";

  /// Save battery percentage
  static Future<void> setBatteryPercentage(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDeviceBatteryPercentage, value);
  }

  /// Get battery percentage
  static Future<double> getBatteryPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDeviceBatteryPercentage) ?? 0.0;
  }

  /// Clear battery value (optional)
  static Future<void> clearBatteryPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceBatteryPercentage);
  }
}
