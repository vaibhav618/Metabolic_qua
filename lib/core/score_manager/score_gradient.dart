import 'package:flutter/material.dart';
import 'package:respyr_dietitian/core/score_manager/score_color.dart';

List<Color> scoreGradient(double score){
  return [
    ScoreColors().getScoreColor(score: score).withOpacity(0.4),
    Colors.white
  ];
}