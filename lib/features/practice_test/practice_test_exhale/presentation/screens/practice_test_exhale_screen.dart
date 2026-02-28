import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/exhale_failed.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/inhale_failed.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/bloc/practice_test_exhale_cubit.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/bloc/practice_test_exhale_state.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/data/practice_test_exhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/screens/practice_test_exhale_progress_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/screens/practice_test_exhale_start_counter_screen.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

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
      listener: (context, state) {
        if (!state.isConnected) {
          _showSnack(context, "Device disconnected");
        }

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
                  state: state,
                  settings: params.breathingSettings,
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

  const _BuildView({required this.state, required this.settings});

  @override
  Widget build(BuildContext context) {
    if (!state.startCounterFinished) {
      return PracticeTestExhaleStartCounterScreen(state: state);
    }

    if (state.startCounterFinished && !state.exhaleFailed) {
      return PracticeTestExhaleProgressScreen(
        state: state,
        breathingSettings: settings,
      );
    }

    return ExhaleFailed(
      // text: state.exhaleFailReason.isEmpty
      //     ? "Test failed."
      //     : state.exhaleFailReason,
      onStartAgain: () {
        context.read<PracticeTestExhaleCubit>().restartAfterFailWithPercent();
      },
      state: state,
    );
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
    // ✅ FIX: Prefer exhaleFailReason (your cubit sets this), fallback to error.
    final raw = ((state.exhaleFailReason ?? "").trim().isNotEmpty
            ? state.exhaleFailReason!
            : (state.error ?? ""))
        .trim();

    final e = raw.toLowerCase();

    // ✅ Match cubit reasons
    final isInhale = _contains(e, "inhale"); // matches "Inhale detected..."
    final isDropped = _contains(e, "dropped") ||
        _contains(e, "drop") ||
        _contains(e, "out of range") ||
        _contains(e, "range"); // matches "Out of range for 2 seconds"
    final timeout = _contains(e, "too long") ||
        _contains(e, "timeout") ||
        _contains(e, "no response") ||
        _contains(e, "no exhale detected within 30 seconds");

    debugPrint("exhale error : $e");

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
            SizedBox(
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
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    if (isDropped) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: rh(context: context, px: 17)),
        child: Column(
          children: [
            Spacer(),
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
            Spacer(),
            SizedBox(
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
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
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
            SizedBox(
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
                    "Start Again",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: rh(context: context, px: 15),
                        fontWeight: FontWeight.w700,
                        height: rh(context: context, px: 1.0),
                        letterSpacing: rh(context: context, px: 0.30)),
                  )),
            ),
            SizedBox(
              height: rh(context: context, px: 20),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
