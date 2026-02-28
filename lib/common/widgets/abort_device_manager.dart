import 'package:shared_preferences/shared_preferences.dart';

class AbortDeviceManager {
  static const String _keyCancelOrDisconnectTime = 'cancel_or_disconnect_time';

  /// Checks if the device was aborted within the last 60 seconds.
  static Future<bool> getAbortStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTimeStr = prefs.getString(_keyCancelOrDisconnectTime);

    if (storedTimeStr != null) {
      final storedTime = DateTime.tryParse(storedTimeStr);
      if (storedTime != null) {
        final now = DateTime.now();
        final diffInSeconds = now.difference(storedTime).inSeconds;
        final remaining = 35 - diffInSeconds;

        return remaining > 0;
      }
    }

    return false;
  }

  /// Optionally add this helper to store the abort time
  static Future<void> saveAbortTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyCancelOrDisconnectTime,
      DateTime.now().toIso8601String(),
    );
  }

  /// Optionally clear the abort time
  static Future<void> clearAbortTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCancelOrDisconnectTime);
  }
}
