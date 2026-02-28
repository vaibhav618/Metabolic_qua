// lib/features/test_conditions/presentation/widgets/test_conditions_bottom_cta.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/size/get_height.dart' show rh;
import '../theme/test_conditions_tokens.dart';

class TestConditionsBottomCta extends StatelessWidget {
  final VoidCallback confirmedToNavigate;

  const TestConditionsBottomCta({
    super.key,
    required this.confirmedToNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: TestConditionsTokens.white,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: TestConditionsTokens.white,
          boxShadow: [TestConditionsTokens.bottomShadow],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: rh(context: context, px: TestConditionsTokens.bottomPaddingH),
          vertical: rh(context: context, px: TestConditionsTokens.bottomPaddingV),
        ),
        child: Semantics(
          button: true,
          label: 'I remember',
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: confirmedToNavigate,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: TestConditionsTokens.ctaBg,
                padding: EdgeInsets.symmetric(
                  vertical: rh(context: context, px: 16), // keep if you like
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    rh(context: context, px: TestConditionsTokens.ctaRadius),
                  ),
                ),
              ),
              child: Text(
                "I remember",
                style: GoogleFonts.poppins(
                  color: TestConditionsTokens.white,
                  fontSize: rh(context: context, px: TestConditionsTokens.ctaTextSize),
                  fontWeight: FontWeight.w700,
                  height: TestConditionsTokens.ctaTextHeight, // keep height as-is
                  letterSpacing: rh(
                    context: context,
                    px: TestConditionsTokens.ctaTextLetterSpacing,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
