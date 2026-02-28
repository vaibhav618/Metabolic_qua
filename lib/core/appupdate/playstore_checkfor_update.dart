import 'package:in_app_update/in_app_update.dart';

Future<void> checkForUpdate() async {
  try {
    final updateInfo = await InAppUpdate.checkForUpdate();

    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {

      // Flexible update (user can continue using app)
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();

      // OR Immediate update (forces update)
      // await InAppUpdate.performImmediateUpdate();
    }
  } catch (e) {
    print("In-app update error: $e");
  }
}
