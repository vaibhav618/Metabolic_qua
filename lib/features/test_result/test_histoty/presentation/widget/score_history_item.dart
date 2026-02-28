import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/score_manager/score_color.dart';
import '../../../../../core/score_manager/score_status.dart';

Widget scoreHistoryItemWidget(
    { required DateTime dateTime,
      required int score
    }
    ){

  String day =  DateFormat("d").format(dateTime);
  String dayName =  DateFormat("EEE").format(dateTime);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: ShapeDecoration(
          color: const Color(0xFFE1E6ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          spacing: 4,
          children: [
            Text(
              day,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.26,
                letterSpacing: -0.30,
              ),
            ),
            Text(
              dayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.20,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            spacing: 50,
            children: [
              Expanded(
                  child: Row(
                    spacing: 10,
                    children: [
                      Text("$score%",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF252525),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.36,
                        ),
                      ),
                      Container(
                        height: 18 ,
                        width: 1,
                        color: const Color(0xFF535359),
                      ),
                      Text(ScoreStatus().getScoreStatus(score: score.toDouble()),
                        style: GoogleFonts.poppins(
                          color: ScoreColors().getScoreColor(score:  score.toDouble()),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.36,
                        ),
                      )
                    ],
                  )
              ),


            ],
          ),
        ),

      )
    ],

  );
}