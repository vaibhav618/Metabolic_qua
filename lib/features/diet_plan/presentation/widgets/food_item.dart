import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

Widget dietPlanFoodItem({required int index,required String foodName,required String foodType, required String foodScale, required String foodCalories}){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Row(
          children: [

            SizedBox(width: 9,),
            Text(index.toString(),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.26,
                letterSpacing: -0.30,
              ),
            ),
            SizedBox(width: 22,),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(foodName,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.26,
                      letterSpacing: -0.24,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(foodScale,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.20,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 22,),
            Expanded(
              flex: 1,
              child: Text("$foodCalories kcal",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              ),
            )

          ],
        ),
        SizedBox(height: 30,)
      ],
    ),
  );
}