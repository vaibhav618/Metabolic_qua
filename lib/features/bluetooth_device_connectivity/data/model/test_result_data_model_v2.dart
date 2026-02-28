class TestResultResponse {
  final bool success;
  final String message;
  final int testId;
  final String dateTime;
  final double fatLossMetabolismScore;
  final double minRange;
  final double maxRange;
  final String urlCalled;
  final TestLog testLog;
  final RespyrResponse respyrResponse;

  TestResultResponse({
    required this.success,
    required this.message,
    required this.testId,
    required this.dateTime,
    required this.fatLossMetabolismScore,
    required this.minRange,
    required this.maxRange,
    required this.urlCalled,
    required this.testLog,
    required this.respyrResponse,
  });

  factory TestResultResponse.fromJson(Map<String, dynamic> json) {
    return TestResultResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      testId: _asInt(json['test_id']),
      dateTime: (json['date_time'] ?? '').toString(),
      fatLossMetabolismScore: _asDouble(json['fat_loss_metabolism_score']),
      minRange: _asDouble(json['min_range']),
      maxRange: _asDouble(json['max_range']),
      urlCalled: (json['url_called'] ?? '').toString(),
      testLog: TestLog.fromJson((json['test_log'] ?? {}) as Map<String, dynamic>),
      respyrResponse: RespyrResponse.fromJson(
        (json['respyr_response'] ?? {}) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'test_id': testId,
    'date_time': dateTime,
    'fat_loss_metabolism_score': fatLossMetabolismScore,
    'min_range': minRange,
    'max_range': maxRange,
    'url_called': urlCalled,
    'test_log': testLog.toJson(),
    'respyr_response': respyrResponse.toJson(),
  };
}

class TestLog {
  final String mode;
  final int rowId;
  final int previousTestTaken;
  final int testTaken;

  TestLog({
    required this.mode,
    required this.rowId,
    required this.previousTestTaken,
    required this.testTaken,
  });

  factory TestLog.fromJson(Map<String, dynamic> json) {
    return TestLog(
      mode: (json['mode'] ?? '').toString(),
      rowId: _asInt(json['row_id']),
      previousTestTaken: _asInt(json['previous_test_taken']),
      testTaken: _asInt(json['test_taken']),
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'row_id': rowId,
    'previous_test_taken': previousTestTaken,
    'test_taken': testTaken,
  };
}

class RespyrResponse {
  final FatUsePatternTrend fatUsePatternTrend;
  final MetabolismScoreAnalysis metabolismScoreAnalysis;
  final BreathMarkerAnalysis breathMarkerAnalysis;

  final String categoryClusters;
  final DayFocus dayFocus;

  final String foodLevelEvaluation;
  final String mode;

  final String nonAdherenceWarning;
  final String overallInterpretation;
  final String recommendedIntervention;
  final String systemStrainSummary;
  final String weeklyFoodPerformance;

  RespyrResponse({
    required this.fatUsePatternTrend,
    required this.metabolismScoreAnalysis,
    required this.breathMarkerAnalysis,
    required this.categoryClusters,
    required this.dayFocus,
    required this.foodLevelEvaluation,
    required this.mode,
    required this.nonAdherenceWarning,
    required this.overallInterpretation,
    required this.recommendedIntervention,
    required this.systemStrainSummary,
    required this.weeklyFoodPerformance,
  });

  factory RespyrResponse.fromJson(Map<String, dynamic> json) {
    return RespyrResponse(
      fatUsePatternTrend: FatUsePatternTrend.fromJson(
        (json['Fat_Use_Pattern_trend'] ?? {}) as Map<String, dynamic>,
      ),
      metabolismScoreAnalysis: MetabolismScoreAnalysis.fromJson(
        (json['Metabolism_Score_Analysis'] ?? {}) as Map<String, dynamic>,
      ),
      breathMarkerAnalysis: BreathMarkerAnalysis.fromJson(
        (json['breath_marker_analysis'] ?? {}) as Map<String, dynamic>,
      ),
      categoryClusters: (json['category_clusters'] ?? 'NA').toString(),
      dayFocus: DayFocus.fromJson((json['day_focus'] ?? {}) as Map<String, dynamic>),
      foodLevelEvaluation: (json['food_level_evaluation'] ?? 'NA').toString(),
      mode: (json['mode'] ?? '').toString(),
      nonAdherenceWarning: (json['non_adherence_warning'] ?? 'NA').toString(),
      overallInterpretation: (json['overall_interpretation'] ?? 'NA').toString(),
      recommendedIntervention: (json['recommended_intervention'] ?? 'NA').toString(),
      systemStrainSummary: (json['system_strain_summary'] ?? 'NA').toString(),
      weeklyFoodPerformance: (json['weekly_food_performance'] ?? 'NA').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Fat_Use_Pattern_trend': fatUsePatternTrend.toJson(),
    'Metabolism_Score_Analysis': metabolismScoreAnalysis.toJson(),
    'breath_marker_analysis': breathMarkerAnalysis.toJson(),
    'category_clusters': categoryClusters,
    'day_focus': dayFocus.toJson(),
    'food_level_evaluation': foodLevelEvaluation,
    'mode': mode,
    'non_adherence_warning': nonAdherenceWarning,
    'overall_interpretation': overallInterpretation,
    'recommended_intervention': recommendedIntervention,
    'system_strain_summary': systemStrainSummary,
    'weekly_food_performance': weeklyFoodPerformance,
  };
}

class FatUsePatternTrend {
  final InterpretationBlock clientInterpretation;
  final bool diabeticAdjustmentApplied;
  final InterpretationBlock scientificInterpretation;
  final double score;
  final String zone;

  FatUsePatternTrend({
    required this.clientInterpretation,
    required this.diabeticAdjustmentApplied,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
  });

  factory FatUsePatternTrend.fromJson(Map<String, dynamic> json) {
    return FatUsePatternTrend(
      clientInterpretation: InterpretationBlock.fromJson(
        (json['client_interpretation'] ?? {}) as Map<String, dynamic>,
      ),
      diabeticAdjustmentApplied: json['diabetic_adjustment_applied'] == true,
      scientificInterpretation: InterpretationBlock.fromJson(
        (json['scientific_interpretation'] ?? {}) as Map<String, dynamic>,
      ),
      score: _asDouble(json['score']),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'client_interpretation': clientInterpretation.toJson(),
    'diabetic_adjustment_applied': diabeticAdjustmentApplied,
    'scientific_interpretation': scientificInterpretation.toJson(),
    'score': score,
    'zone': zone,
  };
}

class InterpretationBlock {
  final String text;
  final String title;

  InterpretationBlock({required this.text, required this.title});

  factory InterpretationBlock.fromJson(Map<String, dynamic> json) {
    return InterpretationBlock(
      text: (json['text'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'title': title};
}

class MetabolismScoreAnalysis {
  final TrendDetail digestiveActivityTrend;
  final TrendDetail energySourceTrend;
  final TrendDetail fuelUtilizationTrend;
  final TrendDetail metabolicLoadTrend;
  final TrendDetail nutrientUtilizationTrend;
  final TrendDetail recoveryActivityTrend;

  final Map<String, String> metabolismScoreSummary;

  MetabolismScoreAnalysis({
    required this.digestiveActivityTrend,
    required this.energySourceTrend,
    required this.fuelUtilizationTrend,
    required this.metabolicLoadTrend,
    required this.nutrientUtilizationTrend,
    required this.recoveryActivityTrend,
    required this.metabolismScoreSummary,
  });

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreAnalysis(
      digestiveActivityTrend: TrendDetail.fromJson(
        (json['Digestive_Activity_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      energySourceTrend: TrendDetail.fromJson(
        (json['Energy_Source_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      fuelUtilizationTrend: TrendDetail.fromJson(
        (json['Fuel_Utilization_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      metabolicLoadTrend: TrendDetail.fromJson(
        (json['Metabolic_Load_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      nutrientUtilizationTrend: TrendDetail.fromJson(
        (json['Nutrient_Utilization_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      recoveryActivityTrend: TrendDetail.fromJson(
        (json['Recovery_Activity_Trend'] ?? {}) as Map<String, dynamic>,
      ),
      metabolismScoreSummary: _asStringMap(json['metabolism_score_summary']),
    );
  }

  Map<String, dynamic> toJson() => {
    'Digestive_Activity_Trend': digestiveActivityTrend.toJson(),
    'Energy_Source_Trend': energySourceTrend.toJson(),
    'Fuel_Utilization_Trend': fuelUtilizationTrend.toJson(),
    'Metabolic_Load_Trend': metabolicLoadTrend.toJson(),
    'Nutrient_Utilization_Trend': nutrientUtilizationTrend.toJson(),
    'Recovery_Activity_Trend': recoveryActivityTrend.toJson(),
    'metabolism_score_summary': metabolismScoreSummary,
  };
}

class TrendDetail {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String ppmNote;
  final double score;
  final String scoreMath;
  final String whatIsThisScore;
  final String zone;

  TrendDetail({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.scoreMath,
    required this.whatIsThisScore,
    required this.zone,
  });

  factory TrendDetail.fromJson(Map<String, dynamic> json) {
    return TrendDetail(
      clientState: (json['client_state'] ?? '').toString(),
      interpretation: (json['interpretation'] ?? '').toString(),
      intervention: (json['intervention'] ?? '').toString(),
      ppmNote: (json['ppm_note'] ?? '').toString(),
      score: _asDouble(json['score']),
      scoreMath: (json['score_math'] ?? '').toString(),
      whatIsThisScore: (json['what_is_this_score'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'client_state': clientState,
    'interpretation': interpretation,
    'intervention': intervention,
    'ppm_note': ppmNote,
    'score': score,
    'score_math': scoreMath,
    'what_is_this_score': whatIsThisScore,
    'zone': zone,
  };
}

class BreathMarkerAnalysis {
  final Marker acetone;
  final MarkerEthanol ethanol;
  final MarkerHydrogen hydrogen;

  BreathMarkerAnalysis({
    required this.acetone,
    required this.ethanol,
    required this.hydrogen,
  });

  factory BreathMarkerAnalysis.fromJson(Map<String, dynamic> json) {
    return BreathMarkerAnalysis(
      acetone: Marker.fromJson((json['acetone'] ?? {}) as Map<String, dynamic>),
      ethanol: MarkerEthanol.fromJson((json['ethanol'] ?? {}) as Map<String, dynamic>),
      hydrogen: MarkerHydrogen.fromJson((json['hydrogen'] ?? {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'acetone': acetone.toJson(),
    'ethanol': ethanol.toJson(),
    'hydrogen': hydrogen.toJson(),
  };
}

class Marker {
  final MarkerAdvice advice;
  final bool diabetic;
  final String marker;
  final int ppm;
  final Map<String, double> ratios;
  final String userGoal;

  Marker({
    required this.advice,
    required this.diabetic,
    required this.marker,
    required this.ppm,
    required this.ratios,
    required this.userGoal,
  });

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      advice: MarkerAdvice.fromJson((json['advice'] ?? {}) as Map<String, dynamic>),
      diabetic: json['diabetic'] == true,
      marker: (json['marker'] ?? '').toString(),
      ppm: _asInt(json['ppm']),
      ratios: _asDoubleMap(json['ratios']),
      userGoal: (json['user_goal'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'advice': advice.toJson(),
    'diabetic': diabetic,
    'marker': marker,
    'ppm': ppm,
    'ratios': ratios,
    'user_goal': userGoal,
  };
}

class MarkerEthanol extends Marker {
  final String dietitianFocus;
  final String fatLossPossible;
  final String interpretationText;
  final String interventionText;
  final String zone;

  MarkerEthanol({
    required super.advice,
    required super.diabetic,
    required super.marker,
    required super.ppm,
    required super.ratios,
    required super.userGoal,
    required this.dietitianFocus,
    required this.fatLossPossible,
    required this.interpretationText,
    required this.interventionText,
    required this.zone,
  });

  factory MarkerEthanol.fromJson(Map<String, dynamic> json) {
    return MarkerEthanol(
      advice: MarkerAdvice.fromJson((json['advice'] ?? {}) as Map<String, dynamic>),
      diabetic: json['diabetic'] == true,
      marker: (json['marker'] ?? '').toString(),
      ppm: _asInt(json['ppm']),
      ratios: _asDoubleMap(json['ratios']),
      userGoal: (json['user_goal'] ?? '').toString(),
      dietitianFocus: (json['dietitian_focus'] ?? '').toString(),
      fatLossPossible: (json['fat_loss_possible'] ?? '').toString(),
      interpretationText: (json['interpretation'] ?? '').toString(),
      interventionText: (json['intervention'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'dietitian_focus': dietitianFocus,
    'fat_loss_possible': fatLossPossible,
    'interpretation': interpretationText,
    'intervention': interventionText,
    'zone': zone,
  };
}

class MarkerHydrogen extends Marker {
  final String dietitianFocus;
  final String fatLossPossible;
  final String interpretationText;
  final String interventionText;
  final String zone;

  MarkerHydrogen({
    required super.advice,
    required super.diabetic,
    required super.marker,
    required super.ppm,
    required super.ratios,
    required super.userGoal,
    required this.dietitianFocus,
    required this.fatLossPossible,
    required this.interpretationText,
    required this.interventionText,
    required this.zone,
  });

  factory MarkerHydrogen.fromJson(Map<String, dynamic> json) {
    return MarkerHydrogen(
      advice: MarkerAdvice.fromJson((json['advice'] ?? {}) as Map<String, dynamic>),
      diabetic: json['diabetic'] == true,
      marker: (json['marker'] ?? '').toString(),
      ppm: _asInt(json['ppm']),
      ratios: _asDoubleMap(json['ratios']),
      userGoal: (json['user_goal'] ?? '').toString(),
      dietitianFocus: (json['dietitian_focus'] ?? '').toString(),
      fatLossPossible: (json['fat_loss_possible'] ?? '').toString(),
      interpretationText: (json['interpretation'] ?? '').toString(),
      interventionText: (json['intervention'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'dietitian_focus': dietitianFocus,
    'fat_loss_possible': fatLossPossible,
    'interpretation': interpretationText,
    'intervention': interventionText,
    'zone': zone,
  };
}

class MarkerAdvice {
  final String whatLowers;
  final String whatRaises;

  MarkerAdvice({
    required this.whatLowers,
    required this.whatRaises,
  });

  factory MarkerAdvice.fromJson(Map<String, dynamic> json) {
    return MarkerAdvice(
      whatLowers: (json['what_lowers'] ?? '').toString(),
      whatRaises: (json['what_raises'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'what_lowers': whatLowers,
    'what_raises': whatRaises,
  };
}

class DayFocus {
  final String note;
  final Map<String, double> signals;
  final String title;

  DayFocus({
    required this.note,
    required this.signals,
    required this.title,
  });

  factory DayFocus.fromJson(Map<String, dynamic> json) {
    return DayFocus(
      note: (json['note'] ?? '').toString(),
      signals: _asDoubleMap(json['signals']),
      title: (json['title'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'note': note,
    'signals': signals,
    'title': title,
  };
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

Map<String, String> _asStringMap(dynamic v) {
  if (v is Map) {
    return v.map((key, value) => MapEntry(key.toString(), (value ?? '').toString()));
  }
  return <String, String>{};
}

Map<String, double> _asDoubleMap(dynamic v) {
  if (v is Map) {
    return v.map((key, value) => MapEntry(key.toString(), _asDouble(value)));
  }
  return <String, double>{};
}
