import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget notificationItem(
{
  required String notificationTitle,
  required String notificationMessage,
  required String timeAgo,
  required bool isSeen,
}
    ){
  return Container(
    decoration: ShapeDecoration(
      color: !isSeen ?  Color(0xFFEAF3FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    padding: EdgeInsets.only(left: 5, right: 20, top: 16, bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 6,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: ShapeDecoration(
            color: !isSeen ?  Color(0xFF308BF9) : Colors.transparent,
            shape: OvalBorder(),
          ),
        ),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(notificationTitle,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.26,
                letterSpacing: -0.24,
              ),
            ),
            Text(notificationMessage,
              style: GoogleFonts.poppins(
                color: const Color(0xFF535359),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
            )
          ],
        )),
        SizedBox(width: 20,),
        Text(timeAgo,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.20,
          ),
        )
      ],
    ),
  );
}