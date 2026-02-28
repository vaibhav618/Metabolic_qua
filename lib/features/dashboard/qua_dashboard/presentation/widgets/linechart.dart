import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/metabolism_bloc.dart';
import '../../bloc/metabolism_event.dart';
import '../../data/models/metabolism_score.dart';
import '../../data/repository/metabolism_score_repository.dart';

class MetabolismChartContainer extends StatefulWidget {
  final String dietitianId;
  final String profileId;
  final double minRange, maxRange;

  final void Function(bool noDataAvailable) noDataAvailable;

  const MetabolismChartContainer({
    super.key,
    required this.dietitianId,
    required this.profileId,
    required this.minRange,
    required this.maxRange,
    required this.noDataAvailable,
  });

  @override
  State<MetabolismChartContainer> createState() =>
      _MetabolismChartContainerState();
}

class _MetabolismChartContainerState extends State<MetabolismChartContainer> {
  late final MetabolismBloc _metabolismBloc;

  @override
  void initState() {
    super.initState();

    final repository = MetabolismRepository();
    _metabolismBloc = MetabolismBloc(repository);

    _metabolismBloc.add(
      FetchMetabolismData(
        widget.dietitianId,
        widget.profileId,
      ),
    );
  }

  @override
  void dispose() {
    _metabolismBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _metabolismBloc,
      child: BlocBuilder<MetabolismBloc, MetabolismState>(
        builder: (context, state) {
          if (state is MetabolismLoading) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is MetabolismLoaded) {
            // ✅ FIX: call parent AFTER build finishes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.noDataAvailable(false);
            });

            return ScoreLineChart(
              data: state.scores.reversed.toList(),
              minRange: widget.minRange,
              maxRange: widget.maxRange,
            );
          }

          if (state is MetabolismError) {
            // ✅ FIX: call parent AFTER build finishes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.noDataAvailable(true);
            });

            // Return something in error state
            return const SizedBox(height: 220);
          }

          return const SizedBox(height: 220);
        },
      ),
    );
  }
}

// --- UI WIDGET (Using MetabolismScore) ---
class ScoreLineChart extends StatelessWidget {
  const ScoreLineChart({
    super.key,
    required this.data,
    required this.minRange,
    required this.maxRange,
  });

  final List<MetabolismScore> data;
  final double minRange;
  final double maxRange;

  static const Color rangeColor = Color(0x66E1E6ED);

  @override
  Widget build(BuildContext context) {
    final List<MetabolismScore> displayData =
    data.length > 7 ? data.sublist(data.length - 7) : data;

    const double maxX = 6.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: 0,
          maxY: 100,
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: minRange,
                y2: 100,
                color: rangeColor,
              ),
            ],
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false,
            drawVerticalLine: true,
            verticalInterval: 1,
            getDrawingVerticalLine: (v) => FlLine(
              color: const Color(0xFFA1A1A1),
              strokeWidth: 1,
              dashArray: [6, 6],
            ),
          ),
          borderData: FlBorderData(show: false),

          // ✅ TOOLTIP + TOUCH DESIGN ADDED
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchSpotThreshold: 24,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: const Color(0xFF308BF9).withOpacity(0.35),
                    strokeWidth: 1,
                    dashArray: [6, 6],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, idx) => FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF308BF9),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              tooltipMargin: 12,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBorder: BorderSide(
                color: const Color(0xFF308BF9).withOpacity(0.25),
                width: 1,
              ),

              getTooltipColor: (touchedSpot) => Colors.black.withOpacity(0.85),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((t) {
                  final i = t.x.toInt();

                  String dateLabel = "";
                  if (i >= 0 && i < displayData.length) {
                    final dt = DateTime.parse(displayData[i].date);
                    dateLabel = DateFormat("dd MMM").format(dt);
                  }

                  final score = t.y.toStringAsFixed(0);

                  return LineTooltipItem(
                    "$score%\n",
                    GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: dateLabel,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 32,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 38,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < displayData.length) {
                    final dateTime = DateTime.parse(displayData[index].date);
                    return _dateTitle(
                      DateFormat('dd').format(dateTime),
                      DateFormat('MMM').format(dateTime),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                displayData.length,
                    (i) => FlSpot(i.toDouble(), displayData[i].score),
              ),
              isCurved: false,
              barWidth: 2,
              color: const Color(0xFF308BF9),
              dotData: data.length <= 1
                  ? const FlDotData(show: true)
                  : const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );

  }

  Widget _dateTitle(String day, String month) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              color: const Color(0xFFA1A1A1),
              fontSize: 9,
            ),
          ),
          Text(
            month,
            style: GoogleFonts.poppins(
              color: const Color(0xFFA1A1A1),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
