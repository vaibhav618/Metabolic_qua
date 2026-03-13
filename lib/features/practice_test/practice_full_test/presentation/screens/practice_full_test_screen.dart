import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/bloc/practice_flow_bloc.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/domain/enums/practice_test.dart';

import '../../../../../core/size/get_height.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import '../../../../bluetooth_device_connectivity/presentation/widgets/inhale_failed.dart';

import '../../bloc/practice_full_test_cubit.dart';
import '../../bloc/practice_full_test_state.dart';
import '../data/practice_full_test_params.dart';

// Update these imports to match exactly where your files are located
import 'full_test_progress_screen.dart';
import 'full_test_start_counter_screen.dart';

class PracticeFullTestScreen extends StatelessWidget {
  final PracticeFullTestParams practiceFullTestParams;

  const PracticeFullTestScreen(
      {super.key, required this.practiceFullTestParams});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PracticeFullTestCubit(
        context.read<BluetoothRepository>(),
        practiceFullTestParams.breathingSettings,
      ),
      child: _PracticeFullTestView(params: practiceFullTestParams),
    );
  }
}

class _PracticeFullTestView extends StatelessWidget {
  final PracticeFullTestParams params;

  const _PracticeFullTestView({required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PracticeFullTestCubit, PracticeFullTestState>(
      listenWhen: (p, c) =>
          p.phase != c.phase || p.navigateBack != c.navigateBack,
      listener: (context, state) {
        if (state.phase == FullTestPhase.success) {
          // Mark Full Test as Completed!
          context.read<PracticeFlowBloc>().add(
                const PracticeFlowMarkCompleted(PracticeTestSteps.fullTest),
              );

          context.go(
            AppRoutes.practiceFlowShell,
            extra: params.clientProfileModel,
          );
        }

        if (state.navigateBack) {
          context.go(
            AppRoutes.practiceFlowShell,
            extra: params.clientProfileModel,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const SizedBox(),
          actions: [
            IconButton(
              onPressed: () {
                context.read<PracticeFullTestCubit>().cancelTest();
                // SAFE POP FIX
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    AppRoutes.practiceFlowShell,
                    extra: params.clientProfileModel,
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
          child: SizedBox.expand(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _BuildView(params: params),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildView extends StatelessWidget {
  final PracticeFullTestParams params;

  const _BuildView({required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PracticeFullTestCubit, PracticeFullTestState>(
      builder: (context, state) {
        // 1. Error Handling (Uses correct error screen based on phase)
        if (state.isFailed) {
          // 🚨 Helper function to handle routing based on connection status
          void handleStartAgain() {
            final isConnected = context.read<BluetoothRepository>().isConnected;
            if (isConnected) {
              context
                  .read<PracticeFullTestCubit>()
                  .restartAfterFailWithPercent();
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(
                  AppRoutes.practiceFlowShell,
                  extra: params.clientProfileModel,
                );
              }
            }
          }

          final errorStr = state.failReason.toLowerCase();

          // 🚨 ADDED: Intercept hold failures instantly
          if (errorStr.contains("hold")) {
            return HoldBreachFailed(
              text: state.failReason,
              onStartAgain: handleStartAgain,
            );
          }

          // If we fail during ANY part of the Inhale process
          if (state.phase == FullTestPhase.initial ||
              state.phase == FullTestPhase.inhaleCountdown ||
              state.phase == FullTestPhase.inhaling) {
            return InhaleFailed(
              text: state.failReason.isEmpty
                  ? "Inhale failed."
                  : state.failReason,
              onStartAgain: handleStartAgain,
            );
          }
          // If we fail during Hold or Exhale
          else {
            return ExhaleFailed(
              text: state.failReason.isEmpty
                  ? "Exhale failed."
                  : state.failReason,
              onStartAgain: handleStartAgain,
            );
          }
        }

        // 2. Countdown Screen (Catches BOTH Inhale and Exhale countdowns)
        if (state.phase == FullTestPhase.initial ||
            state.phase == FullTestPhase.inhaleCountdown ||
            state.phase == FullTestPhase.exhaleCountdown) {
          return FullTestStartCounterScreen(state: state);
        }

        // 3. Main Progress Screen (Handles Inhale, Transition, and Exhale)
        if (state.phase == FullTestPhase.inhaling ||
            state.phase == FullTestPhase.transitioning ||
            state.phase == FullTestPhase.exhaling) {
          return FullTestProgressScreen(
            state: state,
            breathingSettings: params.breathingSettings,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class HoldBreachFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const HoldBreachFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final isDisconnected = lower.contains("disconnect");

    String title;
    if (isDisconnected) {
      title = "Connection Lost";
    } else if (lower.contains("exhale")) {
      title = "You breathed out\nInstead of holding";
    } else if (lower.contains("inhale")) {
      title = "You breathed in\nInstead of holding";
    } else {
      title = "Hold failed.\nPlease try again";
    }

    // Removed the outer Container to match ExhaleFailed's structure
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Keeps text aligned to the left
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontWeight: FontWeight.w600,
              fontSize: rh(context: context, px: 25),
              height: rh(context: context, px: 1.29),
              letterSpacing: rh(context: context, px: -1),
            ),
          ),
          SizedBox(height: rh(context: context, px: 25)),

          if (isDisconnected)
            Text(
              text.isEmpty ? "Device disconnected. Please reconnect." : text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),

          if (!isDisconnected) SizedBox(height: rh(context: context, px: 12)),

          // Image logic: Takes up exactly the remaining middle space
          if (!isDisconnected)
            Expanded(
              child: Center(
                child: Image.asset(
                  "assets/images/device_connection/hold_failed.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // If disconnected, we just want empty space where the image would be
          if (isDisconnected) const Expanded(child: SizedBox()),

          // Removed the Spacer() that was breaking the layout here!

          _buildButton(context, isDisconnected: isDisconnected),
          SizedBox(height: rh(context: context, px: 20)),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required bool isDisconnected}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onStartAgain,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF308BF9),
          padding: EdgeInsets.symmetric(
            vertical: rh(context: context, px: 16),
          ),
          elevation: 0,
        ),
        child: Text(
          isDisconnected ? "Go Back" : "Start Again",
          style: GoogleFonts.poppins(
            fontSize: rh(context: context, px: 15),
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: rh(context: context, px: 1.10),
            letterSpacing: rh(context: context, px: 0.30),
          ),
        ),
      ),
    );
  }
}

class ExhaleFailed extends StatelessWidget {
  final String text;
  final VoidCallback onStartAgain;

  const ExhaleFailed({
    super.key,
    required this.text,
    required this.onStartAgain,
  });

  bool _contains(String s, String q) =>
      s.toLowerCase().contains(q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final e = text.toLowerCase();

    // 🚨 FIXED KEYWORDS: Match all possible Cubit outputs
    final isInhale = _contains(e, "inhale") ||
        _contains(e, "negative") ||
        _contains(e, "air in") ||
        _contains(e, "instead of out");
    final isTimeout = _contains(e, "time") ||
        _contains(e, "long") ||
        _contains(e, "response") ||
        _contains(e, "no breath") ||
        _contains(e, "no exhale") ||
        _contains(e, "30 seconds");
    final isDisconnected =
        _contains(e, "disconnect") || _contains(e, "connection");

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
              text.isEmpty ? "Device disconnected. Please reconnect." : text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w400,
                height: rh(context: context, px: 1.30),
                letterSpacing: rh(context: context, px: -0.30),
              ),
            ),
            const Expanded(child: SizedBox()),
            _buildButton(context, isDisconnected: true),
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

    if (isTimeout) {
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

  Widget _buildButton(BuildContext context, {required bool isDisconnected}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () {
            onStartAgain();
          },
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
