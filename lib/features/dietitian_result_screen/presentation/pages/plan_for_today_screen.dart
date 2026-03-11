import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your live data model and the next screen
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/pages/score_breakdown_screen.dart';

class PlanForTodayScreen extends StatelessWidget {
  final Color domeColor;
  final TestResultResponse testResultResponse;

  const PlanForTodayScreen({
    super.key,
    required this.domeColor,
    required this.testResultResponse,
  });

  // Automatically determines the correct shadow color based on the score!
  Color _getShadowColor(double currentScore) {
    final int strictScore =
        currentScore.toInt(); // 🚨 FIX: Using strict .toInt()
    if (strictScore < 70) return const Color(0xFFF8BB82);
    if (strictScore < 80) return const Color(0xFFFFEAB9);
    return const Color(0xFFE8FFED);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dynamicScale = size.width / 375.0;
    final dynamicScaleH = size.height / 812.0;

    final domeSize = size.width * 1.25;

    final double liveScore = testResultResponse.fatLossMetabolismScore;
    final shadowColor = _getShadowColor(liveScore);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 1. THE HERO DOME WITH INNER SHADOW
          Positioned(
            top: -domeSize * 0.51,
            right: -domeSize * 0.51,
            child: Hero(
              tag: "Key",
              flightShuttleBuilder: (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final opacity = TweenSequence<double>([
                      TweenSequenceItem(
                          tween: Tween(begin: 1.0, end: 0.8), weight: 50),
                      TweenSequenceItem(
                          tween: Tween(begin: 0.8, end: 1.0), weight: 50),
                    ]).evaluate(animation);
                    return Opacity(
                        opacity: opacity, child: toHeroContext.widget);
                  },
                );
              },
              child: CustomPaint(
                foregroundPainter:
                    _FigmaInnerShadowPainter(shadowColor: shadowColor),
                child: Container(
                  width: domeSize,
                  height: domeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [domeColor.withOpacity(0.6), domeColor],
                      stops: const [0.0, 0.2],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reduced top spacing slightly to give cards more breathing room
                SizedBox(height: size.height * 0.21),

                // 🚨 Replaced ListView with a fixed Column and tighter spacing
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0 * dynamicScale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          "YOUR PLAN FOR TODAY",
                          style: GoogleFonts.poppins(
                            fontSize: 15 * dynamicScale, // Reduced
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3 * dynamicScale,
                            color: const Color(0xFF252525),
                          ),
                        ),
                        SizedBox(height: 30 * dynamicScaleH),

                        // Title
                        Text(
                          "Digestive Comfort Day",
                          style: GoogleFonts.poppins(
                            fontSize: 25 * dynamicScale, // Reduced
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252525),
                            letterSpacing: -1 * dynamicScale,
                          ),
                        ),
                        SizedBox(height: 21 * dynamicScaleH),

                        // Description
                        Text(
                          "Today is about nurturing your digestive health. Focusing on what you eat and how you eat can enhance your comfort and well-being.",
                          style: GoogleFonts.poppins(
                            fontSize: 12 * dynamicScale, // 🚨 Fixed 12px
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF535359),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 28 * dynamicScaleH),

                        // Avoid Card (Orange instead of Red)
                        _PlanCard(
                          dynamicScale: dynamicScale,
                          backgroundColor: const Color(
                              0xFFE48326), // 🚨 UPDATED ORANGE COLOR
                          title: "AVOID TODAY",
                          items: const [
                            "Skip heavy or oily foods that can weigh you down.",
                            "Avoid large portions that may lead to discomfort.",
                            "Limit sugary snacks that can upset your stomach.",
                          ],
                        ),
                        SizedBox(height: 12 * dynamicScaleH),

                        // Do This Card (Green)
                        _PlanCard(
                          dynamicScale: dynamicScale,
                          backgroundColor:
                              const Color(0xFF3FAF58), // 🚨 GREEN COLOR
                          title: "DO THIS TODAY",
                          items: const [
                            "Eat smaller portions and chew your food thoroughly.",
                            "Opt for lighter meals with plenty of fruits and vegetables.",
                            "Stay hydrated throughout the day to support digestion.",
                          ],
                        ),

                        // Dynamically takes up any remaining space to push the button down perfectly
                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.0 * dynamicScale,
                    right: 24.0 * dynamicScale,
                    bottom: 20.0 * dynamicScaleH,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF535359),
                          size: 24 * dynamicScale,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // PUSH TO SCORE BREAKDOWN SCREEN
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 850),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ScoreBreakdownScreen(
                                domeColor: domeColor,
                                testResultResponse: testResultResponse,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return Stack(
                                  children: [
                                    Container(color: Colors.white),
                                    FadeTransition(
                                      opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut),
                                      child: child,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 60 * dynamicScale,
                          height: 60 * dynamicScale,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4A8BF5),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 24 * dynamicScale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// REUSABLE WIDGET FOR THE CARDS
class _PlanCard extends StatelessWidget {
  final double dynamicScale;
  final Color backgroundColor;
  final String title;
  final List<String> items;

  const _PlanCard({
    required this.dynamicScale,
    required this.backgroundColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 🚨 Tightened padding inside the cards
      padding: EdgeInsets.fromLTRB(15, 15, 15, 23),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10 * dynamicScale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12 * dynamicScale, // Reduced
              fontWeight: FontWeight.w600,
              letterSpacing: -0.24 * dynamicScale,
            ),
          ),
          SizedBox(height: 8 * dynamicScale),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 3 * dynamicScale),
                // The dark vertical line indicator
                Container(
                  width: 2 * dynamicScale,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10 * dynamicScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) {
                      return Padding(
                        // 🚨 Tightened spacing between bullet points
                        padding: EdgeInsets.only(
                            bottom: item == items.last ? 0 : 8 * dynamicScale),
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11.5 * dynamicScale, // 🚨 Fixed 12px
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            letterSpacing: -0.24 * dynamicScale,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// NATIVE INNER SHADOW PAINTER
class _FigmaInnerShadowPainter extends CustomPainter {
  final Color shadowColor;

  const _FigmaInnerShadowPainter({required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.clipPath(Path()..addOval(rect));

    const double x = 12;
    const double y = -36;
    const double blur = 58.1;
    const double spread = -11;
    final double sigma = blur / 2.0;

    final Paint paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    final Rect holeRect = rect.translate(x, y).inflate(-spread);
    final Path shadowPath = Path()
      ..addRect(rect.inflate(blur * 2))
      ..addOval(holeRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(shadowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _FigmaInnerShadowPainter oldDelegate) {
    return oldDelegate.shadowColor != shadowColor;
  }
}
