import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/graph_model.dart';

class ProgressGraph extends StatelessWidget {
  final List<GraphModel> data;

  const ProgressGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    double maxDataValue = data.map((e) => e.value).reduce(max);
    double calculatedMaxY = (maxDataValue > 100) ? maxDataValue * 1.2 : 105;

    return LineChart(
      LineChartData(
        // CHANGED: Increased maxX from 6.2 to 6.5 so the final dot doesn't hit the right wall
        minX: 0,
        maxX: 6.5,

        minY: 0,
        maxY: calculatedMaxY,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          checkToShowHorizontalLine: (value) => value == 60 || value == 90,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color.fromARGB(255, 161, 161, 161),
            dashArray: [12, 20],
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color.fromARGB(255, 217, 217, 217),
            dashArray: [6, 6],
            strokeWidth: 1,
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > 100) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 161, 161, 161),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                // Ignore non-integer values
                if (value % 1 != 0) {
                  return const SizedBox.shrink();
                }

                final index = value.toInt();

                // Safety Check: Only indices 0-6 allowed
                if (index > 6) return const SizedBox.shrink();

                DateTime date;
                if (index < data.length) {
                  date = data[index].date;
                } else {
                  final lastDate = data.last.date;
                  final difference = index - (data.length - 1);
                  date = lastDate.add(Duration(days: difference));
                }

                final monthName = _getMonthName(date.month);
                final dayString = date.day.toString().padLeft(2, '0');

                return Text(
                  "$dayString\n$monthName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color.fromARGB(255, 161, 161, 161),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(
              color: Color.fromARGB(255, 217, 217, 217),
              width: 1,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(255, 217, 217, 217),
              width: 1,
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            color: Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(
                    255,
                    48,
                    173,
                    249,
                  ).withValues(alpha: 0.35),
                  const Color.fromARGB(0, 48, 139, 249).withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.x == barData.spots.last.x,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.blue,
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
