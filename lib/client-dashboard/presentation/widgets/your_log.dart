import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../model/plan_stats.dart';
import '../../services/diet_plan_stat_service.dart';

class YourLog extends StatelessWidget {
  final ClientProfileModel clientProfileModel;
  final String dietPlanId;

  const YourLog({
    super.key,
    required this.clientProfileModel,
    required this.dietPlanId,
  });

  @override
  Widget build(BuildContext context) {
    final api = DietPlanStatService();

    Widget statBox({
      required String title,
      required String bigValue,
      required String outOfLabel,
    }) {
      return Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFF0F5FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.24,
                )),
            const SizedBox(height: 20),
            Text(bigValue,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.40,
                )),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "out of ",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.20,
                    )),
                TextSpan(
                    text: outOfLabel,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.20,
                    )),
              ]),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<DietPlanStatApi>(
      future: api.fetchPlanStats(
        dietitianId: clientProfileModel.dietitianId,
        clientId: clientProfileModel.profileId,
        dietPlanId: dietPlanId,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: Text('No data'));
        }

        final stats = snap.data!.data;

        return Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              collapsedShape: const RoundedRectangleBorder(),
              shape: const RoundedRectangleBorder(),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 31),
              title: Text(
                'Your Log',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                  letterSpacing: -0.72,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      // ---- Test Log header
                      Row(
                        children: [
                          SvgPicture.asset("assets/images/icons/ic_food_log.svg"),
                          const SizedBox(width: 8),
                          Text(
                            "Test Log",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),

                      // ---- Tests row
                      Row(
                        children: [
                          Expanded(
                            child: statBox(
                              title: "Tests taken",
                              bigValue: stats.testsTaken.toString(),
                              outOfLabel: "${stats.testsTotal} tests",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: statBox(
                              title: "Tests missed",
                              bigValue: stats.testsMissed.toString(),
                              outOfLabel: "${stats.testsTotal} tests",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Plan days till today: ${stats.planTotalDays}",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 19.5),
                      InkWell(
                        onTap: () {
                          // TODO: navigate to test history
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tests history",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF308BF9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right_outlined, color: Color(0xFF308BF9)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 19.5),
                      Container(height: 1, width: double.infinity, color: const Color(0xFFCAE1FF)),
                      const SizedBox(height: 19.5),

                      // ---- Meal Log header
                      Row(
                        children: [
                          SvgPicture.asset("assets/images/icons/ic_food_log.svg"),
                          const SizedBox(width: 8),
                          Text(
                            "Meal Log",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF252525),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.10,
                              letterSpacing: -0.24,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),

                      // ---- Meals row
                      Row(
                        children: [
                          Expanded(
                            child: statBox(
                              title: "Days logged",
                              bigValue: stats.foodLogDays.toString(),
                              outOfLabel: "${stats.planTotalDays} days",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: statBox(
                              title: "Days missed",
                              bigValue: stats.foodLogMissed.toString(),
                              outOfLabel: "${stats.planTotalDays} days",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Entries: ${stats.foodLogCount}",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF535359),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 19.5),
                      InkWell(
                        onTap: () {
                          // TODO: navigate to meal log history
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Meal log history",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF308BF9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.24,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right_outlined, color: Color(0xFF308BF9)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
