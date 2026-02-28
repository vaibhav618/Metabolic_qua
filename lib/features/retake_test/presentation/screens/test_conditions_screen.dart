import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';

import '../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../routes/app_routes.dart';
import '../theme/test_conditions_tokens.dart';
import '../widgets/test_conditions_bottom_cta.dart';
import '../widgets/test_conditions_header.dart';
import '../widgets/test_conditions_sheet.dart';

class TestConditionsScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  final ui = UuidBluetoothManager();

  TestConditionsScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        cancelTest(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: TestConditionsTokens.appBarBlue,
          actions: [
            Semantics(
              button: true,
              label: 'Close',
              child: IconButton(
                onPressed: () => cancelTest(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TestConditionsTokens.gradientColors,
                stops: TestConditionsTokens.gradientStops,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TestConditionsHeader(),
                Expanded(child: TestConditionsSheet()),
              ],
            ),
          ),
        ),
        bottomNavigationBar: TestConditionsBottomCta(
          confirmedToNavigate: () async {
            final connected =  FlutterBluePlus.connectedDevices;

            if (connected.isNotEmpty) {
              _navigateToBluetooth(context);
            } else {
              showDeviceDisconnectedBox(
                context: context,
                onButtonPressed: () {
                  ui.clearAllConnections();
                  navigateToDashboard(context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  void cancelTest(BuildContext context) {
    showCancelTestDialog(context, () {
      ui.clearAllConnections();
      navigateToDashboard(context);
    });
  }

  void navigateToDashboard(BuildContext context) {
    context.go(
      AppRoutes.clientDashboard,
      extra: clientProfileModel,
    );
  }

  void _navigateToBluetooth(BuildContext context) {
    context.push(
      AppRoutes.bluetoothCalibrationScreen,
      extra: {
        "client": clientProfileModel,
        "strategy": dietPlanStrategyModel,
        "min_range": minRange,
        "max_range": maxRange,
      },
    );
  }
}
