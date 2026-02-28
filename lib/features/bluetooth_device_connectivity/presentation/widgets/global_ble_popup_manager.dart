import 'dart:async';
import 'package:flutter/material.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';

class GlobalBlePopupManager {
  static StreamSubscription<String>? _sub;

  /// Call this ONCE in main(), after creating the UuidBluetoothManager.
  static void init({
    required UuidBluetoothManager manager,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    // Avoid double-listening
    _sub?.cancel();

    _sub = manager.dataStream.listen((data) {
      // If you want to filter, do it here:
      // if (!data.startsWith("R:")) return;

      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;



      showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: const Text("Device Data Received"),
            content: Text(data),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }

  static void dispose() {
    _sub?.cancel();
  }
}
