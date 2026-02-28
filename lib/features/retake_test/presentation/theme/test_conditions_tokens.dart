// lib/features/test_conditions/presentation/theme/test_conditions_tokens.dart
import 'package:flutter/material.dart';

sealed class TestConditionsTokens {
  // 🎨 Colors
  static const Color appBarBlue = Color(0xFF1879EE);
  static const Color dark = Color(0xFF252525);
  static const Color white = Colors.white;

  // 🌈 Gradient
  static const List<Color> gradientColors = <Color>[appBarBlue, dark];
  static const List<double> gradientStops = <double>[0.0003, 0.5622];

  // 📐 Header spacing (PX ONLY)
  static const double headerPaddingH = 17;
  static const double headerGap20 = 20;
  static const double headerGap40 = 40;

  // 🔤 Header text
  static const double headerTitleSize = 34;
  static const double headerTitleLetterSpacing = -2.04;

  static const double headerSubtitleSize = 15;
  static const double headerSubtitleLetterSpacing = -0.30;

  // 📦 Sheet padding (PX ONLY)
  static const double sheetPaddingH = 17;
  static const double sheetPaddingV = 35;

  // 📄 Item text
  static const double itemTitleSize = 18;
  static const double itemTitleLetterSpacing = -0.72;

  static const double itemBodySize = 12;
  static const double itemBodyLetterSpacing = -0.24;
  static const double itemBodyHeight = 1.30;

  // 🟦 Sheet
  static const double sheetTopRadius = 15;

  // ⚠️ Keep EXACT as you requested
  static const double sheetWidth = 375;
  static const double sheetHeight = 612;

  // ⬇️ Bottom CTA
  static const double bottomPaddingH = 13;
  static const double bottomPaddingV = 10;

  static const double ctaRadius = 50;
  static const Color ctaBg = dark;

  static const double ctaTextSize = 15;
  static const double ctaTextLetterSpacing = 0.30;
  static const double ctaTextHeight = 1.10;

  // 🌫 Shadow
  static const BoxShadow bottomShadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 6,
    offset: Offset(0, -4),
  );

  // 📏 Layout spacing
  static const double itemsColumnSpacing = 30;
  static const double rowSpacing = 20;
  static const double itemTextSpacing = 10;
}
