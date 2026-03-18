import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/breath_setting_model.dart';

import '../../../../core/size/get_height.dart';
import '../cubit/bluetooth_exhale_cubit_new/bluetooth_exhale_state.dart';
import 'breathing_graph.dart';

class NewExhaleScreen2 extends StatefulWidget {
  final BluetoothExhaleState state;
  final BreathingSettings breathingSettings;
  const NewExhaleScreen2(
      {super.key, required this.state, required this.breathingSettings});

  @override
  State<NewExhaleScreen2> createState() => _NewExhaleScreen2State();
}

class _NewExhaleScreen2State extends State<NewExhaleScreen2>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _reading = ValueNotifier<double>(0);

  bool _isInitialFrame = true;

  // 🚨 UPDATED: Only animating the progress ball now to keep range lines fixed
  late AnimationController _transitionController;
  late Animation<double> _progressAnim;

  bool _isAnimatingGraph = true;

  @override
  void initState() {
    super.initState();

    // Start the graph at the fully shrunken state
    double startingInhaleProgress = 1.0;
    _reading.value = startingInhaleProgress;

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of the ball expansion
    );

    // Animate only the ball/progress
    _progressAnim =
        Tween<double>(begin: startingInhaleProgress, end: widget.state.progress)
            .animate(CurvedAnimation(
                parent: _transitionController, curve: Curves.easeOutCubic));

    _transitionController.addListener(() {
      _reading.value = _progressAnim.value;
    });

    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimatingGraph = false;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialFrame = false;
        });
        _transitionController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant NewExhaleScreen2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isAnimatingGraph &&
        oldWidget.state.progress != widget.state.progress) {
      _reading.value = widget.state.progress;
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _reading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bool isHolding = state.exhaleStarted;

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
            isHolding
                ? "Exhale until timer ends"
                : "Exhale through your Respyr device",
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
                  // 🚨 FIXED: Removed AnimatedBuilder for bands so they stay static
                  child: BreathingTargetGraph(
                    reading: _reading,
                    height: safeH,
                    targetMin:
                        widget.breathingSettings.exhale.minBand.toDouble(),
                    targetMax:
                        widget.breathingSettings.exhale.maxBand.toDouble(),
                    // Keep hold true for the initial frame to match the visual state of the previous screen
                    hold: _isInitialFrame ? true : false,
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

  Widget _buildMainTitle(BuildContext context, BluetoothExhaleState state) {
    final baseStyle = GoogleFonts.poppins(
      color: const Color(0xFF252525),
      fontSize: rh(context: context, px: 25),
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -1,
    );

    Widget textWidget;

    if (_isInitialFrame) {
      textWidget = Text(
        "Start exhaling in..",
        key: const ValueKey("imposter_text"),
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    } else if (!state.exhaleStarted) {
      textWidget = Text(
        "Exhale to move\nthe ball into range",
        key: const ValueKey("exhale_start_text"),
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    } else {
      textWidget = RichText(
        key: const ValueKey("exhale_holding_text"),
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: "Keep the ball in\nrange for "),
            TextSpan(
              text: "${state.holdSecondsLeft}",
              style: const TextStyle(color: Color(0xFF308BF9)),
            ),
            const TextSpan(text: " seconds"),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: textWidget,
    );
  }
}
