import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your live data model here
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

class ScoreBreakdownScreen extends StatelessWidget {
  final Color domeColor; // Pass the same color from the previous screen
  final TestResultResponse testResultResponse; // Live data passed in

  const ScoreBreakdownScreen({
    super.key,
    required this.domeColor,
    required this.testResultResponse,
  });

  // 🚨 FIX: Strict .toInt() applied for zone logic
  Map<String, dynamic> _getZoneData(double score) {
    final int strictScore = score.toInt();
    if (strictScore <= 60) {
      return {'status': 'Poor', 'color': const Color(0xFFE48326)};
    } else if (strictScore < 80) {
      return {'status': 'Fair', 'color': const Color(0xFFFFBF2D)};
    } else {
      return {'status': 'Good', 'color': const Color(0xFF3EAF58)};
    }
  }

  // 🚨 FIX: Strict .toInt() applied for shadow color
  Color _getShadowColor(double currentScore) {
    final int strictScore = currentScore.toInt();
    if (strictScore < 70) return const Color(0xFFF8BB82);
    if (strictScore < 80) return const Color(0xFFFFEAB9);
    return const Color(0xFFE8FFED);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Keeps the same dome size as the previous screen for a seamless transition
    final domeSize = size.width * 1.25;

    // =========================================================================
    // EXTRACT LIVE SCORES FROM THE NESTED MODEL
    // =========================================================================
    final analysis = testResultResponse.respyrResponse.metabolismScoreAnalysis;
    final breathMarkers =
        testResultResponse.respyrResponse.breathMarkerAnalysis;

    final double glucoseFatScore = analysis.energySourceTrend.score;
    final double gutFermentationScore = analysis.digestiveActivityTrend.score;
    final double liverHepaticScore = analysis.metabolicLoadTrend.score;

    // Calculate dynamic zones
    final glucoseFatZone = _getZoneData(glucoseFatScore);
    final gutFermentationZone = _getZoneData(gutFermentationScore);
    final liverHepaticZone = _getZoneData(liverHepaticScore);

    // Get the main score to determine the correct shadow color for the dome
    final double liveScore = testResultResponse.fatLossMetabolismScore;
    final shadowColor = _getShadowColor(liveScore);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. THE HERO DOME (Top Right - Matches exactly)
          Positioned(
            top: -domeSize * 0.51,
            right: -domeSize * 0.51,
            child: Hero(
              tag: "Key", // Keeps the transition flowing
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
              // Wrapped Container with CustomPaint for Native Inner Shadow
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer to push content down below the dome curve
                  SizedBox(height: size.height * 0.21),

                  // Header Text
                  Text(
                    'Score Breakdown',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. BREAKDOWN LIST
                  // Expanded takes up available space, pushing the bottom nav down
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBreakdownItem(
                          title: 'Glucose vs. Fat Metabolism',
                          status: glucoseFatZone['status'],
                          statusColor: glucoseFatZone['color'],
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BreakdownDetailBottomSheet(
                                title: 'Glucose vs. Fat Metabolism',
                                status: glucoseFatZone['status'],
                                statusColor: glucoseFatZone['color'],
                                markerName: 'Acetone',
                                markerValue: '${breathMarkers.acetone.ppm} ppm',
                                subScores: [
                                  {
                                    'title': 'Energy Source Trend',
                                    'trend': analysis.energySourceTrend
                                  },
                                  {
                                    'title': 'Fuel Utilization Trend',
                                    'trend': analysis.fuelUtilizationTrend
                                  },
                                ],
                              ),
                            );
                          },
                        ),
                        _buildBreakdownItem(
                          title: 'Gut Fermentation Metabolism',
                          status: gutFermentationZone['status'],
                          statusColor: gutFermentationZone['color'],
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BreakdownDetailBottomSheet(
                                title: 'Gut Fermentation Metabolism',
                                status: gutFermentationZone['status'],
                                statusColor: gutFermentationZone['color'],
                                markerName: 'Hydrogen',
                                markerValue:
                                    '${breathMarkers.hydrogen.ppm} ppm',
                                subScores: [
                                  {
                                    'title': 'Digestive Activity Trend',
                                    'trend': analysis.digestiveActivityTrend
                                  },
                                  {
                                    'title': 'Nutrient Utilization Trend',
                                    'trend': analysis.nutrientUtilizationTrend
                                  },
                                ],
                              ),
                            );
                          },
                        ),
                        _buildBreakdownItem(
                          title: 'Liver Hepatic Metabolism',
                          status: liverHepaticZone['status'],
                          statusColor: liverHepaticZone['color'],
                          showDivider: true,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BreakdownDetailBottomSheet(
                                title: 'Liver Hepatic Metabolism',
                                status: liverHepaticZone['status'],
                                statusColor: liverHepaticZone['color'],
                                markerName: 'Ethanol',
                                markerValue: '${breathMarkers.ethanol.ppm} ppm',
                                subScores: [
                                  {
                                    'title': 'Metabolic Load Trend',
                                    'trend': analysis.metabolicLoadTrend
                                  },
                                  {
                                    'title': 'Recovery Activity Trend',
                                    'trend': analysis.recoveryActivityTrend
                                  },
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // 4. BOTTOM NAVIGATION (Matches perfectly)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle next action (e.g., navigate to detailed breakdown)
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF308BF9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the individual breakdown rows cleanly
  Widget _buildBreakdownItem({
    required String title,
    required String status,
    required Color statusColor,
    required VoidCallback onTap, // Added onTap required parameter
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap, // Applied onTap action
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF4A4A4A),
                  size: 16,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              color: Colors.grey.shade300,
              height: 1,
              thickness: 1,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM SHEET WIDGETS
// ============================================================================

class BreakdownDetailBottomSheet extends StatefulWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String markerName;
  final String markerValue;
  final List<Map<String, dynamic>> subScores;

  const BreakdownDetailBottomSheet({
    super.key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.markerName,
    required this.markerValue,
    required this.subScores,
  });

  @override
  State<BreakdownDetailBottomSheet> createState() =>
      _BreakdownDetailBottomSheetState();
}

class _BreakdownDetailBottomSheetState
    extends State<BreakdownDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Main Scrollable Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 30),
                Text(
                  'Score Breakdown',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.status,
                  style: GoogleFonts.poppins(
                    color: widget.statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Expandable Sub-Scores
                ...widget.subScores.map((scoreData) {
                  final String subTitle = scoreData['title'];
                  final TrendDetail trend = scoreData['trend'];
                  return _SubScoreAccordion(
                    title: subTitle,
                    trend: trend,
                    statusColor: widget.statusColor,
                  );
                }).toList(),

                const SizedBox(height: 100), // Padding for the close button
              ],
            ),
          ),

          // Floating Close Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF252525),
                elevation: 0,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubScoreAccordion extends StatefulWidget {
  final String title;
  final TrendDetail trend;
  final Color statusColor;

  const _SubScoreAccordion({
    required this.title,
    required this.trend,
    required this.statusColor,
  });

  @override
  State<_SubScoreAccordion> createState() => _SubScoreAccordionState();
}

class _SubScoreAccordionState extends State<_SubScoreAccordion> {
  // 🚨 CHANGED: Set to true so the arrow points up by default
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // 🚨 NEW: Tells Flutter to render it open immediately
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            onExpansionChanged: (expanded) =>
                setState(() => isExpanded = expanded),
            title: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF252525),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trend
                          .whatIsThisScore, // Dynamic description from API
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF666666),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Big Score
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // 🚨 FIX: Strict .toInt() applied here
                        Text(
                          widget.trend.score.toInt().toString().padLeft(2, '0'),
                          style: GoogleFonts.poppins(
                            fontSize: 70,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF252525),
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '%',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252525),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Segmented Bar Chart Mock
                    // 🚨 FIX: Passed strict .toInt().toDouble() down to the bar chart to maintain type safety but pass the truncated value
                    _ScoreBar(
                        score: widget.trend.score.toInt().toDouble(),
                        color: widget.statusColor),

                    const SizedBox(height: 15),
                    Text(
                      'What are the different score ranges?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF308BF9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Score Meaning
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'SCORE MEANING',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF666666),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget
                                .trend.clientState, // Dynamic meaning from API
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Score Chart Placeholder
                    Text(
                      'SCORE CHART',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                          child: Text("Graph Component Goes Here")),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;
  final Color color;

  const _ScoreBar({required this.score, required this.color});

  // Updated with your new exact hex codes!
  // 🚨 FIX: Evaluates the strict Score. Note the bounds changed to match your updated mapping
  Color _getDynamicColor(double currentScore) {
    final int strictScore = currentScore.toInt();
    if (strictScore >= 80) return const Color(0xFF3EAF58); // Good (Green)
    if (strictScore > 60) return const Color(0xFFFFBF2D); // Fair (Yellowish)
    return const Color(0xFFE48326); // Poor (Orangeish)
  }

  @override
  Widget build(BuildContext context) {
    int totalBars = 50;
    // We can use round here because it's just visually filling blocks,
    // but the color comes strictly from the truncated score.
    int filledBars = (score / 100 * totalBars).round();

    final Color activeColor = _getDynamicColor(score);
    final int strictScore = score.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('60', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('80', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('100', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalBars, (index) {
            return Container(
              width: 4,
              height: 45,
              decoration: BoxDecoration(
                color: index < filledBars ? activeColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        // 🚨 FIX: Label evaluation perfectly matches the color evaluation
        Text(
          strictScore >= 80
              ? 'Good'
              : strictScore > 60
                  ? 'Fair'
                  : 'Poor',
          style: GoogleFonts.poppins(
            color: activeColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 🚨 NATIVE INNER SHADOW PAINTER
class _FigmaInnerShadowPainter extends CustomPainter {
  final Color shadowColor;

  const _FigmaInnerShadowPainter({required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Force a strict clipping path so the shadow NEVER bleeds onto the white screen
    canvas.clipPath(Path()..addOval(rect));

    // Y is inverted to -36 to match the visible bottom-left curve of the dome
    const double x = 12;
    const double y = -36;
    const double blur = 58.1;
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
