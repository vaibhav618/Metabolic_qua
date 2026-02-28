// lib/features/retake_test/presentation/theme/retake_test_tokens.dart
import 'package:flutter/material.dart';

sealed class RetakeTestTokens {
  static const Color pageBg = Colors.white;
  static const Color titleColor = Color(0xFF252525);

  static const Color ctaEnabled = Color(0xFF308BF9);
  static const Color ctaDisabled = Color(0xFFCAE1FF);

  static const double titleFontSize = 34;
  static const double titleLetterSpacing = -2.04;

  static const double bottomRadius = 25;
  static const EdgeInsets titlePadding = EdgeInsets.symmetric(horizontal: 20);

  static const SizedBox gapTop = SizedBox(height: 8);
  static const SizedBox gapAfterTitle = SizedBox(height: 24);

  static const EdgeInsets ctaPadding =
  EdgeInsets.symmetric(horizontal: 10, vertical: 10);
  static const EdgeInsets ctaInnerPadding =
  EdgeInsets.symmetric(vertical: 14);
}
