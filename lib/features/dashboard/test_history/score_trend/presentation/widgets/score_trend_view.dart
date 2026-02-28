import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard/test_history/score_trend/presentation/widgets/score_line_chart_view.dart';
import '../../bloc/score_trend_bloc.dart';
import '../../bloc/score_trend_event.dart';
import '../../bloc/score_trend_state.dart';

class ScoreTrendView extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  const ScoreTrendView({super.key, required this.clientProfileModel});

  @override
  Widget build(BuildContext context) {
    // Dispatch the event to fetch data
    BlocProvider.of<ScoreTrendBloc>(context)
        .add(FetchMetabolismData(clientProfileModel.profileId));

    String formattedDate(DateTime date) {
      return DateFormat('dd MMM').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ScoreTrendBloc, ScoreTrendState>(
          builder: (context, state) {
            if (state is ScoreTrendLoaded) {
              if (state.scores.isEmpty) {
                return const Center(child: Text('No History found'));
              }

              final scoresList = state.scores; // assuming oldest → newest
              const int maxSlots = 7;
              final int total = scoresList.length;

              // index of first point in the visible 7-day window
              final int startIndexForRange =
              total > maxSlots ? total - maxSlots : 0;

              // Parse visible start and end dates
              final DateTime startDate =
                  DateTime.tryParse(scoresList[startIndexForRange].dateTime) ??
                      DateTime.now();
              final DateTime endDate =
                  DateTime.tryParse(scoresList.last.dateTime) ??
                      DateTime.now();

              // ===============================
              //   CALCULATE % CHANGE (TODAY vs YESTERDAY)
              // ===============================
              final double today = scoresList.last.fatLossScore;
              final double yesterday = scoresList.length > 1
                  ? scoresList[scoresList.length - 2].fatLossScore
                  : today;

              final double diff = today - yesterday;
              final double percentChange =
              yesterday == 0 ? 0 : (diff / yesterday) * 100;

              final String formattedChange =
                  "${percentChange.abs().toStringAsFixed(0)}%";

              final bool isUp = percentChange > 0;
              final bool isDown = percentChange < 0;
              final bool isEqual = !isUp && !isDown;

              final Color valueColor = isUp
                  ? const Color(0xFF3FAF58) // green
                  : isDown
                  ? const Color(0xFFDA5747) // red
                  : const Color(0xFF252525); // neutral

              final String? arrowIcon = isEqual
                  ? null
                  : isUp
                  ? "assets/images/icons/icon_score_up.svg"
                  : "assets/images/icons/icon_score_down.svg";

              final String labelText =
              isEqual ? "same as yesterday" : "than yesterday";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Score Trend",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),

                  // e.g. "01 Dec - 07 Dec"
                  Text(
                    "${formattedDate(startDate)} - ${formattedDate(endDate)}",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.26,
                      letterSpacing: -0.30,
                    ),
                  ),

                  const SizedBox(height: 33),

                  // ========= CHANGE ROW =========
                  Row(
                    children: [
                      Text(
                        formattedChange,
                        style: GoogleFonts.poppins(
                          color: valueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.36,
                        ),
                      ),

                      // spacing between % and icon/text
                      const SizedBox(width: 5),

                      // Only show icon if not equal
                      if (!isEqual && arrowIcon != null) ...[
                        SvgPicture.asset(
                          arrowIcon,
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 5),
                      ],

                      Text(
                        labelText,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1A1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 23.5),

                  ScoreLineChartView(
                    scores: scoresList
                        .map((score) => score.fatLossScore)
                        .toList(),
                    dates: scoresList
                        .map((score) => score.dateTime)
                        .toList(),
                    scoreName: 'Fat Loss Metabolism Score',
                  ),
                ],
              );
            }

            if (state is ScoreTrendError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Error loading scores: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            // Fallback (loading or initial)
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
