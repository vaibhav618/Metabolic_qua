import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/common/dialogs/device_low_battery.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/practice_test/data/services/practice_service.dart';
import 'package:respyr_dietitian/features/practice_test/practice_full_test/presentation/data/practice_full_test_params.dart';

import '../../../../../core/size/get_height.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import '../../../../bluetooth_device_connectivity/data/services/breathing_config_service.dart';
import '../../bloc/practice_flow_bloc.dart';
import '../../domain/enums/practice_test.dart';
import '../widgets/practice_menu.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/data/practice_test_inhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/data/practice_test_exhale_params.dart';

class PracticeTestScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const PracticeTestScreen({super.key, required this.clientProfileModel});

  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  bool _isSavingProgress = false;
  bool _isNavigatingAway = false; // 🚨 1. ADD THE SILENCER FLAG
  bool _requireManualReconnect =
      false; // 🚨 REQUIRES MANUAL RECONNECT AFTER DISCONNECT

  // 🚨 Catch-All Battery Trap Variables
  StreamSubscription<String>? _bleTrapSub;
  String _rawBuffer = "";

  static const List<PracticeTestSteps> _steps = [
    PracticeTestSteps.connect,
    PracticeTestSteps.inhaleTest,
    PracticeTestSteps.exhaleTest,
    PracticeTestSteps.fullTest,
  ];

  @override
  void initState() {
    super.initState();
    _startLowBatteryTrap();
  }

  // 🚨 THE TRAP: Listens for fragmented battery errors in the background
  void _startLowBatteryTrap() {
    final repo = context.read<BluetoothRepository>();

    _bleTrapSub = repo.receivedDataStream().listen((data) {
      if (data.isEmpty) return;

      _rawBuffer += data; // Stitch fragments

      // Spring the trap if the error is detected
      if (_rawBuffer.contains("ERROR") && _rawBuffer.contains("003")) {
        _showLowBatteryDialog();
      }

      // Keep memory light
      if (_rawBuffer.length > 50) {
        _rawBuffer = "";
      }
    });
  }

  void _showLowBatteryDialog() {
    _bleTrapSub?.cancel(); // Cancel trap so it doesn't trigger repeatedly

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: DeviceLowBattery(
          message:
              "Battery level is too low. Please charge your device to take a test.",
          onOk: () {
            try {
              context.read<BluetoothRepository>().sendData("&");
            } catch (_) {}

            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.clientDashboard,
                extra: widget.clientProfileModel);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bleTrapSub?.cancel(); // Clean up trap on exit
    super.dispose();
  }

  void _goConnect(BuildContext context) {
    // 🚨 Reset the manual flag because the user is properly initiating the connection
    setState(() {
      _requireManualReconnect = false;
    });

    context.push(
      '${AppRoutes.practiceFlowShell}/${AppRoutes.startDeviceScreen}',
      extra: widget.clientProfileModel,
    );
  }

  void _goInhale(BuildContext context, BreathingSettings settings) {
    context.pushReplacement(
      // Use pushReplacement to kill background Cubits
      '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceTestInhaleScreen}',
      extra: PracticeTestInhaleParams(
        breathingSettings: settings,
        clientProfileModel: widget.clientProfileModel,
      ),
    );
  }

  void _goExhale(BuildContext context, BreathingSettings settings) {
    context.pushReplacement(
      // Use pushReplacement to kill background Cubits
      '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceTestExhaleScreen}',
      extra: PracticeTestExhaleParams(
        breathingSettings: settings,
        clientProfileModel: widget.clientProfileModel,
      ),
    );
  }

  void _goFullTest(BuildContext context, BreathingSettings settings) {
    // Make sure to import PracticeFullTestParams at the top of this file
    context.push(
      '${AppRoutes.practiceFlowShell}/${AppRoutes.practiceFullTestScreen}',
      extra: PracticeFullTestParams(
        breathingSettings: settings,
        clientProfileModel: widget
            .clientProfileModel, // Ensure clientProfileModel is accessible here
      ),
    );
  }

  Widget _divider(BuildContext context) => Column(
        children: [
          SizedBox(height: rh(context: context, px: 20)),
          Container(
            height: rh(context: context, px: 1),
            color: const Color(0xFFD9D9D9),
          ),
          SizedBox(height: rh(context: context, px: 20)),
        ],
      );

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // 🚨 Mute snackbars during navigation
              _isNavigatingAway = true;

              // Force disconnect to un-check the "Connect" step
              final repo = context.read<BluetoothRepository>();
              try {
                if (repo.isConnected) {
                  repo.sendData("&"); // Sleep the device
                  repo.disconnect();
                }
              } catch (_) {}

              // SAFE POP: Check if there is history.
              if (context.canPop()) {
                context.pop();
              } else {
                // If no history (because of pushReplacement), force navigation back to the dashboard
                context.go(
                  AppRoutes.clientDashboard,
                  extra: widget.clientProfileModel,
                );
              }
            },
            icon: Icon(
              Icons.close,
              size: rh(context: context, px: 22),
              color: const Color(0xFF252525),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rh(context: context, px: 20),
            vertical: rh(context: context, px: 20),
          ),
          child: FutureBuilder<BreathingSettings>(
            future: BreathingConfigService.fetchBreathingSettings(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError || !snap.hasData) {
                return Center(
                  child: Text(
                    "Unable to load settings",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              final settings = snap.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Practice using your\nRespyr device",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 25),
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 28)),
                  Expanded(
                    child: BlocConsumer<PracticeFlowBloc, PracticeFlowState>(
                      listenWhen: (p, c) =>
                          p.isConnected != c.isConnected ||
                          p.bleError != c.bleError,
                      listener: (context, state) {
                        // 🚨 2. IF NAVIGATING AWAY, IGNORE ALL BLUETOOTH ERRORS
                        if (_isNavigatingAway) return;

                        if (!state.isConnected) {
                          if (!_requireManualReconnect) {
                            _showSnack(context,
                                "Device disconnected. Please reconnect.");
                            // 🚨 Force a disconnect so it doesn't auto-reconnect in background and skip the flow
                            try {
                              context.read<BluetoothRepository>().disconnect();
                            } catch (_) {}

                            setState(() {
                              _requireManualReconnect = true;
                            });
                          }
                        }

                        final err = state.bleError;
                        if (err != null && err.trim().isNotEmpty) {
                          _showSnack(context, err);
                        }
                      },
                      builder: (context, state) {
                        final bool areAllTestsCompleted =
                            _steps.every((step) => state.isCompleted(step));

                        return Column(
                          children: [
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _steps.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, __) => _divider(context),
                              itemBuilder: (context, index) {
                                final step = _steps[index];
                                final enabled = state.isEnabled(step);

                                // FORCE connection status to map to completion dynamically
                                // 🚨 Combine with manual reconnect flag so background connects don't fake completion
                                bool completed = state.isCompleted(step);
                                if (step == PracticeTestSteps.connect) {
                                  completed = state.isConnected &&
                                      !_requireManualReconnect;
                                }

                                return PracticeMenu(
                                  enabled: enabled,
                                  isStepCompleted: completed,
                                  practiceTestStep: step,
                                  onItemClicked: () {
                                    if (!enabled) return;

                                    if (step == PracticeTestSteps.connect) {
                                      _goConnect(context);
                                      return;
                                    }

                                    // Check connection for all breath tests
                                    // 🚨 Reject if disconnected OR if they are required to do manual flow
                                    if (!state.isConnected ||
                                        _requireManualReconnect) {
                                      _showSnack(
                                          context, "Connect the device first");
                                      return;
                                    }

                                    if (step == PracticeTestSteps.inhaleTest) {
                                      _goInhale(context, settings);
                                    } else if (step ==
                                        PracticeTestSteps.exhaleTest) {
                                      _goExhale(context, settings);
                                    } else if (step ==
                                        PracticeTestSteps.fullTest) {
                                      // THE FIX: Trigger the Full Test flow
                                      _goFullTest(context, settings);
                                    }
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: rh(context: context, px: 61),
                              child: Visibility(
                                visible: areAllTestsCompleted,
                                child: ElevatedButton(
                                  onPressed: _isSavingProgress
                                      ? null
                                      : () async {
                                          if (areAllTestsCompleted) {
                                            final router = GoRouter.of(context);
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            final repo = context
                                                .read<BluetoothRepository>();

                                            setState(
                                                () => _isSavingProgress = true);

                                            try {
                                              debugPrint(
                                                  "🚀 1. Calling API...");
                                              await PracticeService()
                                                  .markPracticeAsDone(widget
                                                      .clientProfileModel
                                                      .profileId);
                                              debugPrint("🚀 2. API Success!");

                                              // 🚨 3. ENGAGE SILENCER!
                                              _isNavigatingAway = true;
                                              messenger
                                                  .clearSnackBars(); // Wipe any existing snackbars

                                              // 🚨 4. TURN OFF HARDWARE
                                              try {
                                                if (repo.isConnected) {
                                                  repo.sendData(
                                                      "&"); // Sleep command
                                                  // Give the hardware 100ms to read it, then sever the connection
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 100),
                                                      () {
                                                    repo.disconnect();
                                                  });
                                                }
                                              } catch (e) {
                                                debugPrint(
                                                    "Hardware sleep error ignored: $e");
                                              }

                                              // 5. NAVIGATE TO DASHBOARD
                                              router.go(
                                                AppRoutes.clientDashboard,
                                                extra:
                                                    widget.clientProfileModel,
                                              );
                                            } catch (e) {
                                              debugPrint("🛑 CAUGHT ERROR: $e");

                                              _isNavigatingAway =
                                                  false; // Un-mute if API failed

                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Error saving progress. Try again."),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );

                                              if (mounted) {
                                                setState(() =>
                                                    _isSavingProgress = false);
                                              }
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Complete the steps above")),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF308BF9),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: _isSavingProgress
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Begin Your Journey",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            height: 1.10,
                                            letterSpacing: 0.30,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
