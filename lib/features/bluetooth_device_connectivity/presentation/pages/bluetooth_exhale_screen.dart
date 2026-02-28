import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/exhale_timeout_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/improper_exhale_dialog.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/processor/bluetooth_blow_processor.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_exhale_cubit.dart/bluetooth_exhale_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_exhale_cubit.dart/bluetooth_exhale_state.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/new_exhale_screen.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/old_exhale_screen.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class BluetoothExhaleScreen extends StatelessWidget {
  final String baseValue;
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;

  const BluetoothExhaleScreen({
    super.key,
    required this.baseValue,
    required this.clientProfileModel,
    required this.dietPlanStrategyModel,
    required this.minRange, required this.maxRange,
  });

  Future<bool> showCancelTestDialogBox(BuildContext context) async {
    bool didCancel = false;
    showCancelTestDialog(context, () {
      context.read<BluetoothExhaleCubit>().sendAbort();
      Future.microtask(() async {
        if (!context.read<BluetoothExhaleCubit>().isClosed) {
          await context.read<BluetoothExhaleCubit>().setCancelOrDisconnectFlag();
        }
      });
      context.go(AppRoutes.clientDashboard, extra: clientProfileModel);
      context.read<BluetoothExhaleCubit>().dialogDismissed();
    });

    return didCancel;
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await showCancelTestDialogBox(context);
          if (shouldExit) {}
        }
      },
      child: BlocProvider(
        create: (ctx) => BluetoothExhaleCubit(
          processor: BluetoothBlowProcessor(),
          repo: ctx.read<BluetoothRepository>(),
          baseValue: baseValue,
          audioHelper: AudioHelper(),
        ),
        child: BlocConsumer<BluetoothExhaleCubit, BluetoothExhaleState>(
          listener: (context, state) async {
            if (!context.mounted) return;

            // ✅ If not current route, do nothing (prevents dialog/navigation glitches)
            if (ModalRoute.of(context)?.isCurrent != true) return;

            // ✅ PRIORITY 1: navigate to results, and STOP listener flow
            if (state.exhaleComplete) {
              final processor = context.read<BluetoothExhaleCubit>().processor;

              final maxPR = processor.blowValuesList.isNotEmpty
                  ? processor.blowValuesList.reduce((a, b) => a > b ? a : b)
                  : 0.0;

              final bestPR = processor.blowValuesList.isNotEmpty
                  ? processor.blowValuesList.reduce((a, b) => a + b) /
                  processor.blowValuesList.length
                  : 0.0;

              final duration = processor.blowDuration;

              final allValues = [
                ...processor.baseBlowValueList,
                ...processor.blowValuesList,
              ];

              final params = GeneratingResultParams(
                maxPressure: maxPR,
                bestPressure: bestPR,
                blowDuration: duration,
                blowValuesList: allValues,
                clientProfileModel: clientProfileModel,
                dietPlanStrategyModel: dietPlanStrategyModel,
                minRange: minRange,
                maxRange: maxRange,
              );

              context.read<BluetoothExhaleCubit>().stop();
              if (!context.mounted) return;
              if (ModalRoute.of(context)?.isCurrent != true) return;

              context.pushReplacement(
                AppRoutes.bluetoothGeneratingResultScreen,
                extra: params,
              );

              return;
            }

            // ✅ PRIORITY 2: dialogs only if exhaleComplete is false
            switch (state.activeDialog) {
              case ActiveDialog.disconnect:
                Future.microtask(() async {
                  if (!context.read<BluetoothExhaleCubit>().isClosed) {
                    context.read<BluetoothExhaleCubit>().stop();
                    context.read<BluetoothExhaleCubit>().dialogDismissed();
                    context.read<BluetoothExhaleCubit>().setCancelOrDisconnectFlag();
                  }
                });

                showDeviceDisconnectedBox(
                  context: context,
                  onButtonPressed: () async {
                    context.go(
                      AppRoutes.clientDashboard,
                      extra: clientProfileModel,
                    );
                  },
                ).then((_) {
                  if (context.mounted) {
                    context.read<BluetoothExhaleCubit>().dialogDismissed();
                  }
                });
                break;

              case ActiveDialog.timeout:

                Future.microtask(() async {
                  if (!context.read<BluetoothExhaleCubit>().isClosed) {
                    context.read<BluetoothExhaleCubit>().stop();
                    context.read<BluetoothExhaleCubit>().dialogDismissed();
                    context.read<BluetoothExhaleCubit>().setCancelOrDisconnectFlag();
                  }
                });

                showExhaleSessionTimeOutDialog(
                  context: context,
                  onButtonPressed: () async {
                    context.go(
                      AppRoutes.clientDashboard,
                      extra: clientProfileModel,
                    );
                  },
                ).then((_) {
                  if (context.mounted) {
                    context.read<BluetoothExhaleCubit>().dialogDismissed();
                  }
                });
                break;

              case ActiveDialog.improper:
                Future.microtask(() async {
                  if (!context.read<BluetoothExhaleCubit>().isClosed) {
                    context.read<BluetoothExhaleCubit>().abortBlow();
                    context.read<BluetoothExhaleCubit>().dialogDismissed();
                    context.read<BluetoothExhaleCubit>().setCancelOrDisconnectFlag();
                  }
                });
                showImproperExhale(
                  context: context,
                  tryAgainButtonClicked: () async {
                    context.go(
                      AppRoutes.clientDashboard,
                      extra: clientProfileModel,
                    );
                  },
                  needHelpButtonCancel: () {
                    Navigator.pop(context);
                  },
                );
                break;

              case ActiveDialog.none:
                break;
            }
          },
          builder: (context, state) {
            if (state.textError != null) {
              return Scaffold(
                body: Center(
                  child: Text(
                    state.textError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    showCancelTestDialogBox(context);
                  },
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
              ),

              body: SafeArea(
                child: NewExhaleScreen(state: state, onCloseButtonPressed: (){
                  showCancelTestDialogBox(context);
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
