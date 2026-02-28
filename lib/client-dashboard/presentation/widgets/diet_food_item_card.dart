import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../extras/meal_type_helper.dart';

class DietPlanWidgets {
  Widget dietFoodItemCard({
    required int index,
    required String foodName,
    required String foodCalories,
    required String foodPortion,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 100),
        width: double.infinity,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
        child: Stack(
          children: [
            // Background with opacity
            Opacity(
              opacity: 0.5,
              child: Container(
                height: double.infinity,
                decoration: ShapeDecoration(
                  gradient: ThemeHelper().getDietItemGradient(),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ),

            // Foreground content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index.toString(),
                    style: GoogleFonts.poppins(
                      color: ThemeHelper().getThemeDarkColor(),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.26,
                      letterSpacing: -0.50,
                    ),
                  ),

                  // Center column for food details
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 Prevent overflow here
                        Text(
                          foodName,
                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.26,
                            letterSpacing: -0.30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          foodPortion,
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

                  Text(
                    foodCalories,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF535359),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
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
}
