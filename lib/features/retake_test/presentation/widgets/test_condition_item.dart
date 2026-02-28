// lib/features/test_conditions/presentation/widgets/test_condition_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/test_conditions_tokens.dart';

class TestConditionItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String body;

  const TestConditionItem({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: Row(
        spacing: TestConditionsTokens.rowSpacing,
        children: [
          SvgPicture.asset(iconAsset),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: TestConditionsTokens.itemTextSpacing,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: TestConditionsTokens.dark,
                    fontSize: TestConditionsTokens.itemTitleSize,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: TestConditionsTokens.itemTitleLetterSpacing,
                  ),
                ),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    color: TestConditionsTokens.dark,
                    fontSize: TestConditionsTokens.itemBodySize,
                    fontWeight: FontWeight.w400,
                    height: TestConditionsTokens.itemBodyHeight,
                    letterSpacing: TestConditionsTokens.itemBodyLetterSpacing,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
