import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/bloc/practice_test_exhale_cubit.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/bloc/practice_test_exhale_state.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/data/practice_test_exhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/screens/practice_test_exhale_progress_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/screens/practice_test_exhale_start_counter_screen.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart'; // 🚨 Added for connection check

import '../../../../../core/size/get_height.dart';
import '../../../practice_test_home/bloc/practice_flow_bloc.dart';
import '../../../practice_test_home/domain/enums/practice_test.dart';

class PracticeTestExhaleScreen extends StatelessWidget {
  final PracticeTestExhaleParams practiceTestExhaleParams;

  const PracticeTestExhaleScreen({
    super.key,
    required this.practiceTestExhaleParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeTestExhaleCubit(
        context.read(),
        practiceTestExhaleParams.breathingSettings,
      ),
      child: _PracticeTestExhaleView(
        params: practiceTestExhaleParams,
      ),
    );
  }
}

class _PracticeTestExhaleView extends StatelessWidget {
  final PracticeTestExhaleParams params;

  const _PracticeTestExhaleView({required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PracticeTestExhaleCubit, PracticeTestExhaleState>(
      listenWhen: (p, c) =>
          p.isConnected != c.isConnected ||
          p.error != c.error ||
          p.exhaleFailed != c.exhaleFailed ||
          p.exhaleSuccess != c.exhaleSuccess ||
          p.navigateBack != c.navigateBack ||
          p.exhaleSuccess != c.exhaleSuccess,
      listener: (context, state) {
        // if (!state.isConnected) {
        //   _showSnack(context, "Device disconnected");
        // }

        if (state.exhaleSuccess) {
          // Marks the Exhale step as completed in the main flow
          context.read<PracticeFlowBloc>().add(
                PracticeFlowMarkCompleted(PracticeTestSteps.exhaleTest),
              );

          // Use context.go to jump back to the shell safely with the required profile extra
          context.go(
            AppRoutes.practiceFlowShell,
            extra: params.clientProfileModel,
          );
        }
      },
      child: BlocBuilder<PracticeTestExhaleCubit, PracticeTestExhaleState>(
        buildWhen: (p, c) =>
            p.startCounterStarted != c.startCounterStarted ||
            p.startCounterFinished != c.startCounterFinished ||
            p.exhaleStarted != c.exhaleStarted ||
            p.exhaleFinished != c.exhaleFinished ||
            p.exhaleFailed != c.exhaleFailed ||
            p.progress != c.progress ||
            p.showSkipButton != c.showSkipButton, // 🚨 Listen for Skip Button
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<PracticeTestExhaleCubit>().cancelTest();
                    // Safe pop check to prevent "nothing to pop" error
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.practiceFlowShell,
                          extra: params.clientProfileModel);
                    }
                  },
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _BuildView(
                  key: ValueKey(
                    "${state.startCounterStarted}-"
                    "${state.startCounterFinished}-"
                    "${state.exhaleStarted}-"
                    "${state.exhaleFinished}-"
                    "${state.exhaleFailed}-"
                    "${state.showSkipButton}", // 🚨 Include in key to force rebuild
                  ),
                  state: state,
                  settings: params.breathingSettings,
                  params: params, // 🚨 Pass params down to BuildView
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

class _BuildView extends StatelessWidget {
  final PracticeTestExhaleState state;
  final BreathingSettings settings;
  final PracticeTestExhaleParams params; // 🚨 Accept params

  const _BuildView({
    super.key,
    required this.state,
    required this.settings,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    // 🚨 ADDED: Check for compatibility timeout first
    if (state.showSkipButton) {
      return IncompatibleDeviceScreen(
        errorText: state.exhaleFailReason,
        onRetry: () {
          final isConnected = context.read<BluetoothRepository>().isConnected;
          if (isConnected) {
            context
                .read<PracticeTestExhaleCubit>()
                .restartAfterFailWithPercent();
          } else {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.practiceFlowShell,
                  extra: params.clientProfileModel);
            }
          }
        },
        onSkip: () {
          // 🚨 FIX: Abort the test entirely and go straight to Dashboard
          context.read<PracticeTestExhaleCubit>().cancelTest();
          context.go(
            AppRoutes.clientDashboard,
            extra: params.clientProfileModel,
          );
        },
      );
    }

    // 🚨 MOVED TO TOP: Failure/Disconnect logic now overrides the timer
    if (state.exhaleFailed) {
      return ExhaleFailed(
        state: state,
        onStartAgain: () {
          // Check connection status directly from the repository
          final isConnected = context.read<BluetoothRepository>().isConnected;

          if (isConnected) {
            // Proceed with normal retry
            context
                .read<PracticeTestExhaleCubit>()
                .restartAfterFailWithPercent();
          } else {
            // Disconnected: Force navigation back to Practice Menu
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                AppRoutes.practiceFlowShell,
                extra: params.clientProfileModel,
              );
            }
          }
        },
      );
    }

    if (!state.startCounterFinished) {
      return PracticeTestExhaleStartCounterScreen(state: state);
    }

    if (state.startCounterFinished && !state.exhaleFailed) {
      return PracticeTestExhaleProgressScreen(
        state: state,
        breathingSettings: settings,
      );
    }

    return const SizedBox.shrink();
  }
}

class ExhaleFailed extends StatelessWidget {
  final PracticeTestExhaleState state;
  final VoidCallback onStartAgain;

  const ExhaleFailed({
    super.key,
    required this.state,
    required this.onStartAgain,
  });

  bool _contains(String s, String q) =>
      s.toLowerCase().contains(q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final raw = ((state.exhaleFailReason ?? "").trim().isNotEmpty
            ? state.exhaleFailReason!
            : (state.error ?? ""))
        .trim();

    final e = raw.toLowerCase();

    final isInhale = _contains(e, "inhale");
    final timeout = _contains(e, "too long") ||
        _contains(e, "timeout") ||
        _contains(e, "no response") ||
        _contains(e, "no exhale detected within 30 seconds");

    // 🚨 NEW: Detect disconnects
    final isDisconnected = _contains(e, "disconnect");

    debugPrint("exhale error : $e");

    // 🚨 ADDED: Dedicated Disconnected Screen
    if (isDisconnected) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Connection Lost",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(
              height: rh(context: context, px: 25),
            ),
            Text(
              raw.isEmpty ? "Device disconnected. Please reconnect." : raw,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),
            const Expanded(child: SizedBox()),
            _buildButton(context, isDisconnected: true), // Will show "Go Back"
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (isInhale) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You breathed air in\nInstead of out",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_inhale_exhale_screen.png",
              ),
            ),
            _buildButton(context, isDisconnected: false),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (timeout) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You took too long to\nexhale.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
            SizedBox(height: rh(context: context, px: 37)),
            Expanded(
              child: Image.asset(
                "assets/images/device_connection/img_exhale_timeout.png",
              ),
            ),
            _buildButton(context, isDisconnected: false),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    // 🚨 UPDATED DEFAULT FALLBACK: "Keep the ball in range" is now shown for all unhandled drops/failures
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        children: [
          const Spacer(),
          Center(
              child: Image.asset(
            "assets/images/device_connection/img_inhale_exhale_dropped.png",
          )),
          SizedBox(
            height: rh(context: context, px: 48),
          ),
          Center(
            child: Text(
              "Keep the ball in the\nrange for longer",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -1),
              ),
            ),
          ),
          const Spacer(),
          _buildButton(context, isDisconnected: false),
          SizedBox(
            height: rh(context: context, px: 20),
          ),
        ],
      ),
    );
  }

  // 🚨 Helper widget to keep code clean and switch text if disconnected
  Widget _buildButton(BuildContext context, {required bool isDisconnected}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onStartAgain,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF308BF9),
              padding: EdgeInsetsGeometry.symmetric(
                  vertical: rh(context: context, px: 16)),
              elevation: 0),
          child: Text(
            isDisconnected ? "Go Back" : "Start Again",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w700,
                height: rh(context: context, px: 1.0),
                letterSpacing: rh(context: context, px: 0.30)),
          )),
    );
  }
}

// 🚨 NEW WIDGET: Displayed ONLY when device ignores us for 8 seconds
class IncompatibleDeviceScreen extends StatelessWidget {
  final String errorText;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  const IncompatibleDeviceScreen({
    super.key,
    required this.errorText,
    required this.onRetry,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Device Not Responding",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 25),
              fontWeight: FontWeight.w600,
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
            ),
          ),
          SizedBox(height: rh(context: context, px: 25)),
          Text(
            "Your device may not support the Practice Test stream. You can try again or skip this step.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              height: rh(context: context, px: 1.30),
              letterSpacing: rh(context: context, px: -0.30),
            ),
          ),
          const Spacer(),

          // Retry Button (Outlined)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF308BF9), width: 2),
                padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 16)),
              ),
              child: Text(
                "Try Again",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF308BF9),
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 12)),

          // Skip Button (Filled Blue)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSkip,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF308BF9),
                padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 16)),
                elevation: 0,
              ),
              child: Text(
                "Skip Practice Test",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: rh(context: context, px: 20)),
        ],
      ),
    );
  }
}
