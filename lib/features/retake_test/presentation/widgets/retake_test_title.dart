// lib/features/retake_test/presentation/widgets/retake_test_title.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/retake_test_tokens.dart';

class RetakeTestTitle extends StatelessWidget {
  const RetakeTestTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RetakeTestTokens.titlePadding,
      child: Text(
        "Reason for retaking the test?",
        style: GoogleFonts.poppins(
          color: RetakeTestTokens.titleColor,
          fontSize: RetakeTestTokens.titleFontSize,
          fontWeight: FontWeight.w400,
          letterSpacing: RetakeTestTokens.titleLetterSpacing,
        ),
      ),
    );
  }
}
