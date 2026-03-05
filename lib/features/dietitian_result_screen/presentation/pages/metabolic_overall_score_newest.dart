import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/arc_ruler.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import 'score_chart_screen.dart';

class MetabolismOverallScore extends StatefulWidget {
  final TestResultResponse testResultResponse;
  final ClientProfileModel clientProfileModel;

  const MetabolismOverallScore({
    super.key,
    required this.testResultResponse,
    required this.clientProfileModel,
  });

  @override
  State<MetabolismOverallScore> createState() => _MetabolismOverallScoreState();
}

class _MetabolismOverallScoreState extends State<MetabolismOverallScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  // Explicit animations for sequenced transitions
  late Animation<Color?> _domeColorAnimation;
  late Animation<double> _textFadeOutAnimation;
  late Animation<double> _textFadeInAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _buttonFadeInAnimation;

  // Define the master duration here so it's easy to change later
  final Duration _animationDuration = const Duration(
    milliseconds: 4000,
  ); // CHANGED to 4 seconds

  // Helper to format the live date
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime);
      final local = dt.toLocal();
      return DateFormat('d MMM yyyy, h:mma').format(local);
    } catch (_) {
      return dateTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration, // Applied here
    );

    // 🚨 Extract the live score
    final double liveScore = widget.testResultResponse.fatLossMetabolismScore;

    // 1. The Score counting up
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: liveScore,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final finalStatusColor = _getStatusColor(liveScore);

    // 2. Color Transition (Shifted earlier: 35% to 55% of animation)
    _domeColorAnimation = ColorTween(
      begin: const Color(0xFF308BF9),
      end: finalStatusColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeInOut),
      ),
    );

    // 3. Text Cross-fade (Shifted earlier)
    _textFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.45, curve: Curves.easeOut),
      ),
    );

    _textFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.55, curve: Curves.easeIn),
      ),
    );

    // 4. Slide Upwards (55% to 75% of animation)
    _slideUpAnimation = Tween<double>(
      begin: 0.0, // Stays at 0 until 55%
      end: -80.0, // Slides up 80 pixels
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeInOut),
      ),
    );

    // 5. Button Fade In (70% to 90% of animation)
    _buttonFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 0.90, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(double score) {
    if (score < 70) return const Color(0xFFE48226); // Bad (Orange)
    if (score < 80) return const Color(0xFFFFBF2D); // Moderate (Yellow)
    return const Color(0xFF3EAF58); // Good (Green)
  }

  String _getStatusText(double score) {
    if (score < 70) return "bad";
    if (score < 80) return "moderate";
    return "good";
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 Extract live score for the UI
    final double liveScore = widget.testResultResponse.fatLossMetabolismScore;

    // 1. Calculate dynamic scale based on a standard 375px width screen
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicScale = screenWidth / 375.0;

    // 2. Scale the dome base size (using your exact 628 value)
    final domeSize = 508.0 * dynamicScale;

    Future<bool> navToDashboard(BuildContext context) async {
      bool didCancel = false;
      if (context.mounted) {
        context.go(AppRoutes.clientDashboard, extra: widget.clientProfileModel);
      }
      return didCancel;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle:
            false, // 🚨 Changed to false to align the block to the left
        title: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // 🚨 Added to align text left inside the column
          children: [
            Text(
              widget.clientProfileModel.profileName,
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.36,
              ),
            ),
            Text(
              formatDateTime(widget.testResultResponse.dateTime.toString()),
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              navToDashboard(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentScore = _scoreAnimation.value;
          final currentDomeColor =
              _domeColorAnimation.value ?? const Color(0xFF308BF9);

          return Stack(
            alignment: Alignment.center,
            children: [
              // --- SCORE TEXT SECTION ---
              Positioned(
                top: 60 * dynamicScale, // Scaled positioning
                child: Column(
                  children: [
                    Text(
                      'Your Metabolism Score',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF252525),
                        height: 1.10,
                        letterSpacing: -0.72,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          currentScore.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 80,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '%',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- ARC SCALE & DOME ---
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 450 * dynamicScale, // Scaled container
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // The Color Dome
                      Positioned(
                        top: 70 * dynamicScale, // Scaled positioning
                        child: Hero(
                          tag: "Key",
                          child: Container(
                            width: domeSize, // Responsive width
                            height: domeSize, // Responsive height
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  currentDomeColor.withOpacity(0.6),
                                  currentDomeColor,
                                ],
                                stops: const [0.0, 0.13],
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 160 * dynamicScale,
                                ), // Scaled inner spacing
                                // The sliding text block
                                Transform.translate(
                                  offset: Offset(0, _slideUpAnimation.value),
                                  child: SizedBox(
                                    width: 280,
                                    height: 70, // Fixed height limits jumps
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        // Initial Text
                                        Opacity(
                                          opacity: _textFadeOutAnimation.value,
                                          child: Text(
                                            "Your score falls in...",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ),
                                        // Final Result Text
                                        Opacity(
                                          opacity: _textFadeInAnimation.value,
                                          child: Text(
                                            // 🚨 Applying liveScore to the text logic
                                            "Great. Your score falls in\n${_getStatusText(liveScore)} range!",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 30 * dynamicScale,
                                ), // Scaled inner spacing
                                // The Button (Follows the text up, fading in as it does)
                                Transform.translate(
                                  offset: Offset(
                                    0,
                                    _slideUpAnimation.value +
                                        (1 - _buttonFadeInAnimation.value) * 15,
                                  ),
                                  child: Opacity(
                                    opacity: _buttonFadeInAnimation.value,
                                    child: OutlinedButton(
                                      onPressed: _buttonFadeInAnimation.value >
                                              0.8
                                          ? () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  // CHANGED BACK TO 800ms for that slow, majestic glide
                                                  transitionDuration:
                                                      const Duration(
                                                    milliseconds: 850,
                                                  ),
                                                  pageBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) =>
                                                      ScoreChartScreen(
                                                    domeColor: currentDomeColor,
                                                  ),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    // The Stack instantly covers the old screen with white
                                                    return Stack(
                                                      children: [
                                                        Container(
                                                          color: Colors.white,
                                                        ),
                                                        FadeTransition(
                                                          opacity:
                                                              CurvedAnimation(
                                                            parent: animation,
                                                            curve:
                                                                Curves.easeOut,
                                                          ),
                                                          child: child,
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.white,
                                        ),
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                      ),
                                      child: Text(
                                        "What it means?",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                          letterSpacing: 0.30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // YOUR EXTERNAL ARC RULER WIDGET
                      Positioned(
                        top: 70 * dynamicScale, // Scaled positioning
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: ArcRuler(
                            value: liveScore, // 🚨 Real Score applied here
                            onChanged: (val) {},
                            thumbAnimationDuration:
                                _animationDuration, // Applied here to match perfectly
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
