import 'package:equatable/equatable.dart';

class MetabolismTargetModel extends Equatable {
  final String mode;
  final int age;
  final String gender;
  final double heightCm;
  final double currentWeight;
  final double correctWeight;
  final double healthyMin;
  final double healthyMax;
  final double totalLossNeeded;
  final int recommendedWeeks;
  final double maxWeeklyLossKg;

  final String acetoneTargetPpm;
  final String ethanolTargetPpm;
  final String h2TargetPpm;

  final Map<String, String> targetScores;

  const MetabolismTargetModel({
    required this.mode,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeight,
    required this.correctWeight,
    required this.healthyMin,
    required this.healthyMax,
    required this.totalLossNeeded,
    required this.recommendedWeeks,
    required this.maxWeeklyLossKg,
    required this.acetoneTargetPpm,
    required this.ethanolTargetPpm,
    required this.h2TargetPpm,
    required this.targetScores,
  });

  factory MetabolismTargetModel.fromJson(Map<String, dynamic> json) {
    return MetabolismTargetModel(
      mode: json['mode'],
      age: json['age'],
      gender: json['gender'],
      heightCm: (json['height_cm'] as num).toDouble(),
      currentWeight: (json['current_weight'] as num).toDouble(),
      correctWeight: (json['correct_weight'] as num).toDouble(),
      healthyMin: (json['healthy_min'] as num).toDouble(),
      healthyMax: (json['healthy_max'] as num).toDouble(),
      totalLossNeeded: (json['total_loss_needed'] as num).toDouble(),
      recommendedWeeks: json['recommended_weeks'],
      maxWeeklyLossKg: (json['max_weekly_loss_kg'] as num).toDouble(),
      acetoneTargetPpm: json['acetone_target_ppm'],
      ethanolTargetPpm: json['ethanol_target_ppm'],
      h2TargetPpm: json['h2_target_ppm'],
      targetScores:
      Map<String, String>.from(json['target_metabolism_scores']),
    );
  }

  @override
  List<Object?> get props => [
    mode,
    age,
    gender,
    heightCm,
    currentWeight,
    correctWeight,
    healthyMin,
    healthyMax,
    totalLossNeeded,
    recommendedWeeks,
    maxWeeklyLossKg,
    acetoneTargetPpm,
    ethanolTargetPpm,
    h2TargetPpm,
    targetScores,
  ];
}
