import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import '../../../../../core/score_manager/score_color.dart';
import '../../../../../core/score_manager/score_gradient.dart';
import '../../data/modal/score_point.dart';

Widget scoreTrendChart({
  required List<ScorePoint> series,
}) {


  final spots = <FlSpot>[];
  for (int i = 0; i < series.length; i++) {
    spots.add(FlSpot(i.toDouble(), series[i].value));
  }



  return  SizedBox(
    height: 180,
    child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (series.length - 1).toDouble(),
          minY: 0,
          maxY: 100,

          // === GRID OFF ===
          gridData: FlGridData(show: false),

          // === AXIS LINES (BORDERS) ===
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(
                color: Color(0xFFE5E5E5), // Y-axis line color
                width: 1,
              ),
              bottom: BorderSide(
                color: Color(0xFFE5E5E5), // X-axis line color
                width: 1,
              ),
              right: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              top: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
            ),
          ),

          titlesData: FlTitlesData(
            // ===== Y AXIS =====
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  if (value % 25 != 0) return const SizedBox.shrink();

                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFFA1A1A1),
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -0.20,
                    ),
                  );
                },
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // ===== X AXIS =====
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= series.length) {
                    return const SizedBox.shrink();
                  }

                  final d = series[index].date;
                  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.day.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Color(0xFFA1A1A1),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                      Text(
                        months[d.month - 1],
                        style: const TextStyle(
                          color: Color(0xFFA1A1A1),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.20,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 2,                    // thick smooth line
              dotData: FlDotData(show: series.length > 1 ?false:true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: scoreGradient(series.last.value),
                ),
              ),
              spots: spots,
              color: ScoreColors().getScoreColor(score: series.last.value), // dark grey line
            ),
          ],
        )
    ),
  );
}