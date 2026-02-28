import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutrientsProgessWidget extends StatelessWidget {
  final String name;
  final String value;
  final String total;
  final Color color;
  final double progress;
  const NutrientsProgessWidget({
    super.key,
    required this.name,
    required this.value,
    required this.total,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              color: const Color(0xFF535359),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Color(0xFFD9D9D9),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.40,
            ),
          ),
          const SizedBox(height: 10),

          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
              children: [
                TextSpan(text: 'out of '),
                TextSpan(
                  text: total,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
