import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/widgets/arc_ruler.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

import 'score_chart_screen.dart';
import 'trend_card_screen.dart'; // 🚨 NEW: Imported the Trend Card Screen

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
  late Animation<Color?>
      _shadowColorAnimation; // 🚨 NEW: Shadow Color Animation
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
    final finalShadowColor = _getShadowColor(liveScore); // 🚨 Get target shadow

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

    // 2.5 Color Transition for Inner Shadow (Blue start -> Target Color)
    _shadowColorAnimation = ColorTween(
      begin: const Color(0xFFCAE1FF),
      end: finalShadowColor,
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

  // 🚨 FIX: Using strict .toInt()
  Color _getStatusColor(double score) {
    final int strictScore = score.toInt();
    if (strictScore < 70) return const Color(0xFFE48226); // Bad (Orange)
    if (strictScore < 80) return const Color(0xFFFFBF2D); // Moderate (Yellow)
    return const Color(0xFF3EAF58); // Good (Green)
  }

  // 🚨 FIX: Using strict .toInt()
  Color _getShadowColor(double score) {
    final int strictScore = score.toInt();
    if (strictScore < 70) return const Color(0xFFF8BB82); // Red/Orange Shadow
    if (strictScore < 80) return const Color(0xFFFFEAB9); // Yellow Shadow
    return const Color(0xFFE8FFED); // Green Shadow
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 Extract live score for the UI
    final double liveScore = widget.testResultResponse.fatLossMetabolismScore;

    // 🚨 Extract dynamic zone from data model
    final String dynamicZone =
        widget.testResultResponse.respyrResponse.fatUsePatternTrend.zone;

    // Local helper to format the specific text string you wanted based on the zone
    String getZoneText(String zone) {
      if (zone.toLowerCase() == 'focus') {
        return "Your score needs to\n$zone!";
      } else if (zone.toLowerCase() == 'poor' || zone.toLowerCase() == 'bad') {
        return "Action needed. Your score falls in the\n$zone range!";
      } else if (zone.toLowerCase() == 'moderate' ||
          zone.toLowerCase() == 'fair') {
        return "Keep going! Your score falls in the\n$zone range!";
      }
      return "Great! Your score falls in the\n$zone range!";
    }

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
          final currentShadowColor =
              _shadowColorAnimation.value ?? const Color(0xFFCAE1FF);

          return Stack(
            alignment: Alignment.center,
            children: [
              // --- SCORE TEXT SECTION ---
              Positioned(
                top: 60 * dynamicScale, // Scaled positioning
                child: Column(
                  children: [
                    // 🚨 NEW: Hero wrapper for Title
                    Hero(
                      tag: 'fat_use_title',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          'Your Metabolism Score',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252525),
                            height: 1.10,
                            letterSpacing: -0.72,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const SizedBox(width: 20),
                        // 🚨 NEW: Hero wrapper for Score
                        Hero(
                          tag: 'fat_use_score',
                          child: Material(
                            type: MaterialType.transparency,
                            // 🚨 FIX: Strict .toInt() applied here
                            child: Text(
                              currentScore.toInt().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 80,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
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
                          // 🚨 Native Figma-accurate painter with dynamic shadow color
                          child: CustomPaint(
                            foregroundPainter: _FigmaInnerShadowPainter(
                              shadowColor: currentShadowColor,
                            ),
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
                                      width:
                                          320, // 🚨 FIX: Increased width to prevent awkward wrapping
                                      height:
                                          100, // 🚨 FIX: Increased height so text doesn't cut off at the bottom
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          // Initial Text
                                          Opacity(
                                            opacity:
                                                _textFadeOutAnimation.value,
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
                                          // 🚨 Final Result Text mapping to Dynamic Text Helper
                                          Opacity(
                                            opacity: _textFadeInAnimation.value,
                                            child: Text(
                                              getZoneText(dynamicZone),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -1,
                                                height: 1.10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 10 *
                                        dynamicScale, // 🚨 Adjusted spacing slightly to account for the larger text box
                                  ),
                                  // The Button (Follows the text up, fading in as it does)
                                  Transform.translate(
                                    offset: Offset(
                                      0,
                                      _slideUpAnimation.value +
                                          (1 - _buttonFadeInAnimation.value) *
                                              15,
                                    ),
                                    child: Opacity(
                                      opacity: _buttonFadeInAnimation.value,
                                      child: OutlinedButton(
                                        onPressed: _buttonFadeInAnimation
                                                    .value >
                                                0.8
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 850),
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        TrendCardScreen(
                                                      // 🚨 FIX: Pass the full data model here!
                                                      testResultResponse: widget
                                                          .testResultResponse,
                                                      domeColor:
                                                          currentDomeColor,
                                                      onBackPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      onNextPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            transitionDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        850),
                                                            pageBuilder: (context,
                                                                    a, sa) =>
                                                                ScoreChartScreen(
                                                              domeColor:
                                                                  currentDomeColor,
                                                              testResultResponse:
                                                                  widget
                                                                      .testResultResponse,
                                                              clientProfileModel:
                                                                  widget
                                                                      .clientProfileModel,
                                                            ),
                                                            transitionsBuilder:
                                                                (context,
                                                                    animation,
                                                                    secondaryAnimation,
                                                                    child) {
                                                              return Stack(
                                                                children: [
                                                                  Container(
                                                                      color: Colors
                                                                          .white),
                                                                  FadeTransition(
                                                                    opacity:
                                                                        CurvedAnimation(
                                                                      parent:
                                                                          animation,
                                                                      curve: Curves
                                                                          .easeOut,
                                                                    ),
                                                                    child:
                                                                        child,
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      return Stack(
                                                        children: [
                                                          Container(
                                                              color:
                                                                  Colors.white),
                                                          FadeTransition(
                                                            opacity:
                                                                CurvedAnimation(
                                                              parent: animation,
                                                              curve: Curves
                                                                  .easeOut,
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

// 🚨 NATIVE INNER SHADOW PAINTER
// Accepts dynamic shadowColor
class _FigmaInnerShadowPainter extends CustomPainter {
  final Color shadowColor;

  const _FigmaInnerShadowPainter({required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Force a strict clipping path.
    canvas.clipPath(Path()..addOval(rect));

    // Figma Properties
    const double x = 12;
    const double y = 36;
    const double blur = 58;
    const double spread = -11;

    final double sigma = blur / 2.0;

    final Paint paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    // Negative spread means the shadow contracts.
    final Rect holeRect = rect.translate(x, y).inflate(-spread);

    final Path shadowPath = Path()
      ..addRect(rect.inflate(
          blur * 2)) // Large outer bounds to ensure blur doesn't clip early
      ..addOval(holeRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(shadowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _FigmaInnerShadowPainter oldDelegate) {
    return oldDelegate.shadowColor != shadowColor;
  }
}
