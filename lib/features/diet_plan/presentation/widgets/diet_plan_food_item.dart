
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'log_food_sheet.dart';

Widget dietPlanFoodItem({
  required int index,
  required String mealTitle,
  required String foodName,
  required String foodType,
  required String foodScale,
  required String foodCalories,
  required String foodProtein,
  required String foodFat,
  required String foodCarbs,
  required BuildContext context,
  required bool isLogged,
  required VoidCallback onLogged,
  required VoidCallback onAlreadyLogged,
  required String dieticianId,
  required String profileId,
  required String dietPlanId,
  required bool canLog,
  required DateTime logDate,
  required String mealTime,
  required DateTime logDateTime,
}) {
  Future<void> insertFoodLog() async {
    if (!canLog) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only log today or previous days")),
      );
      return;
    }

    LogFoodSheet().showFoodBottomSheet(
      context: context,
      mealTitle: mealTitle,
      index: index,
      foodName: foodName,
      foodType: foodType,
      foodScale: foodScale,
      foodCalories: foodCalories,
      foodProtein: foodProtein,
      foodFat: foodFat,
      foodCarbs: foodCarbs,
      isLogged: isLogged,
      onLogged: onLogged,
      onAlreadyLogged: onAlreadyLogged,
      dieticianId: dieticianId,
      profileId: profileId,
      dietPlanId: dietPlanId,
      logDate: logDate,
      mealTime: mealTime,
      logDateTime: logDateTime,
    );
  }

  return GestureDetector(
    onTap: insertFoodLog,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index.toString(),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.30,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.26,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  foodScale,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$foodCalories kcal",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
