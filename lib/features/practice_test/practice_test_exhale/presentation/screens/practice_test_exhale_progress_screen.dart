import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/size/get_height.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/bloc/practice_test_exhale_state.dart';

import '../../../../bluetooth_device_connectivity/presentation/widgets/breathing_graph.dart';

class PracticeTestExhaleProgressScreen extends StatefulWidget {
  final PracticeTestExhaleState state;
  final BreathingSettings breathingSettings;
  const PracticeTestExhaleProgressScreen(
      {super.key, required this.state, required this.breathingSettings});

  @override
  State<PracticeTestExhaleProgressScreen> createState() =>
      _PracticeTestExhaleProgressScreenState();
}

class _PracticeTestExhaleProgressScreenState
    extends State<PracticeTestExhaleProgressScreen> {
  final ValueNotifier<double> _reading = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _reading.value = widget.state.progress;
  }

  @override
  void didUpdateWidget(covariant PracticeTestExhaleProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: _buildMainTitle(context, state),
        ),
        SizedBox(height: rh(context: context, px: 20)),
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
                    targetMin:
                        widget.breathingSettings.exhale.minBand.toDouble(),
                    targetMax:
                        widget.breathingSettings.exhale.maxBand.toDouble(),
                    hold: false,
                    holdCounter: 0,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: rh(context: context, px: 127)),
      ],
    );
  }

  Widget _buildMainTitle(BuildContext context, PracticeTestExhaleState state) {
    final baseStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -1,
    );

    if (state.exhaleNeedRunning) {
      final remainingMs =
          (state.exhaleNeedTotalMillis - (state.inBandSeconds * 1000).round())
              .clamp(0, state.exhaleNeedTotalMillis);
      final remainingSec = (remainingMs / 1000).ceil();

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: "Keep the ball\nin range for "),
            TextSpan(
              text: "$remainingSec",
              style: const TextStyle(color: Color(0xFF308BF9)),
            ),
            const TextSpan(text: " seconds"),
          ],
        ),
      );
    }

    return Text(
      "Exhale to move\nthe ball into range",
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }

  String _buildSubTitle(PracticeTestExhaleState state) {
    if (state.exhaleNeedRunning) {
      return "Exhale until timer ends";
    }
    return "Exhale through your Respyr device";
  }
}
