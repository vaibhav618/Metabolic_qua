import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabWidget extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const TabWidget({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,

          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF308BF9) : Colors.grey.shade300,
              width: 2.5,
            ),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
        ),
      ),
    );
  }
}
