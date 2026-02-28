import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/widgets/breathing_graph.dart';
import 'package:respyr_dietitian/features/practice_test/practice_full_test/bloc/practice_full_test_state.dart';

class FullTestProgressScreen extends StatefulWidget {
  final PracticeFullTestState state;
  final BreathingSettings breathingSettings;

  const FullTestProgressScreen({
    super.key,
    required this.state,
    required this.breathingSettings,
  });

  @override
  State<FullTestProgressScreen> createState() => _FullTestProgressScreenState();
}

class _FullTestProgressScreenState extends State<FullTestProgressScreen> {
  // We use a ValueNotifier to keep the ball movement smooth without rebuilding the whole screen
  final ValueNotifier<double> _reading = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _reading.value = widget.state.progress;
  }

  @override
  void didUpdateWidget(covariant FullTestProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the reading notifier whenever the state progress changes
    if (oldWidget.state.progress != widget.state.progress) {
      _reading.value = widget.state.progress;
    }
  }

  @override
  void dispose() {
    _reading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isInhaling = state.phase == FullTestPhase.inhaling;

    // Dynamically set limits based on phase
    final targetMax = isInhaling
        ? widget.breathingSettings.inhale.maxBand.toDouble()
        : widget.breathingSettings.exhale.maxBand.toDouble();
    final targetMin = isInhaling
        ? widget.breathingSettings.inhale.minBand.toDouble()
        : widget.breathingSettings.exhale.minBand.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Title
        SizedBox(
          width: double.infinity,
          child: _buildMainTitle(context, state),
        ),
        SizedBox(height: rh(context: context, px: 20)),

        // Subtitle
        SizedBox(
          width: double.infinity,
          child: Text(
            _buildSubTitle(state),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              height: 1.30,
              letterSpacing: -0.30,
            ),
          ),
        ),

        SizedBox(height: rh(context: context, px: 22)),

        // The Graph Widget (Fills the screen like standalone screens)
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final safeH = (constraints.maxHeight <= 0)
                  ? rh(context: ctx, px: 300)
                  : constraints.maxHeight;

              return Center(
                child: RepaintBoundary(
                  child: BreathingTargetGraph(
                    reading: _reading,
                    height: safeH,
                    targetMin: targetMin,
                    targetMax: targetMax,
                    hold: false,
                    holdCounter: 0,
                  ),
                ),
              );
            },
          ),
        ),

        // Match the spacing from your Exhale screen
        SizedBox(height: rh(context: context, px: 127)),
      ],
    );
  }

  Widget _buildMainTitle(BuildContext context, PracticeFullTestState state) {
    final baseStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -1,
    );

    // If the ball is in range, show the "Keep ball in range for X seconds" text
    if (state.needRunning) {
      final targetTimeMs = state.phase == FullTestPhase.inhaling
          ? widget.breathingSettings.inhale.timeMs
          : widget.breathingSettings.exhale.timeMs;

      final remainingMs = (targetTimeMs - (state.inBandSeconds * 1000).round())
          .clamp(0, targetTimeMs);
      final remainingSec = (remainingMs / 1000).ceil();

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: "Keep the ball\nin range for "),
            TextSpan(
              text: "$remainingSec",
              // Changed to match the blue color from your standalone Exhale screen
              style: const TextStyle(color: Color(0xFF308BF9)),
            ),
            const TextSpan(text: " seconds"),
          ],
        ),
      );
    }

    // Default instructional text
    final actionText =
        state.phase == FullTestPhase.inhaling ? "Inhale" : "Exhale";

    return Text(
      "$actionText to move\nthe ball into range",
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }

  String _buildSubTitle(PracticeFullTestState state) {
    if (state.phase == FullTestPhase.transitioning) {
      return "Prepare for the next step...";
    }

    final actionText =
        state.phase == FullTestPhase.inhaling ? "Inhale" : "Exhale";

    // Matches the dynamic subtitle logic from the standalone screens
    if (state.needRunning) {
      return "$actionText until timer ends";
    }

    return "$actionText through your Respyr device";
  }
}
