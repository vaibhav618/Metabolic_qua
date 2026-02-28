import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';

import '../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/size/get_height.dart' show rh;

import '../../../bluetooth_device_connectivity/data/datasource/bluetooth_manager.dart';
import '../../../bluetooth_device_connectivity/presentation/cubit/bluetooth_connection_cubit/bluetooth_connection_cubit.dart';
import '../../bloc/retake_test_cubit.dart';
import '../../bloc/retake_test_state.dart';
import '../theme/retake_test_tokens.dart';
import '../widgets/retake_test_continue_button.dart';
import '../widgets/retake_test_options.dart';
import '../widgets/retake_test_title.dart';

class RetakeTestScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const RetakeTestScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange,
  });

  @override
  State<RetakeTestScreen> createState() => _RetakeTestScreenState();
}

class _RetakeTestScreenState extends State<RetakeTestScreen> {
  late final TextEditingController _detailsController;
  late final RetakeTestCubit _cubit;
  final ui = UuidBluetoothManager();

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController();
    _cubit = RetakeTestCubit();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        cancelTest();
      },
      child: BlocProvider<RetakeTestCubit>.value(
        value: _cubit,
        child: BlocListener<RetakeTestCubit, RetakeTestState>(
          listenWhen: (p, n) => p.submitted != n.submitted && n.submitted == true,
          listener: (context, state) async {
            final connected = await FlutterBluePlus.connectedDevices;

            if (connected.isNotEmpty) {
              context.go(
                AppRoutes.testConditionScreen,
                extra: {
                  "client": widget.clientProfileModel,
                  "strategy": widget.dietPlanStrategyModel,
                  "min_range": widget.minRange,
                  "max_range": widget.maxRange,
                },
              );
            } else {
              showDeviceDisconnectedBox(
                context: context,
                onButtonPressed: () {
                  navigateToDashboard();
                },
              );
            }
          },
          child: Scaffold(
            backgroundColor: RetakeTestTokens.pageBg,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: RetakeTestTokens.pageBg,
              surfaceTintColor: RetakeTestTokens.pageBg,
              actions: [
                Semantics(
                  button: true,
                  label: 'Close',
                  child: IconButton(
                    onPressed: cancelTest,
                    icon: const Icon(Icons.close),
                  ),
                ),
                SizedBox(width: rh(context: context, px: 10)),
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: rh(context: context, px: 90)),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RetakeTestTokens.gapTop,
                          const RetakeTestTitle(),
                          RetakeTestTokens.gapAfterTitle,
                          RetakeTestOptions(detailsController: _detailsController),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 0),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const SafeArea(
                        top: false,
                        child: RetakeTestContinueButton(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void cancelTest() {
    showCancelTestDialog(context, () {
      ui.clearAllConnections();
      navigateToDashboard();
    });
  }

  void navigateToDashboard() {
    context.go(
      AppRoutes.clientDashboard,
      extra: widget.clientProfileModel,
    );
  }
}
