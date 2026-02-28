import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget notificationTypeChip({
  required String notificationType,
  required bool isActive,
  required VoidCallback onClick,
  int unseenCount = 0, // 👈 per-type unseen count
}) {
  return GestureDetector(
    onTap: onClick, // <-- FIXED
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD9EAFF) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 5,
        children: [
          Text(
            notificationType,
            style: GoogleFonts.poppins(
              color: isActive ? Color(0xFF308BF9): Color(0xFFA1A1A1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: -0.24,
            ),
          ),
          if(unseenCount>0)...[
            Container(
              width: 4,
              height: 4,
              decoration: ShapeDecoration(
                color: const Color(0xFF308BF9),
                shape: OvalBorder(),
              ),
            )
          ]

        ],
      ),
    ),
  );
}
