import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightMiniChart extends StatelessWidget {
  final List<double> allWeights;      // all logged weights
  final List<DateTime> allDates;      // same length as allWeights
  final double targetWeight;          // target from input
  final String weightChangeType;      // "weight_loss" / "weight_gain"

  static const int _maxVisible = 7;    // chart has 7 slots on X
  static const double _bandRange = 40; // band = target-20 .. target

  const WeightMiniChart({
    super.key,
    required this.allWeights,
    required this.allDates,
    required this.targetWeight,
    required this.weightChangeType,
  });

  @override
  Widget build(BuildContext context) {
    if (allWeights.isEmpty || allDates.isEmpty) {
      return const SizedBox.shrink();
    }

    // -------- LAST UP TO 7 POINTS --------
    final int visibleCount = math.min(_maxVisible, allWeights.length);
    final int startIndex = allWeights.length - visibleCount;

    final List<double> visibleWeights = allWeights.sublist(startIndex);
    final List<DateTime> visibleDates = allDates.sublist(startIndex);

    // X values: 0,1,2,...,visibleCount-1
    final List<FlSpot> weightSpots = List.generate(
      visibleCount,
          (i) => FlSpot(i.toDouble(), visibleWeights[i]),
    );

    // -------- Y RANGE: 0 .. (max + 10) rounded to 10 --------
    final double maxRaw = [
      ...visibleWeights,
      targetWeight,
    ].reduce((a, b) => a > b ? a : b);

    const double minY = 0;
    final double maxY = _roundUpTo10(maxRaw + 10);

    // -------- FIXED BAND: target-20 .. target across FULL 7 slots --------
    final double bandTop = targetWeight.clamp(minY, maxY);
    final double bandBottom = (targetWeight - _bandRange).clamp(minY, maxY);

    final List<FlSpot> bandTopSpots = List.generate(
      _maxVisible,
          (i) => FlSpot(i.toDouble(), bandTop),
    );

    final List<FlSpot> bandBottomSpots = List.generate(
      _maxVisible,
          (i) => FlSpot(i.toDouble(), bandBottom),
    );

    // -------- BAND COLOR: on-track or not (last vs prev) --------
    Color bandColor;
    if (visibleWeights.length >= 2) {
      final double prev = visibleWeights[visibleWeights.length - 2];
      final double last = visibleWeights.last;

      bool onTrack;
      if (weightChangeType == "weight_loss") {
        onTrack = last < prev; // going down = good
      } else if (weightChangeType == "weight_gain") {
        onTrack = last > prev; // going up = good
      } else {
        onTrack = true;
      }

      bandColor = onTrack ? const Color(0xFF3FAF58) : const Color(0xFFDA5747);
    } else {
      bandColor = const Color(0xFF3FAF58); // only one point → default green
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Analysis",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          Container(
            height: 300,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.white,
                minX: 0,
                maxX: (_maxVisible - 1).toDouble(), // always 0..6
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),

                // ========= TOOLTIP =========
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      // MUST return same length list; use null for band lines
                      return touchedSpots.map((barSpot) {
                        // we only show tooltip for actual weight line (index 2)
                        if (barSpot.barIndex != 2) return null;

                        final int i = barSpot.spotIndex;
                        if (i < 0 || i >= visibleWeights.length) return null;

                        final double current = visibleWeights[i];
                        final DateTime date = visibleDates[i];

                        final String dayStr = date.day.toString().padLeft(2, '0');
                        const monthNames = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];
                        final String monthStr = monthNames[date.month - 1];

                        String progressText;

                        if (i == 0) {
                          progressText = "Starting weight";
                        } else {
                          final double prev = visibleWeights[i - 1];
                          final double diff = current - prev;
                          final double absDiff =
                          diff.abs() < 0.05 ? 0 : diff.abs(); // ignore tiny noise

                          if (absDiff == 0) {
                            progressText = "No change";
                          } else if (weightChangeType == "weight_loss") {
                            if (diff < 0) {
                              progressText =
                              "You lost ${absDiff.toStringAsFixed(1)} kg";
                            } else {
                              progressText =
                              "You gained ${absDiff.toStringAsFixed(1)} kg";
                            }
                          } else if (weightChangeType == "weight_gain") {
                            if (diff > 0) {
                              progressText =
                              "You gained ${absDiff.toStringAsFixed(1)} kg";
                            } else {
                              progressText =
                              "You lost ${absDiff.toStringAsFixed(1)} kg";
                            }
                          } else {
                            final sign = diff > 0 ? "+" : "-";
                            progressText =
                            "Change $sign${absDiff.toStringAsFixed(1)} kg";
                          }
                        }

                        return LineTooltipItem(
                          "$dayStr $monthStr\n",
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: "${current.toStringAsFixed(1)} kg\n",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: progressText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                // ========= END TOOLTIP =========

                // ---- Dashed target line ----
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetWeight,
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                  ],
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  // ---- Y AXIS: 0..maxY, step 10 ----
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        const double eps = 0.01;
                        final int rounded = value.round();
                        if ((value - rounded).abs() < eps &&
                            rounded % 10 == 0 &&
                            rounded >= 0 &&
                            rounded <= maxY + eps) {
                          return Text(
                            rounded.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // ---- X AXIS: DateTime labels ----
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();

                        if (index < 0 || index >= visibleWeights.length) {
                          return const SizedBox.shrink();
                        }

                        final DateTime date = visibleDates[index];
                        final String dayStr = date.day.toString().padLeft(2, '0');

                        const List<String> monthNames = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];
                        final String monthStr = monthNames[date.month - 1];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayStr,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              monthStr,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // ---- LINES ----
                lineBarsData: [
                  // 0: band bottom (hidden)
                  LineChartBarData(
                    spots: bandBottomSpots,
                    isCurved: false,
                    barWidth: 0,
                    color: Colors.transparent,
                    dotData: FlDotData(show: false),
                  ),
                  // 1: band top (hidden)
                  LineChartBarData(
                    spots: bandTopSpots,
                    isCurved: false,
                    barWidth: 0,
                    color: Colors.transparent,
                    dotData: FlDotData(show: false),
                  ),
                  // 2: actual weight line
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: false,
                    barWidth: 2,
                    color: const Color(0xFF308BF9),
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.black87,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],

                // ---- COLOURED BAND: target-20..target across 0..6 ----
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 0, // band bottom
                    toIndex: 1,   // band top
                    color: bandColor.withOpacity(0.18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// helper: round up to nearest multiple of 10
double _roundUpTo10(double value) {
  return (value / 10).ceil() * 10.0;
}
