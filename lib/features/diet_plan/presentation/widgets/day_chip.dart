import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DayChip extends StatelessWidget {
  final String label;   // "monday".."sunday"
  final DateTime date;  // concrete date in plan range
  final bool selected;
  final VoidCallback onTap;
  const DayChip({
    super.key,
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  String _shortMonth(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(m - 1).clamp(0, 11)];
  }

  String _shortWeek(String lbl) => lbl[0].toUpperCase() + lbl.substring(1, 3); // Mon, Tue

  @override
  Widget build(BuildContext context) {
    // final dateLabel = "${date.day} ${_shortMonth(date.month)}";
    final dateLabel = "${date.day}";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(
          color: selected ? const Color(0xFF308BF9) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateLabel, // Mon
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : const Color(0xFF535359),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.26,
                letterSpacing: -0.30,
              ),
            ),
            Text(
              _shortWeek(label), // 11 Nov
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}