// lib/features/test_conditions/presentation/widgets/test_conditions_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart' show rh;
import '../theme/test_conditions_tokens.dart';

class TestConditionsHeader extends StatelessWidget {
  const TestConditionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        rh(
          context: context,
          px: TestConditionsTokens.headerPaddingH,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Remember",
            style: GoogleFonts.poppins(
              color: TestConditionsTokens.white,
              fontSize: rh(
                context: context,
                px: TestConditionsTokens.headerTitleSize,
              ),
              fontWeight: FontWeight.w400,
              letterSpacing: rh(
                context: context,
                px: TestConditionsTokens.headerTitleLetterSpacing,
              ),
              height: 1.0,
            ),
          ),

          SizedBox(
            height: rh(
              context: context,
              px: TestConditionsTokens.headerGap20,
            ),
          ),

          Text(
            "Best conditions to take the test",
            style: GoogleFonts.poppins(
              color: TestConditionsTokens.white,
              fontSize: rh(
                context: context,
                px: TestConditionsTokens.headerSubtitleSize,
              ),
              fontWeight: FontWeight.w400,
              height: 1.0,
              letterSpacing: rh(
                context: context,
                px: TestConditionsTokens.headerSubtitleLetterSpacing,
              ),
            ),
          ),

          SizedBox(
            height: rh(
              context: context,
              px: TestConditionsTokens.headerGap40,
            ),
          ),
        ],
      ),
    );
  }
}
