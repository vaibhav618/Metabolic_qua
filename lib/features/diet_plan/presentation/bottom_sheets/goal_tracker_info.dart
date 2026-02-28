import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/log_meal_screen.dart';
import '../widgets/circular_progress.dart' hide CircularPercent;

void showGoalTrackInfoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // important for dynamic height

    barrierColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SingleChildScrollView( // ✅ makes it wrap content
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ dynamic height
          children: [

            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                margin: EdgeInsets.zero,
               color: Colors.white,
                elevation: 5,
                child: Column(
                  children: [

                    Row(
                      children: [
                        Column(
                          children: [
                            Text("Calories"),
                            Text("1200 kcal"),
                            Text("out of 1800kcal"),
                          ],
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        spacing: 22,
                        children: [
                          CircularPercent(
                            percent: 5,
                            size: 67,
                            stroke: 5,
                            color: Color(0xFF3FAF58),

                            child: SvgPicture.asset("assets/images/icons/ic_trophy.svg", width: 32, height: 32, color: Colors.white,),
                          ),
                          Expanded(
                            child: Column(
                              spacing: 20,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Daily Goal",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                                Text("75% completed",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: -0.40,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close, color: Colors.white,)
                          )

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
