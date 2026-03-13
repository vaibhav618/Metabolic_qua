import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚨 Added for the Skip Screen UI
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/inhale_failed.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/bloc/practice_test_inhale_cubit.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/bloc/practice_test_inhale_state.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/data/practice_test_inhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/screens/practice_test_inhale_progress_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/screens/practice_test_start_counter_screen.dart'
    show PracticeTestStartCounterScreen;

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart'; // 🚨 Needed for connection check

import '../../../../../core/size/get_height.dart'; // 🚨 Added for rh() sizing in the skip screen
import '../../../practice_test_home/bloc/practice_flow_bloc.dart';
import '../../../practice_test_home/domain/enums/practice_test.dart';
import 'package:respyr_dietitian/routes/app_routes.dart'; // 🚨 Needed for routing

class PracticeTestInhaleScreen extends StatelessWidget {
  final PracticeTestInhaleParams practiceTestInhaleParams;

  const PracticeTestInhaleScreen({
    super.key,
    required this.practiceTestInhaleParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeTestInhaleCubit(
        context.read(),
        practiceTestInhaleParams.breathingSettings,
      ),
      child: _PracticeTestInhaleView(
        settings: practiceTestInhaleParams.breathingSettings,
        params: practiceTestInhaleParams, // 🚨 Pass params down
      ),
    );
  }
}

class _PracticeTestInhaleView extends StatelessWidget {
  final BreathingSettings settings;
  final PracticeTestInhaleParams params; // 🚨 Accept params here

  const _PracticeTestInhaleView({
    required this.settings,
    required this.params,
  });

  PreferredSizeWidget _buildAppBar({
    required BuildContext context,
    required VoidCallback onBackClicked,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onBackClicked,
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PracticeTestInhaleCubit, PracticeTestInhaleState>(
      listenWhen: (p, c) =>
          p.isConnected != c.isConnected ||
          p.error != c.error ||
          p.inhaleFailed != c.inhaleFailed ||
          p.inhaleSuccess != c.inhaleSuccess ||
          p.navigateBack != c.navigateBack ||
          p.inhaleSuccess != c.inhaleSuccess,
      listener: (context, state) {
        if (!state.isConnected) {
          _showSnack(context, "Device disconnected");
        }

        final err = state.error;
        if (err != null && err.trim().isNotEmpty) {
          _showSnack(context, err);
        }

        if (state.inhaleSuccess) {
          context.read<PracticeFlowBloc>().add(
                PracticeFlowMarkCompleted(PracticeTestSteps.inhaleTest),
              );
          context.pop();
        }

        if (state.navigateBack) {}
      },
      child: BlocBuilder<PracticeTestInhaleCubit, PracticeTestInhaleState>(
        buildWhen: (p, c) =>
            p.startCounterStarted != c.startCounterStarted ||
            p.startCounterFinished != c.startCounterFinished ||
            p.inhaleStarted != c.inhaleStarted ||
            p.inhaleFinished != c.inhaleFinished ||
            p.inhaleFailed != c.inhaleFailed ||
            p.progress != c.progress ||
            p.showSkipButton != c.showSkipButton, // 🚨 Listen for Skip Button
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(
              context: context,
              onBackClicked: () {
                context.read<PracticeTestInhaleCubit>().cancelTest();
                Navigator.of(context).maybePop();
              },
            ),
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _BuildView(
                  key: ValueKey(
                    "${state.startCounterStarted}-"
                    "${state.startCounterFinished}-"
                    "${state.inhaleStarted}-"
                    "${state.inhaleFinished}-"
                    "${state.inhaleFailed}-"
                    "${state.showSkipButton}", // 🚨 Include in key to force rebuild
                  ),
                  state: state,
                  settings: settings,
                  params: params, // 🚨 Pass params to final view
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _BuildView extends StatelessWidget {
  final PracticeTestInhaleState state;
  final BreathingSettings settings;
  final PracticeTestInhaleParams params; // 🚨 Accept params here

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
        errorText: state.inhaleFailReason,
        onRetry: () {
          final isConnected = context.read<BluetoothRepository>().isConnected;
          if (isConnected) {
            context
                .read<PracticeTestInhaleCubit>()
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
          context.read<PracticeTestInhaleCubit>().cancelTest();
          context.go(
            AppRoutes.clientDashboard,
            extra: params.clientProfileModel,
          );
        },
      );
    }

    // 🚨 MOVED TO TOP: Failure/Disconnect logic now overrides the timer
    if (state.inhaleFailed) {
      final msg = state.inhaleFailReason.trim().isNotEmpty
          ? state.inhaleFailReason.trim()
          : "Test failed.";

      return InhaleFailed(
        text: msg,
        onStartAgain: () {
          // Check connection status directly from the repository
          final isConnected = context.read<BluetoothRepository>().isConnected;

          if (isConnected) {
            // Proceed with normal retry
            context
                .read<PracticeTestInhaleCubit>()
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
      return PracticeTestStartCounterScreen(state: state);
    }

    if (state.startCounterFinished && !state.inhaleFailed) {
      return PracticeTestInhaleProgressScreen(
        state: state,
        breathingSettings: settings,
      );
    }

    return const SizedBox.shrink();
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
