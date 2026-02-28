import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../core/size/get_height.dart';
import '../../../bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';
import '../cubit/dietitian_result_state.dart';
import 'result_overview_card.dart';

class ResultOverViewScreen extends StatelessWidget {
  final DietitianResultState state;
  final ClientProfileModel clientProfileModel;
  final TestResultResponse result;

  const ResultOverViewScreen({
    super.key,
    required this.state,
    required this.clientProfileModel,
    required this.result,
  });

  Color getZoneColor(String zone) {
    switch (zone.toLowerCase()) {
      case "focus":
        return const Color(0xFFE48326);
      case "moderate":
        return const Color(0xFFFFBF2D);
      case "optimal":
        return const Color(0xFF3FAF58);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {


    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rh(context: context, px: 16),
              vertical: rh(context: context, px: 10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: rh(context: context, px: 1),
                        color: const Color(0xFFC7C6CE),
                      ),
                      borderRadius: BorderRadius.circular(
                        rh(context: context, px: 10),
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 14),
                    horizontal: rh(context: context, px: 17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Fat-Use\nPattern Trend",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: rh(context: context, px: 20),
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: rh(context: context, px: -0.40),
                          ),
                        ),
                      ),
                      SizedBox(width: rh(context: context, px: 20)),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              "${result.respyrResponse.fatUsePatternTrend.score.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: rh(context: context, px: 34),
                                fontWeight: FontWeight.w400,
                                height: 1.10,
                                letterSpacing: rh(context: context, px: -2.04),
                              ),
                            ),
                            Text(
                              result.respyrResponse.fatUsePatternTrend.zone,
                              style: GoogleFonts.poppins(
                                color: getZoneColor(
                                  result.respyrResponse.fatUsePatternTrend.zone,
                                ),
                                fontSize: rh(context: context, px: 12),
                                fontWeight: FontWeight.w700,
                                height: 1.10,
                                letterSpacing: rh(context: context, px: -0.24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rh(context: context, px: 30)),
                Text(
                  'Scores Overview',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 20),
                    fontWeight: FontWeight.w700,
                    letterSpacing: rh(context: context, px: -0.4),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "assets/images/result_screen/human.png",
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.55,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rh(context: context, px: 10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: rh(context: context, px: 15)),
                      ResultOverviewCard(
                        metabolismType: 'Fat',
                        state: state,
                        result: result,
                      ),
                      SizedBox(height: rh(context: context, px: 25)),
                      ResultOverviewCard(
                        metabolismType: 'Gut',
                        state: state,
                        result: result,
                      ),
                      SizedBox(height: rh(context: context, px: 25)),
                      ResultOverviewCard(
                        metabolismType: 'Liver',
                        state: state,
                        result: result,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rh(context: context, px: 16),
                vertical: rh(context: context, px: 10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scores Interpretation',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: rh(context: context, px: 20),
                      fontWeight: FontWeight.w700,
                      letterSpacing: rh(context: context, px: -0.4),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 8)),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF252525),
                        fontSize: rh(context: context, px: 12),
                        fontWeight: FontWeight.w400,
                        height: 1.26,
                        letterSpacing: rh(context: context, px: -0.24),
                      ),
                      children: [
                        const TextSpan(
                          text:
                          'Scores interpretations are based on the values recorded by Respyr device. Please refer to the reference ',
                        ),
                        TextSpan(
                          text: 'link',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF308BF9),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' for more details.'),
                      ],
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
