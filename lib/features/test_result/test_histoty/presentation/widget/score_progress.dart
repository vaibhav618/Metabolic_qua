import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/score_manager/score_color.dart';
import '../../../../../core/score_manager/score_difference.dart';

Widget scoreDifference({
  required double scoreCurrent,
  required double scorePrevious,
}){


  final result = getScoreDifference(current: scoreCurrent, previous: scorePrevious);

  Icon getScoreArrow(){
    if(result["status"]=="increase"){
      return Icon(Icons.arrow_upward_outlined, size: 16, color: ScoreColors.colorGood,);
    }else if(result["status"]=="decrease"){
      return Icon(Icons.arrow_downward_outlined, size: 16, color:ScoreColors.colorPoor,);
    }
    return Icon(CupertinoIcons.equal, size: 16, color: Colors.grey,);
  }

  
  double diff = result["percentage"];

  return   Visibility(
    visible: diff!=0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [

        Row(
          spacing: 6,
          children: [
            Text("${diff.toStringAsFixed(0)}%",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.36,
              ),
            ),
            getScoreArrow()
          ],
        ),

        Text("than last yesterday",
          style: GoogleFonts.poppins(
            color: const Color(0xFFA1A1A1),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        )
      ],
    ),
  );
}