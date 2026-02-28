import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle poppinsTextStyle({
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF252525),
}) {
  return GoogleFonts.poppins(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 1.10,
    letterSpacing: -0.24,
  );
}
