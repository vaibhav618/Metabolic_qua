import 'package:permission_handler/permission_handler.dart';

Future<void> askNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}