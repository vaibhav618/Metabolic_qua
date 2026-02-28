import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/common/widgets/audio_helper.dart';
import 'package:respyr_dietitian/common/widgets/internet_connectivity_handler.dart';
import 'package:respyr_dietitian/core/services/shared_prefs_profile_data.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_breathe_tube_cubit/bluetooth_breathe_tube_state.dart';
import 'package:respyr_dietitian/common/dialogs/cancel_Test_dialog.dart';
import 'package:respyr_dietitian/common/dialogs/disconnection_dialog.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import '../../../../common/widgets/battery_indicator_widget.dart';
import '../../../../core/battery/device_battery_manager.dart';

class BluetoothBreatheTube extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final DietPlanStrategyModel dietPlanStrategyModel;
  final double minRange;
  final double maxRange;
  const BluetoothBreatheTube({super.key, required this.clientProfileModel, required this.dietPlanStrategyModel, required this.minRange, required this.maxRange});

  Future<bool> _showCancelTestDialogBox(BuildContext context) async {
    bool didCancel = false;

    showCancelTestDialog(context, () {
      context.go(AppRoutes.clientDashboard, extra: clientProfileModel);

      context.read<BluetoothBreatheTubeCubit>().dialogDismissed();
    });

    return didCancel;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (ctx) => BluetoothBreatheTubeCubit(
            ctx.read<BluetoothRepository>(),
            AudioHelper(),
          ),
      child: BlocConsumer<BluetoothBreatheTubeCubit, BluetoothBreatheTubeState>(
        listener: (context, state) async {
          final cubit = context.read<BluetoothBreatheTubeCubit>();

          if (state.isDialogShown) {
            // Disconnection Dialog
            showDeviceDisconnectedBox(
              context: context,
              onButtonPressed: () {
                cubit.dialogDismissed();
                cubit.disconnect();
                context.go(AppRoutes.clientDashboard);
              },
            );
          }

          if (state.isCompleted) {
            cubit.close();
            context.push(
              AppRoutes.bluetoothCalibrationScreen,
              extra: {
                "client" : clientProfileModel,
                "strategy" : dietPlanStrategyModel,
                "min_range" : minRange,
                "max_range" : maxRange,
              },
            );
          }
        },

        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop) {
                final shouldExit = await _showCancelTestDialogBox(context);

                if (shouldExit) {}
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: InternetConnectivityHandler(
                onConnectivityChanged: (hasInternet) {
                  context
                      .read<BluetoothBreatheTubeCubit>()
                      .handleInternetChanged(hasInternet);
                },
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed:
                                  () => _showCancelTestDialogBox(context),
                              icon: SvgPicture.asset(
                                "assets/images/common/closeicon.svg",
                              ),
                            ),
                            const Spacer(),
                            FutureBuilder<double>(
                              future: DeviceBatteryManager.getBatteryPercentage(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data! <= 0) {
                                  return const SizedBox.shrink();
                                }

                                return Row(
                                  children: [
                                    BatteryIconWidget(
                                      batteryPercentage: snapshot.data!,
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                );
                              },
                            ),
                            Visibility(
                              visible: false,
                              child: IconButton(
                                onPressed: () {
                                  context
                                      .read<BluetoothBreatheTubeCubit>()
                                      .audioHelper
                                      .toggleMute();
                                },
                                icon: BlocBuilder<
                                  BluetoothBreatheTubeCubit,
                                  BluetoothBreatheTubeState
                                >(
                                  builder: (context, state) {
                                    return Icon(
                                      context
                                              .read<BluetoothBreatheTubeCubit>()
                                              .audioHelper
                                              .isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Place the mouth tube in the slot",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.mulish(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF595959),
                            ),
                          ),
                        ),
                       // Image.asset("assets/images/gif_images/mouth_tube.gif"),
                        SizedBox(height: 50),
                        LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: const Color(0xFFE0E0E0),
                          color: Color(0xFF308BF9),
                          minHeight: 15,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading... ${(state.progress * 100).toInt()}%',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF308BF9),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
