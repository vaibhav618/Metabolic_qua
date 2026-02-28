import 'dart:ui';

class ScoreColors {
  static Color colorPoor = const Color(0xFFDA5747);
  static Color colorFair = const Color(0xFFF8B10F);
  static Color colorGood = const Color(0xFF3EAF58);

  Color getScoreColor({required double score}) {
    if (score < 60) {
      return ScoreColors.colorPoor;
    } else if (score < 80) {
      return ScoreColors.colorFair;
    } else {
      return ScoreColors.colorGood;
    }
  }
}
