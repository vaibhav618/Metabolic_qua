import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:respyr_dietitian/features/test_result/test_histoty/presentation/widget/score_progress.dart';
import 'package:respyr_dietitian/features/test_result/test_histoty/presentation/widget/score_trend.dart';
import '../../data/modal/score_point.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

Widget scoreTrendCard({
  required String title,
  required List<ScorePoint> series,
}) {
  if (series.isEmpty) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF252525),
              ),
            ),
            Text(
              "No data",
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final spots = <FlSpot>[];
  for (int i = 0; i < series.length; i++) {
    spots.add(FlSpot(i.toDouble(), series[i].value));
  }


  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          color: const Color(0xFF252525),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.10,
          letterSpacing: -0.24,
        ),
      ),
      const SizedBox(height: 20.5),
      if(series.length  > 2)
      scoreDifference(
          scoreCurrent:  series.last.value.toDouble(),
          scorePrevious: series[series.length - 2].value.toDouble()
      ),
      const SizedBox(height: 20.5),
      scoreTrendChart(series: series),
    ],
  );
}
