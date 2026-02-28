import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/model/diet_plan_strategy_model.dart';
import '../../extras/date_helper.dart';


class PlanHistoryWidgets {
  Widget planHistoryItem({
    required DietPlanStrategyModel dietPlanStrategyModel,
  }) {
    final isCancelled = dietPlanStrategyModel.status == "cancelled";
    final isCompleted = dietPlanStrategyModel.status == "completed";

    final statusIcon = isCancelled
        ? 'assets/images/icons/ic_cancelled.svg'
        : 'assets/images/icons/ic_finished.svg';

    final statusText = isCompleted
        ? "Completed"
        : isCancelled
        ? "Cancelled"
        : "";

    final statusColor = isCancelled
        ? const Color(0xFFA1A1A1)
        : const Color(0xFF3EAF58);

    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left column: Title + Updated Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dietPlanStrategyModel.planTitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                    letterSpacing: -0.72,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  formatToDayMonth(dietPlanStrategyModel.updatedAt),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.20,
                  ),
                ),
              ],
            ),

            // Right column: Date range + Status
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${formatToDayMonth(dietPlanStrategyModel.planStartDate)} - ${formatToDayMonth(dietPlanStrategyModel.planEndDate)}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SvgPicture.asset(statusIcon),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
