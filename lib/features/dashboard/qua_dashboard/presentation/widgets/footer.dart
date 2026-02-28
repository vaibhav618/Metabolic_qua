import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 150),
      child: Column(
        children: [
          Text("Made In India",
            style: GoogleFonts.poppins(
              color: const Color(0xFFA1A1A1),
              fontSize: 34,
              fontWeight: FontWeight.w400,
              letterSpacing: -2.04,
              height: 1.0
            ),
          ),
          Text("All rights reserved Respyr",
            style: GoogleFonts.poppins(
              color: const Color(0xFFA1A1A1),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20,
            ),
          )
        ],
      ),
    );
  }
}
