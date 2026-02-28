import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/model/water_intake_data.dart';

class WaterBarChart extends StatelessWidget {
  final double targetWaterInML; // kept for compatibility (not used directly)
  final List<WaterIntakeDay> days;

  const WaterBarChart({
    super.key,
    required this.days,
    required this.targetWaterInML,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return Center(
        child: Text(
          "Not yet tracked",
          style: GoogleFonts.poppins(
            color: const Color(0xFFA1A1A1),
            fontSize: 12,
          ),
        ),
      );
    }


    double maxTargetLiters = 0;
    double maxConsumedLiters = 0;

    for (final d in days) {
      if (d.targetLiters > maxTargetLiters) {
        maxTargetLiters = d.targetLiters;
      }
      if (d.consumedLiters > maxConsumedLiters) {
        maxConsumedLiters = d.consumedLiters;
      }
    }

    double axisMaxY =
    maxTargetLiters > 0 ? maxTargetLiters : maxConsumedLiters;
    if (axisMaxY <= 0) axisMaxY = 1;
    axisMaxY = axisMaxY.ceilToDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: axisMaxY,
        barGroups: _buildGroups(days),
        alignment: BarChartAlignment.spaceAround,

        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBorderRadius: BorderRadius.circular(12),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            tooltipMargin: 8,
            maxContentWidth: 140,
            // Background color now via getTooltipColor
            getTooltipColor: (group) => const Color(0xFF2F80FF),

            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              if (index < 0 || index >= days.length) return null;

              final dayData = days[index];
              final consumed = dayData.consumedLiters;
              final target = dayData.targetLiters;

              return BarTooltipItem(
                '${consumed.toStringAsFixed(1)} litres\n',
                GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: 'Target: ${target.toStringAsFixed(1)}L',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFFFC1C1).withOpacity(0.5),
            strokeWidth: 0.4,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xFFFFC1C1).withOpacity(0.3),
            strokeWidth: 0.4,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}L',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: -0.20,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                final day = days[index].date;
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${day.day.toString().padLeft(2, '0')}\n${months[day.month - 1]}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA1A1A1),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      letterSpacing: -0.20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups(List<WaterIntakeDay> days) {
    const blue = Color(0xFF2F80FF);
    const greyTrack = Color(0xFFD3D3D3);

    return List.generate(days.length, (index) {
      final d = days[index];

      double trackMaxY = d.targetLiters;
      if (trackMaxY <= 0) {
        trackMaxY = d.consumedLiters;
      }
      if (trackMaxY <= 0) {
        trackMaxY = 1;
      }

      final consumed = d.consumedLiters.clamp(0, trackMaxY);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            width: 18,
            toY: trackMaxY,
            borderRadius: BorderRadius.circular(0),
            rodStackItems: [
              // Grey track 0 → target
              BarChartRodStackItem(0, trackMaxY, greyTrack),

              // Blue consumed 0 → consumed
              if (consumed > 0)
                BarChartRodStackItem(
                  0,
                  consumed.toDouble(),
                  blue,
                ),
            ],
          ),
        ],
      );
    });
  }
}
