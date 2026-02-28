import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart';

class TestFailedSuggestionItem extends StatelessWidget {
  final String step;
  final String text;

  const TestFailedSuggestionItem({super.key,required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: rh(context: context, px: 25),
          height: rh(context: context, px: 25),
          decoration: const ShapeDecoration(
            color: Color(0xFF0F5AB5),
            shape: OvalBorder(),
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: rh(context: context, px: 15),
                fontWeight: FontWeight.w600,
                height: rh(context: context, px: 1.29),
                letterSpacing: rh(context: context, px: -0.60),
              ),
            ),
          ),
        ),
        SizedBox(width: rh(context: context, px: 10)),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: rh(context: context, px: 15),
              fontWeight: FontWeight.w400,
              height: rh(context: context, px: 1.45),
              letterSpacing: rh(context: context, px: -0.30),
            ),
          ),
        ),
      ],
    );
  }
}