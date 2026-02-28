import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/log_meal_screen.dart';

void showLogMealBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // important for dynamic height
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // avoid keyboard overlap
        ),
        child: SingleChildScrollView( // ✅ makes it wrap content
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ dynamic height
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF7AD), Colors.white],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 54),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.keyboard_arrow_left_outlined,
                            color: Color(0xFFAC9C0C)),
                        Column(
                          children: [
                            Text("Wake up",
                                style: TextStyle(
                                    color: Color(0xFFAC9C0C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24)),
                            Text("06:00-06:30AM",
                                style: TextStyle(
                                    color: Color(0xFFAC9C0C),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.10,
                                    letterSpacing: -0.72)),
                          ],
                        ),
                        Icon(Icons.keyboard_arrow_right_outlined,
                            color: Color(0xFFAC9C0C)),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text("Meal Macro Goal",
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF252525),
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -2.04,
                            height: 1.2)),
                    Text("3 items",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.10,
                          letterSpacing: -0.24,
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 78),

              // Macro Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true, // ✅ no fixed height
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  mainAxisSpacing: 20,
                  children: [
                    _macroCard("Calories", "1500", "kcal/day"),
                    _macroCard("Protein", "90", "g/day"),
                    _macroCard("Carbs", "200", "g/day"),
                    _macroCard("Fat", "50", "g/day"),
                  ],
                ),
              ),

              const SizedBox(height: 78),

              // Log button
              Center(
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogMealScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/images/icons/ic_food.svg",
                          color: const Color(0xFF308BF9)),
                      const SizedBox(width: 8),
                      Text("Log this meal",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF308BF9),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.30,
                          )),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                          "assets/images/icons/ic_arrow_right_outline.svg"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      );
    },
  );
}

// Reusable widget for macro stats
Widget _macroCard(String label, String value, String unit) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label,
          style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.24)),
      const SizedBox(height: 10),
      Text(value,
          style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.50)),
      Text(unit,
          style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20)),
    ],
  );
}
