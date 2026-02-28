import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

Widget targetItem({
  required String targetLabel,
  required String targetIntake,
  required double targetValue,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            targetLabel,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 20),
          // kept toString() to avoid UI change; format if you want later
          Text(
            targetValue ==0 ? "-" : targetValue.toString(),
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.50,
            ),
          ),
          Text(
            "$targetIntake/day",
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
  );
}