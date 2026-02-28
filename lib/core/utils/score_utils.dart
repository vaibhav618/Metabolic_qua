import 'package:flutter/material.dart';

class ScoreInfo {
  final String label;
  final Color color;

  const ScoreInfo({required this.label, required this.color});
}

/// --------------------------------------------------------------
/// STRICT SUBTYPE MATCHING FOR REVERSE SCORING
/// --------------------------------------------------------------
bool isReverseSubtype(String subtype) {
  final cleaned = subtype.toLowerCase().trim();

  return cleaned == "fermentative metabolism score" ||
      cleaned == "glucose metabolism score" ||
      cleaned == "detoxification metabolism score";
}

/// --------------------------------------------------------------
/// GET SCORE LEVEL BASED ON SUBTYPE RULE
/// --------------------------------------------------------------
ScoreInfo getScoreLevel(int score, String subtype) {
  final reverse = isReverseSubtype(subtype);

  if (!reverse) {
    // NORMAL (0–60 Poor, 60–80 Fair, 80–100 Good)
    if (score <= 60) {
      return const ScoreInfo(label: 'Poor', color: Color(0xFFEA5455));
    } else if (score <= 80) {
      return const ScoreInfo(label: 'Fair', color: Color(0xFFFFC412));
    } else {
      return const ScoreInfo(label: 'Good', color: Color(0xFF3EAF58));
    }
  }

  // REVERSE (0–20 Good, 20–60 Fair, 60–100 Poor)
  if (score <= 20) {
    return const ScoreInfo(label: 'Good', color: Color(0xFF3EAF58));
  } else if (score <= 60) {
    return const ScoreInfo(label: 'Fair', color: Color(0xFFFFC412));
  } else {
    return const ScoreInfo(label: 'Poor', color: Color(0xFFEA5455));
  }
}

/// --------------------------------------------------------------
/// COLOR / GRADIENT PICKER
/// --------------------------------------------------------------
class ScoreColorHelper {
  static Color getScoreColor(int score, String subtype) {
    return getScoreLevel(score, subtype).color;
  }

  static List<Color> getLinearScoreColor(int score, String subtype) {
    final label = getScoreLevel(score, subtype).label;

    switch (label) {
      case "Good":
        return [Color(0xFF3FAF58), Color(0xFF009245)];
      case "Fair":
        return [Color(0xFFFFC412), Color(0xFFE3AC06)];
      default: // Poor
        return [Color(0xFFEA5455), Color(0xFFC1272D)];
    }
  }
}
