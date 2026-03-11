import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🚨 IMPORT ADDED FOR DATA MODEL
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

class TrendCardScreen extends StatelessWidget {
  final TestResultResponse testResultResponse;
  final Color domeColor;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  const TrendCardScreen({
    super.key,
    required this.testResultResponse,
    required this.domeColor,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  // Automatically determines the correct shadow color based on the score!
  Color _getShadowColor(int currentScore) {
    if (currentScore < 70) return const Color(0xFFF8BB82);
    if (currentScore < 80) return const Color(0xFFFFEAB9);
    return const Color(0xFFE8FFED);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // EXTRACTING DATA DIRECTLY FROM THE MODEL
    final int currentScore = testResultResponse.fatLossMetabolismScore.toInt();
    final String title = testResultResponse
        .respyrResponse.fatUsePatternTrend.clientInterpretation.title;
    final String description = testResultResponse
        .respyrResponse.fatUsePatternTrend.clientInterpretation.text;

    // 🚨 TEMPORARY CALCULATION (Replace when Data Model is updated by Seniors)
    // Faking a previous score so the UI shows realistic arrows and percentages.
    final int mockPreviousScore =
        currentScore > 75 ? currentScore - 5 : currentScore + 3;
    final int difference = currentScore - mockPreviousScore;

    final bool isPositiveTrend = difference >= 0;
    final int displayPercentage = difference.abs();

    // Responsive scaling multipliers based on a standard 375x812 design
    final dynamicScale = size.width / 375.0;
    final dynamicScaleH = size.height / 812.0;

    final domeSize = size.width * 1.25;

    final shadowColor = _getShadowColor(currentScore);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // THE DOME HERO ANIMATION
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
                        tween: Tween(begin: 1.0, end: 0.8),
                        weight: 50,
                      ),
                      TweenSequenceItem(
                        tween: Tween(begin: 0.8, end: 1.0),
                        weight: 50,
                      ),
                    ]).evaluate(animation);

                    return Opacity(
                      opacity: opacity,
                      child: toHeroContext.widget,
                    );
                  },
                );
              },
              child: Material(
                type: MaterialType.transparency,
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
          ),

          // Main Content inside SafeArea
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Buttons
                Padding(
                  padding: EdgeInsets.only(
                    right: 20.0 * dynamicScale,
                    top: 10.0 * dynamicScaleH,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTopIconButton(
                        Icons.question_mark_rounded,
                        dynamicScale,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                const ScoreRangesBottomSheet(),
                          );
                        },
                      ),
                      SizedBox(width: 12 * dynamicScale),
                      Hero(
                        tag: "share_button",
                        child: Material(
                          type: MaterialType.transparency,
                          child: _buildTopIconButton(
                              Icons.share_outlined, dynamicScale),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.14),

                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0 * dynamicScale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TREND CARD",
                          style: GoogleFonts.poppins(
                            fontSize: 15 * dynamicScale,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3 * dynamicScale,
                            color: const Color(0xFF252525),
                          ),
                        ),
                        SizedBox(height: 50 * dynamicScaleH),

                        // 🚨 DYNAMIC TREND INDICATOR
                        Row(
                          children: [
                            Icon(
                              isPositiveTrend
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: isPositiveTrend
                                  ? const Color(0xFF67B76B)
                                  : Colors.redAccent,
                              size: 20 * dynamicScale,
                            ),
                            SizedBox(width: 4 * dynamicScale),
                            Text(
                              "$displayPercentage% ", // 🚨 NOW USING TEMP CALCULATION
                              style: GoogleFonts.poppins(
                                fontSize: 16 * dynamicScale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF535359),
                                letterSpacing: -0.3 * dynamicScale,
                              ),
                            ),
                            Text(
                              "than yesterday",
                              style: GoogleFonts.poppins(
                                fontSize: 16 * dynamicScale,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF757575),
                                letterSpacing: -0.3 * dynamicScale,
                              ),
                            ),
                          ],
                        ),

                        // Score
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "$currentScore",
                              style: GoogleFonts.poppins(
                                fontSize: 100 * dynamicScale,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF252525),
                                height: 1.3,
                                letterSpacing: -2 * dynamicScale,
                              ),
                            ),
                            Text(
                              "%",
                              style: GoogleFonts.poppins(
                                fontSize: 20 * dynamicScale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF252525),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10 * dynamicScaleH),

                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 25 * dynamicScale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252525),
                            letterSpacing: -1 * dynamicScale,
                          ),
                        ),
                        SizedBox(height: 16 * dynamicScaleH),

                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 13 * dynamicScale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                            height: 1.5,
                            letterSpacing: -0.24 * dynamicScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(
                    left: 24.0 * dynamicScale,
                    right: 24.0 * dynamicScale,
                    bottom: 30.0 * dynamicScaleH,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onBackPressed,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF535359),
                          size: 24 * dynamicScale,
                        ),
                      ),
                      GestureDetector(
                        onTap: onNextPressed,
                        child: Container(
                          width: 60 * dynamicScale,
                          height: 60 * dynamicScale,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF308BF9),
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

  Widget _buildTopIconButton(IconData icon, double dynamicScale,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44 * dynamicScale,
        height: 44 * dynamicScale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.25),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 20 * dynamicScale,
          ),
        ),
      ),
    );
  }
}

// ... ScoreRangesBottomSheet and Painters remain exactly the same below ...
class ScoreRangesBottomSheet extends StatelessWidget {
  const ScoreRangesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dynamicScale = size.width / 375.0;

    return Container(
      height: size.height * 0.94,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0 * dynamicScale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40 * dynamicScale),
                Text(
                  "What are the\ndifferent score ranges?",
                  style: GoogleFonts.poppins(
                    fontSize: 25 * dynamicScale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF252525),
                    height: 1.1,
                    letterSpacing: -1 * dynamicScale,
                  ),
                ),
                SizedBox(height: 30 * dynamicScale),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15 * dynamicScale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(16 * dynamicScale),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 15 * dynamicScale),
                      Text(
                        "FOR METABOLISM SCORE",
                        style: GoogleFonts.poppins(
                          fontSize: 11 * dynamicScale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF757575),
                        ),
                      ),
                      SizedBox(height: 22 * dynamicScale),
                      _ScoreRangeCard(
                        dynamicScale: dynamicScale,
                        range: "100-80%",
                        label: "Good",
                        color: const Color(0xFF5CAD64),
                        description:
                            "Indicates the level of gas production from gut fermentation.",
                      ),
                      SizedBox(height: 10 * dynamicScale),
                      _ScoreRangeCard(
                        dynamicScale: dynamicScale,
                        range: "79-70%",
                        label: "Fair",
                        color: const Color(0xFFF3C05A),
                        description:
                            "Indicates the level of gas production from gut fermentation.",
                      ),
                      SizedBox(height: 10 * dynamicScale),
                      _ScoreRangeCard(
                        dynamicScale: dynamicScale,
                        range: "69-0%",
                        label: "Poor",
                        color: const Color(0xFFDB8547),
                        description:
                            "Indicates the level of gas production from gut fermentation.",
                      ),
                      SizedBox(height: 40 * dynamicScale),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.0 * dynamicScale),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF252525),
                elevation: 0,
                shape: CircleBorder(),
                onPressed: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRangeCard extends StatelessWidget {
  final double dynamicScale;
  final String range;
  final String label;
  final Color color;
  final String description;

  const _ScoreRangeCard({
    required this.dynamicScale,
    required this.range,
    required this.label,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * dynamicScale,
            vertical: 12 * dynamicScale,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color,
                Colors.white,
              ],
              stops: const [0.3, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8 * dynamicScale),
              topRight: Radius.circular(8 * dynamicScale),
              bottomLeft: Radius.circular(8 * dynamicScale),
              bottomRight: Radius.zero,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                range,
                style: GoogleFonts.poppins(
                  fontSize: 20 * dynamicScale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12 * dynamicScale,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 16 * dynamicScale),
          padding: EdgeInsets.fromLTRB(16 * dynamicScale, 12 * dynamicScale,
              16 * dynamicScale, 16 * dynamicScale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8 * dynamicScale),
              bottomRight: Radius.circular(8 * dynamicScale),
            ),
          ),
          child: Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12 * dynamicScale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF535359),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

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
