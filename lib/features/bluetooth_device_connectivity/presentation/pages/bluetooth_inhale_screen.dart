import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_cubit.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_inhale_cubit/bluetooth_inhale_state.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../common/dialogs/improper_exhale_dialog.dart';
import '../../domain/processor/bluetooth_blow_processor.dart';
import '../widgets/device_inhale_screen.dart';
import '../widgets/inhale_getting_started.dart';

class BluetoothInhaleScreen extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const BluetoothInhaleScreen({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.breathingSettings,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => BluetoothInhaleCubit(
        ctx.read<BluetoothRepository>(),
        AudioHelper(),
        BluetoothBlowProcessor(),
      ),
      child: _BluetoothInhaleView(
        clientProfileModel: clientProfileModel,
        dietPlanStrategyModel: dietPlanStrategyModel,
        minRange: minRange,
        maxRange: maxRange,
        breathingSettings: breathingSettings,
      ),
    );
  }
}


class _BluetoothInhaleView extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  final BreathingSettings breathingSettings;

  const _BluetoothInhaleView({
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange,
    required this.maxRange, required this.breathingSettings,
  });

  Future<bool> showCancelTestDialogBox(BuildContext context, bool hold) async {
    bool didCancel = false;

    showCancelTestDialog(context, () async {
      context.read<BluetoothInhaleCubit>().sendAbort();
      if(hold) await context.read<BluetoothInhaleCubit>().setCancelOrDisconnectFlag();
      context.go(
        AppRoutes.clientDashboard,
        extra: clientProfileModel,
      );

      context.read<BluetoothInhaleCubit>().dialogDismissed();
    });

    return didCancel;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Builder(
      builder: (context) {
        // ✅ replaces initState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BluetoothInhaleCubit>().startStartCounter(from: 5);
        });

        return BlocConsumer<BluetoothInhaleCubit, BluetoothInhaleState>(
          listenWhen: (prev, curr) =>
          prev.isDialogShown != curr.isDialogShown ||
              prev.navigateToExhaleScreen != curr.navigateToExhaleScreen ||
              prev.improperBlow != curr.improperBlow,
          listener: (context, state) {
            final cubit = context.read<BluetoothInhaleCubit>();

            // 1️⃣ Improper blow – highest priority
            if (state.improperBlow && state.isDialogShown) {
              cubit.sendAbort();
              context.read<BluetoothInhaleCubit>().setCancelOrDisconnectFlag();

              showImproperExhale(
                context: context,
                tryAgainButtonClicked: () async {
                  cubit.dialogDismissed();
                  context.go(
                    AppRoutes.clientDashboard,
                    extra: clientProfileModel,
                  );
                },
                needHelpButtonCancel: () {
                  Navigator.pop(context);
                },
              );

              return; // ⛔ stop further handling
            }

            // 2️⃣ Bluetooth disconnected
            if (state.isDialogShown && !cubit.repo.isConnected) {
              showDeviceDisconnectedBox(
                context: context,
                onButtonPressed: () async {
                  context.pop();
                  cubit.dialogDismissed();

                  context.go(
                    AppRoutes.clientDashboard,
                    extra: clientProfileModel,
                  );
                },
              );

              return; // ⛔ stop further handling
            }

            // 3️⃣ Navigate to exhale screen
            if (state.navigateToExhaleScreen) {
              context.push(
                AppRoutes.bluetoothExhaleScreen,
                extra: ExhaleScreenParams(
                  clientProfileModel: clientProfileModel,
                  baseValue: state.blowExhaleBaseValue ?? "",
                  dietPlanStrategyModel: dietPlanStrategyModel,
                  minRange: minRange,
                  maxRange: maxRange,
                  breathingSettings: breathingSettings,
                ),
              );
            }
          },
          buildWhen: (prev, curr) =>
          prev.startCounter != curr.startCounter ||
              prev.startCounterFinished != curr.startCounterFinished ||
              prev.isBluetoothConnected != curr.isBluetoothConnected ||
              prev.progress != curr.progress ||
              prev.inhaleStarted != curr.inhaleStarted ||
              prev.inhaleFinished != curr.inhaleFinished ||
              prev.holdStarted != curr.holdStarted ||
              prev.holdFinished != curr.holdFinished ||
              prev.holdCounter != curr.holdCounter ||
              prev.perfectSamples != curr.perfectSamples ||
              prev.navigateToExhaleScreen != curr.navigateToExhaleScreen,
          builder: (context, state) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop) {
                  await showCancelTestDialogBox(context, state.holdStarted&&state.inhaleFinished&&!state.holdFinished);
                }
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      showCancelTestDialogBox(context, state.holdStarted&&state.inhaleFinished&&!state.holdFinished);
                    },
                  ),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                ),
                body: SafeArea(child: DeviceInhaleScreen(state: state)),
              ),
            );
          },
        );
      },
    );
  }
}


