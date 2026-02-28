import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class LatestTestData extends Equatable {
  final String testId;
  final String dietitianId;
  final String profileId;
  final String dietPlanId;

  final double? absorptiveMetabolismScore;
  final double? fermentativeMetabolismScore;
  final double? fatMetabolismScore;
  final double? glucoseMetabolismScore;
  final double? hepaticStressMetabolismScore;
  final double? detoxificationMetabolismScore;
  final double? fatLossMetabolismScore;

  final double? acetonePpm;
  final double? h2Ppm;
  final double? ethanolPpm;

  final String dateTime;

  final TestJsonData? testJsonData;
  final String rawTestJson;
  final double? minRange;
  final double? maxRange;

  const LatestTestData({
    required this.testId,
    required this.dietitianId,
    required this.profileId,
    required this.dietPlanId,
    required this.absorptiveMetabolismScore,
    required this.fermentativeMetabolismScore,
    required this.fatMetabolismScore,
    required this.glucoseMetabolismScore,
    required this.hepaticStressMetabolismScore,
    required this.detoxificationMetabolismScore,
    required this.fatLossMetabolismScore,
    required this.acetonePpm,
    required this.h2Ppm,
    required this.ethanolPpm,
    required this.dateTime,
    required this.testJsonData,
    required this.rawTestJson,
    required this.minRange,
    required this.maxRange,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  static TestJsonData? _parseRespyrData(dynamic json) {
    final m = _asMap(json);
    if (m == null || m.isEmpty) return null;
    return TestJsonData.fromJson(m);
  }

  static TestJsonData? _parseTestJson(dynamic testJsonRaw) {
    if (testJsonRaw == null) return null;

    // case 1: already map
    final asMap = _asMap(testJsonRaw);
    if (asMap != null && asMap.isNotEmpty) {
      return TestJsonData.fromJson(asMap);
    }

    // case 2: string json
    final s = testJsonRaw.toString().trim();
    if (s.isEmpty) return null;

    try {
      final decoded = jsonDecode(s);
      final map = _asMap(decoded);
      if (map == null || map.isEmpty) return null;
      return TestJsonData.fromJson(map);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("test_json parse failed: $e");
      }
      return null;
    }
  }

  factory LatestTestData.fromJson(Map<String, dynamic> json) {
    // ✅ prefer respyr_response if present
    final respyrResponse = _parseRespyrData(json['respyr_response']);

    // fallback to test_json
    final testJsonData = respyrResponse ?? _parseTestJson(json['test_json']);

    final rawTestJson = (json['test_json'] ?? '').toString().trim();

    return LatestTestData(
      testId: (json['test_id'] ?? '').toString(),
      dietitianId: (json['dietitian_id'] ?? '').toString(),
      profileId: (json['profile_id'] ?? '').toString(),
      dietPlanId: (json['diet_plan_id'] ?? '').toString(),
      absorptiveMetabolismScore: _toDouble(json['absorptive_metabolism_score']),
      fermentativeMetabolismScore: _toDouble(json['fermentative_metabolism_score']),
      fatMetabolismScore: _toDouble(json['fat_metabolism_score']),
      glucoseMetabolismScore: _toDouble(json['glucose_metabolism_score']),
      hepaticStressMetabolismScore: _toDouble(json['hepatic_stress_metabolism_score']),
      detoxificationMetabolismScore: _toDouble(json['detoxification_metabolism_score']),
      fatLossMetabolismScore: _toDouble(json['fat_loss_metabolism_score']),
      acetonePpm: _toDouble(json['acetone_ppm']),
      h2Ppm: _toDouble(json['h2_ppm']),
      ethanolPpm: _toDouble(json['ethanol_ppm']),
      dateTime: (json['date_time'] ?? '').toString(),
      testJsonData: testJsonData,
      rawTestJson: rawTestJson,
      minRange: _toDouble(json['min_range']),
      maxRange: _toDouble(json['max_range']),
    );
  }

  @override
  List<Object?> get props => [
    testId,
    dietitianId,
    profileId,
    dietPlanId,
    absorptiveMetabolismScore,
    fermentativeMetabolismScore,
    fatMetabolismScore,
    glucoseMetabolismScore,
    hepaticStressMetabolismScore,
    detoxificationMetabolismScore,
    fatLossMetabolismScore,
    acetonePpm,
    h2Ppm,
    ethanolPpm,
    dateTime,
    testJsonData,
    rawTestJson,
    minRange,
    maxRange,
  ];
}

class TestJsonData extends Equatable {
  final MetabolismScoreAnalysis? metabolismScoreAnalysis;
  final BreathMarkerAnalysis? breathMarkerAnalysis;
  final FatLossMetabolismScore? fatLossMetabolismScore;

  final String? categoryClusters;
  final String? foodLevelEvaluation;
  final String? mode;
  final String? nonAdherenceWarning;
  final String? overallInterpretation;
  final String? recommendedIntervention;
  final String? systemStrainSummary;
  final String? weeklyFoodPerformance;

  const TestJsonData({
    this.metabolismScoreAnalysis,
    this.breathMarkerAnalysis,
    this.fatLossMetabolismScore,
    this.categoryClusters,
    this.foodLevelEvaluation,
    this.mode,
    this.nonAdherenceWarning,
    this.overallInterpretation,
    this.recommendedIntervention,
    this.systemStrainSummary,
    this.weeklyFoodPerformance,
  });

  static Map<String, dynamic>? _map(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  factory TestJsonData.fromJson(Map<String, dynamic> json) {
    final msa = _map(json['Metabolism_Score_Analysis']);
    final bma = _map(json['breath_marker_analysis']);

    // ✅ Your backend uses Fat_Use_Pattern_trend for fat-loss score
    final fatUse = _map(json['Fat_Use_Pattern_trend']) ?? _map(json['fat_loss_metabolism_score']);

    return TestJsonData(
      metabolismScoreAnalysis: msa != null ? MetabolismScoreAnalysis.fromJson(msa) : null,
      breathMarkerAnalysis: bma != null ? BreathMarkerAnalysis.fromJson(bma) : null,
      fatLossMetabolismScore: fatUse != null ? FatLossMetabolismScore.fromJson(fatUse) : null,
      categoryClusters: json['category_clusters']?.toString(),
      foodLevelEvaluation: json['food_level_evaluation']?.toString(),
      mode: json['mode']?.toString(),
      nonAdherenceWarning: json['non_adherence_warning']?.toString(),
      overallInterpretation: json['overall_interpretation']?.toString(),
      recommendedIntervention: json['recommended_intervention']?.toString(),
      systemStrainSummary: json['system_strain_summary']?.toString(),
      weeklyFoodPerformance: json['weekly_food_performance']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    metabolismScoreAnalysis,
    breathMarkerAnalysis,
    fatLossMetabolismScore,
    categoryClusters,
    foodLevelEvaluation,
    mode,
    nonAdherenceWarning,
    overallInterpretation,
    recommendedIntervention,
    systemStrainSummary,
    weeklyFoodPerformance,
  ];
}

class MetabolismScoreAnalysis extends Equatable {
  final MetabolismScore absorption;
  final MetabolismScore detoxification;
  final MetabolismScore fatMetabolism;
  final MetabolismScore fermentation;
  final MetabolismScore glucoseMetabolism;
  final MetabolismScore hepaticStress;
  final MetabolismScoreSummary? metabolismScoreSummary;

  const MetabolismScoreAnalysis({
    required this.absorption,
    required this.detoxification,
    required this.fatMetabolism,
    required this.fermentation,
    required this.glucoseMetabolism,
    required this.hepaticStress,
    this.metabolismScoreSummary,
  });

  static Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return const <String, dynamic>{};
  }

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    // Old format support (if ever returned)
    final isOld = json['absorption'] != null;

    if (isOld) {
      return MetabolismScoreAnalysis(
        absorption: MetabolismScore.fromJson(_safeMap(json['absorption'])),
        detoxification: MetabolismScore.fromJson(_safeMap(json['detoxification'])),
        fatMetabolism: MetabolismScore.fromJson(_safeMap(json['fat_metabolism'])),
        fermentation: MetabolismScore.fromJson(_safeMap(json['fermentation'])),
        glucoseMetabolism: MetabolismScore.fromJson(_safeMap(json['glucose_metabolism'])),
        hepaticStress: MetabolismScore.fromJson(_safeMap(json['hepatic_stress'])),
        metabolismScoreSummary: json['metabolism_score_summary'] != null
            ? MetabolismScoreSummary.fromJson(_safeMap(json['metabolism_score_summary']))
            : null,
      );
    }

    // ✅ New format mapping (*_Trend keys)
    return MetabolismScoreAnalysis(
      absorption: MetabolismScore.fromJson(_safeMap(json['Nutrient_Utilization_Trend'])),
      fermentation: MetabolismScore.fromJson(_safeMap(json['Digestive_Activity_Trend'])),
      fatMetabolism: MetabolismScore.fromJson(_safeMap(json['Fuel_Utilization_Trend'])),
      glucoseMetabolism: MetabolismScore.fromJson(_safeMap(json['Energy_Source_Trend'])),
      hepaticStress: MetabolismScore.fromJson(_safeMap(json['Metabolic_Load_Trend'])),
      detoxification: MetabolismScore.fromJson(_safeMap(json['Recovery_Activity_Trend'])),
      metabolismScoreSummary: json['metabolism_score_summary'] != null
          ? MetabolismScoreSummary.fromJson(_safeMap(json['metabolism_score_summary']))
          : null,
    );
  }

  @override
  List<Object?> get props => [
    absorption,
    detoxification,
    fatMetabolism,
    fermentation,
    glucoseMetabolism,
    hepaticStress,
    metabolismScoreSummary,
  ];
}

class MetabolismScore extends Equatable {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String ppmNote;
  final double score;
  final String whatIsThisScore;
  final String zone;

  const MetabolismScore({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.whatIsThisScore,
    required this.zone,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    return double.tryParse(s) ?? 0.0;
  }

  factory MetabolismScore.fromJson(Map<String, dynamic> json) {
    return MetabolismScore(
      clientState: (json['client_state'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      ppmNote: (json['ppm_note'] ?? '').toString(),
      score: _toDouble(json['score']),
      whatIsThisScore: (json['what_is_this_score'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    clientState,
    interpretation,
    intervention,
    ppmNote,
    score,
    whatIsThisScore,
    zone,
  ];
}

class MetabolismScoreSummary extends Equatable {
  final String absorptiveScore;
  final String detoxificationScore;
  final String fatMetabolismScore;
  final String fermentativeScore;
  final String glucoseMetabolismScore;
  final String hepaticStressScore;

  const MetabolismScoreSummary({
    required this.absorptiveScore,
    required this.detoxificationScore,
    required this.fatMetabolismScore,
    required this.fermentativeScore,
    required this.glucoseMetabolismScore,
    required this.hepaticStressScore,
  });

  factory MetabolismScoreSummary.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return '';
    }

    return MetabolismScoreSummary(
      absorptiveScore: pick(['Nutrient Utilization Trend', 'Absorptive Score']),
      fermentativeScore: pick(['Digestive Activity Trend', 'Fermentative Score']),
      fatMetabolismScore: pick(['Fuel Utilization Trend', 'Fat Metabolism Score']),
      glucoseMetabolismScore: pick(['Energy Source Trend', 'Glucose Metabolism Score']),
      hepaticStressScore: pick(['Metabolic Load Trend', 'Hepatic Stress Score']),
      detoxificationScore: pick(['Recovery Activity Trend', 'Detoxification Score']),
    );
  }

  @override
  List<Object?> get props => [
    absorptiveScore,
    detoxificationScore,
    fatMetabolismScore,
    fermentativeScore,
    glucoseMetabolismScore,
    hepaticStressScore,
  ];
}

class BreathMarkerAnalysis extends Equatable {
  final BreathMarker acetone;
  final BreathMarker ethanol;
  final BreathMarker hydrogen;

  const BreathMarkerAnalysis({
    required this.acetone,
    required this.ethanol,
    required this.hydrogen,
  });

  static Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return const <String, dynamic>{};
  }

  factory BreathMarkerAnalysis.fromJson(Map<String, dynamic> json) {
    return BreathMarkerAnalysis(
      acetone: BreathMarker.fromJson(_safeMap(json['acetone'])),
      ethanol: BreathMarker.fromJson(_safeMap(json['ethanol'])),
      hydrogen: BreathMarker.fromJson(_safeMap(json['hydrogen'])),
    );
  }

  @override
  List<Object?> get props => [acetone, ethanol, hydrogen];
}

class BreathMarker extends Equatable {
  final MarkerAdvice advice;
  final bool diabetic;
  final String dietitianFocus;
  final String fatLossPossible;
  final String interpretation;
  final String intervention;
  final String marker;
  final double ppm;
  final MarkerRatios ratios;
  final String userGoal;
  final String zone;

  const BreathMarker({
    required this.advice,
    required this.diabetic,
    required this.dietitianFocus,
    required this.fatLossPossible,
    required this.interpretation,
    required this.intervention,
    required this.marker,
    required this.ppm,
    required this.ratios,
    required this.userGoal,
    required this.zone,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return const <String, dynamic>{};
  }

  factory BreathMarker.fromJson(Map<String, dynamic> json) {
    return BreathMarker(
      advice: MarkerAdvice.fromJson(_safeMap(json['advice'])),
      diabetic: (json['diabetic'] ?? false) == true,
      dietitianFocus: (json['dietitian_focus'] ?? '').toString(),
      fatLossPossible: (json['fat_loss_possible'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      marker: (json['marker'] ?? '').toString(),
      ppm: _toDouble(json['ppm']),
      ratios: MarkerRatios.fromJson(_safeMap(json['ratios'])),
      userGoal: (json['user_goal'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    advice,
    diabetic,
    dietitianFocus,
    fatLossPossible,
    interpretation,
    intervention,
    marker,
    ppm,
    ratios,
    userGoal,
    zone,
  ];
}

class MarkerAdvice extends Equatable {
  final String whatLowers;
  final String whatRaises;

  const MarkerAdvice({
    required this.whatLowers,
    required this.whatRaises,
  });

  factory MarkerAdvice.fromJson(Map<String, dynamic> json) {
    return MarkerAdvice(
      whatLowers: (json['what_lowers'] ?? '').toString(),
      whatRaises: (json['what_raises'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [whatLowers, whatRaises];
}

class MarkerRatios extends Equatable {
  final double? fatMetabolismPercent;
  final double? glucoseMetabolismPercent;
  final double? hepaticStrainPercent;
  final double? liverDetoxPercent;
  final double? absorptivePercent;
  final double? fermentationPercent;

  const MarkerRatios({
    this.fatMetabolismPercent,
    this.glucoseMetabolismPercent,
    this.hepaticStrainPercent,
    this.liverDetoxPercent,
    this.absorptivePercent,
    this.fermentationPercent,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  factory MarkerRatios.fromJson(Map<String, dynamic> json) {
    return MarkerRatios(
      fatMetabolismPercent: _toDouble(json['Fat Metabolism %'] ?? json['Fuel Utilization %']),
      glucoseMetabolismPercent: _toDouble(json['Glucose Metabolism %'] ?? json['Energy Source %']),
      hepaticStrainPercent: _toDouble(json['Hepatic Strain %'] ?? json['Metabolic Load %']),
      liverDetoxPercent: _toDouble(json['Liver Detox %'] ?? json['Recovery Activity %']),
      absorptivePercent: _toDouble(json['Absorptive %'] ?? json['Nutrient Utilization %']),
      fermentationPercent: _toDouble(json['Fermentation %'] ?? json['Digestive Activity %']),
    );
  }

  @override
  List<Object?> get props => [
    fatMetabolismPercent,
    glucoseMetabolismPercent,
    hepaticStrainPercent,
    liverDetoxPercent,
    absorptivePercent,
    fermentationPercent,
  ];
}

class FatLossMetabolismScore extends Equatable {
  final String clientInterpretation;
  final String scientificInterpretation;
  final double score;
  final String zone;

  const FatLossMetabolismScore({
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _extract(dynamic v) {
    if (v == null) return '';
    if (v is Map<String, dynamic>) {
      final text = v['text'];
      if (text != null && text.toString().trim().isNotEmpty) return text.toString();
      final title = v['title'];
      if (title != null && title.toString().trim().isNotEmpty) return title.toString();
      return '';
    }
    if (v is Map) {
      final m = v.map((k, val) => MapEntry(k.toString(), val));
      return _extract(m);
    }
    return v.toString();
  }

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    return FatLossMetabolismScore(
      clientInterpretation: _extract(json['client_interpretation']),
      scientificInterpretation: _extract(json['scientific_interpretation']),
      score: _toDouble(json['score']),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
    clientInterpretation,
    scientificInterpretation,
    score,
    zone,
  ];
}
