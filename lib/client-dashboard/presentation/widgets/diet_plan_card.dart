import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/presentation/widgets/target_item.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

import '../../data/model/diet_plan_strategy_model.dart';
import '../../extras/date_helper.dart';
import '../screens/client_overall_plan_screen.dart';

class PlanCard extends StatelessWidget {
  final List<DietPlanStrategyModel> activeData;
  final List<DietPlanStrategyModel> completedData;
  final List<DietPlanStrategyModel> canceledData;
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianDetailModel;

  const PlanCard({
    super.key,
    required this.activeData,
    required this.completedData,
    required this.canceledData, required this.clientProfileModel, required this.dietitianDetailModel,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveData = activeData.isNotEmpty;
    final displayModel = hasActiveData ? activeData.first : null;

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              children: [
                Expanded(
                  child: Text(
                    hasActiveData ? displayModel!.planTitle : "No Active Plan",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -0.72,
                    ),
                  ),
                ),
                Text(
                  hasActiveData
                      ? "${formatToDayShortMonth(displayModel!.planStartDate)} - ${formatToDayShortMonth(displayModel.planEndDate)}"
                      : "-",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          // View All Plans Link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientOverallPlanScreen(
                      activeData: activeData.first,
                      completedData: completedData,
                      canceledData: canceledData, clientProfileModel: clientProfileModel, dietitianDetailModel: dietitianDetailModel,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    "View all plans",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF308BF9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                      letterSpacing: -0.24,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_outlined,size: 15,
                    color: Color(0xFF308BF9),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),
          Container(
            color: const Color(0xFFD7D6D6),
            height: 1,
            width: double.infinity,
          ),
          const SizedBox(height: 15),

          // Daily Target Header
          Row(
            children: [
              SvgPicture.asset("assets/images/icons/ic_target.svg"),
              const SizedBox(width: 5),
              Text(
                "Daily Target",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.10,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Target Items Row 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                targetItem(
                  targetLabel: 'Calories',
                  targetIntake: 'Kcal',
                  targetValue: hasActiveData
                      ? displayModel!.caloriesTarget.toDouble()
                      : 0,
                ),
                targetItem(
                  targetLabel: 'Protein',
                  targetIntake: 'gram',
                  targetValue: hasActiveData
                      ? displayModel!.proteinTarget.toDouble()
                      : 0,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Target Items Row 2
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                targetItem(
                  targetLabel: 'Fibre',
                  targetIntake: 'gram',
                  targetValue: hasActiveData
                      ? displayModel!.fiberTarget.toDouble()
                      : 0,
                ),
                targetItem(
                  targetLabel: 'Water',
                  targetIntake: 'ml',
                  targetValue: hasActiveData ? displayModel!.waterTarget : 0,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.5),
        ],
      ),
    );
  }
}