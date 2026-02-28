import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import '../../../../bluetooth_device_connectivity/data/model/generating_result_model.dart';
import '../../../../bluetooth_device_connectivity/presentation/widgets/metabolism_scale.dart';
import '../../../../dashboard/test_history/score_trend/bloc/score_trend_bloc.dart';
import '../../../../dashboard/test_history/score_trend/bloc/score_trend_event.dart';
import '../../../../dashboard/test_history/score_trend/data/repository/score_trend_repository.dart';
import '../../../../dashboard/test_history/score_trend/presentation/widgets/score_trend_view.dart';
import '../../../../dietitian_result_screen/presentation/pages/overall_metabolism_score.dart' hide MetabolismScale;

class TestResultHistory extends StatefulWidget {
  final GeneratingResultModel? result;
  final ClientProfileModel clientProfileModel;

  const TestResultHistory({
    super.key,
    required this.result,
    required this.clientProfileModel,
  });

  @override
  State<TestResultHistory> createState() => _TestResultHistoryState();
}

class _TestResultHistoryState extends State<TestResultHistory> {

  Color getZoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case "poor":
        return const Color(0xFFDA5747); // red
      case "fair":
        return const Color(0xFFF8B10F); // yellow
      case "Optimal":
        return const Color(0xFF3FAF58); // green
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime dateTime) {
    final dayMonth = DateFormat("dd MMMM").format(dateTime); // 05 July
    final time = DateFormat("hh:mm a").format(dateTime); // 12:30 PM
    return "$dayMonth, ${time.toLowerCase()}"; // 05 July, 12:30 pm
  }

  @override
  Widget build(BuildContext context) {
    // Safe getters
    final result = widget.result;
    final fatLossScoreModel = result?.respyrResponse?.fatLossMetabolismScore;

    final bool hasResult = fatLossScoreModel != null;

    final double score = fatLossScoreModel?.score ?? 0;
    final String zone = fatLossScoreModel?.zone ?? "";
    final String interpretation =
        fatLossScoreModel?.clientInterpretation ?? "-";

    final DateTime? testDateTime = result?.dateTime;
    final String formattedDate =
    testDateTime == null ? "" : formatDate(testDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today’s Metabolism Score",
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),

          Visibility(
            visible: hasResult,
            replacement: Text("Not yet tracked",
              style: GoogleFonts.poppins(
                color: const Color(0xFFA1A1A1),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // keeping your spacing usage
              spacing: 15,
              children: [
                Row(
                  spacing: 2,
                  children: [
                    SvgPicture.asset("assets/images/icons/ic_test_check.svg"),
                    Text(
                      "Completed",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF3EAF58),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ],
                ),

                // if you want to show date
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.10,
                      letterSpacing: -0.24,
                    ),
                  ),
              ],
            ),
          ),

           Visibility(
             visible: hasResult,
             replacement: SizedBox(height: 42,),
               child: SizedBox(height: 20),
           ),

          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 15,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: hasResult,
                  replacement: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "-",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 100,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        "%",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.40,
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        score.toStringAsFixed(0),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 100,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        "%",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                          letterSpacing: -0.40,
                        ),
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: hasResult,
                  child: const SizedBox(height: 60),
                ),

                Visibility(
                  visible: hasResult,
                  child: MetabolismScale(value: score),
                ),

                Visibility(
                  visible: hasResult,
                  child: const SizedBox(height: 37),
                ),

                Visibility(
                  visible: hasResult,
                  child: RichText(
                    text: TextSpan(
                      text: "You’re Score is ",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                      children: [
                        TextSpan(
                          text: zone.isEmpty ? "-" : "$zone!",
                          style: GoogleFonts.poppins(
                            color: getZoneColor(zone),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: hasResult,
                  child: const SizedBox(height: 40),
                ),

                Visibility(
                  visible: hasResult,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      interpretation,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF535359),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.30,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 37),

                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE1E6ED),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View Test History",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF308BF9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right_outlined,
                        color: Color(0xFF308BF9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 44,),
          // Wrap ScoreTrendView with BlocProvider
          BlocProvider(
            create: (_) => ScoreTrendBloc(ScoreTrendRepository())..add(FetchMetabolismData(widget.clientProfileModel.profileId)),
            child: ScoreTrendView(clientProfileModel: widget.clientProfileModel),
          ),

        ],
      ),
    );
  }
}
