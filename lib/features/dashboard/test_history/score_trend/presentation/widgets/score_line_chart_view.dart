import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScoreLineChartView extends StatelessWidget {
  final List<double> scores;
  final List<String> dates;
  final String scoreName;

  const ScoreLineChartView({
    super.key,
    required this.scores,
    required this.dates,
    required this.scoreName,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty || dates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'No data available',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF535359),
          ),
        ),
      );
    }

    const int maxSlots = 7;

    // Take LAST maxSlots points
    final int totalPoints = scores.length;
    final int startIndex = totalPoints > maxSlots ? totalPoints - maxSlots : 0;

    final List<double> visibleScores = scores.sublist(startIndex);
    final List<String> visibleDates = dates.sublist(startIndex);

    final int pointCount = visibleScores.length;
    if (pointCount == 0) return const SizedBox.shrink();

    return  SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (maxSlots - 1).toDouble(),

          // Fixed Y-axis 0 → 100
          minY: 0,
          maxY: 100,

          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false,
            drawVerticalLine: true,
            verticalInterval: 1, // lines at each x index (0..6)
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color(0xFFD9D9D9), // #D9D9D9
                strokeWidth: 1,
                dashArray: [4, 4], // dashed
              );
            },
          ),

          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipMargin: 10,
              maxContentWidth: 120,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBorder: const BorderSide(
                color: Color(0xFFE1E6ED),
                width: 1,
              ),
              getTooltipColor: (touchedSpot) => Colors.white,
              getTooltipItems: (touchedSpots) {
                return touchedSpots
                    .map<LineTooltipItem?>((touchedSpot) {
                  final index = touchedSpot.spotIndex;
                  if (index < 0 || index >= pointCount) return null;

                  final rawDate = visibleDates[index];
                  final parsed = DateTime.tryParse(rawDate);
                  final dateLabel = parsed != null
                      ? DateFormat('dd MMM').format(parsed)
                      : rawDate;

                  final score = visibleScores[index].clamp(0, 100);
                  final scoreLabel = "${score.toStringAsFixed(0)}%";

                  return LineTooltipItem(
                    "$dateLabel\n",
                    GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF252525),
                    ),
                    children: [
                      TextSpan(
                        text: scoreLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF535359),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // Y-axis labels: 0, 20, 40, 60, 80, 100
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value % 20 != 0 || value < 0 || value > 100) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toInt().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
              ),
            ),

            // X-axis labels: "01" + "Dec"
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= pointCount) {
                    return const SizedBox.shrink();
                  }

                  final raw = visibleDates[index];
                  final parsed = DateTime.tryParse(raw);

                  String day = '';
                  String month = '';
                  if (parsed != null) {
                    day = DateFormat('dd').format(parsed);
                    month = DateFormat('MMM').format(parsed);
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          month,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide(color: Colors.transparent),
              right: BorderSide(color: Colors.transparent),
              left: BorderSide(color: Color(0xFFE1E6ED)),
              bottom: BorderSide(color: Color(0xFFE1E6ED)),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                pointCount,
                    (i) => FlSpot(
                  i.toDouble(),
                  visibleScores[i],
                ),
              ),
              isCurved: true,
              barWidth: 3,
              color: const Color(0xFF308BF9),
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF308BF9).withOpacity(0.35),
                    const Color(0xFF308BF9).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
