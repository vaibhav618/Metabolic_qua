// ✅ COMPLETE UPDATED MODEL (includes scientific_interpretation as {title,text})

class GeneratingResultModel {
  final bool success;
  final String message;
  final int testId;
  final String urlCalled;
  final RespyrResponse respyrResponse;
  final DateTime dateTime;

  GeneratingResultModel({
    required this.success,
    required this.message,
    required this.testId,
    required this.urlCalled,
    required this.respyrResponse,
    required this.dateTime,
  });

  factory GeneratingResultModel.fromJson(Map<String, dynamic> json) {
    final String? dtStr = json['date_time'];
    DateTime parsedDateTime;

    print(dtStr);
    print(json);

    if (dtStr != null && dtStr.isNotEmpty) {
      parsedDateTime = DateTime.parse(dtStr.replaceFirst(' ', 'T'));
    } else {
      parsedDateTime = DateTime.now();
    }

    return GeneratingResultModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      testId: (json['test_id'] ?? 0).toInt(),
      urlCalled: json['url_called'] ?? '',
      dateTime: parsedDateTime,
      respyrResponse: RespyrResponse.fromJson(json['respyr_response'] ?? {}),
    );
  }
}

class RespyrResponse {
  final MetabolismScoreAnalysis metabolismScoreAnalysis;
  final BreathMarkerAnalysis breathMarkerAnalysis;
  final FatLossMetabolismScore fatLossMetabolismScore;

  // ✅ optional
  final DayFocus? dayFocus;

  RespyrResponse({
    required this.metabolismScoreAnalysis,
    required this.breathMarkerAnalysis,
    required this.fatLossMetabolismScore,
    this.dayFocus,
  });

  factory RespyrResponse.fromJson(Map<String, dynamic> json) {
    return RespyrResponse(
      metabolismScoreAnalysis: MetabolismScoreAnalysis.fromJson(
        json['Metabolism_Score_Analysis'] ?? {},
      ),
      breathMarkerAnalysis: BreathMarkerAnalysis.fromJson(
        json['breath_marker_analysis'] ?? {},
      ),
      fatLossMetabolismScore: FatLossMetabolismScore.fromJson(
        json['fat_loss_metabolism_score'] ?? {},
      ),
      dayFocus:
      json['day_focus'] != null ? DayFocus.fromJson(json['day_focus']) : null,
    );
  }
}

class MetabolismScoreAnalysis {
  final ScoreItem absorption;
  final ScoreItem detoxification;
  final ScoreItem fatMetabolism;
  final ScoreItem fermentation;
  final ScoreItem glucoseMetabolism;
  final ScoreItem hepaticStress;

  MetabolismScoreAnalysis({
    required this.absorption,
    required this.detoxification,
    required this.fatMetabolism,
    required this.fermentation,
    required this.glucoseMetabolism,
    required this.hepaticStress,
  });

  factory MetabolismScoreAnalysis.fromJson(Map<String, dynamic> json) {
    return MetabolismScoreAnalysis(
      absorption: ScoreItem.fromJson(json['absorption'] ?? {}),
      detoxification: ScoreItem.fromJson(json['detoxification'] ?? {}),
      fatMetabolism: ScoreItem.fromJson(json['fat_metabolism'] ?? {}),
      fermentation: ScoreItem.fromJson(json['fermentation'] ?? {}),
      glucoseMetabolism: ScoreItem.fromJson(json['glucose_metabolism'] ?? {}),
      hepaticStress: ScoreItem.fromJson(json['hepatic_stress'] ?? {}),
    );
  }
}

class ScoreItem {
  final String clientState;
  final String interpretation;
  final String intervention;
  final String ppmNote;

  // ✅ API returns decimals (53.33 etc)
  final double score;

  final String whatIsThisScore;
  final String zone;

  // optional
  final String? scoreMath;

  ScoreItem({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.whatIsThisScore,
    required this.zone,
    this.scoreMath,
  });

  factory ScoreItem.fromJson(Map<String, dynamic> json) {
    return ScoreItem(
      clientState: json['client_state'] ?? '',
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      ppmNote: json['ppm_note'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      whatIsThisScore: json['what_is_this_score'] ?? '',
      zone: json['zone'] ?? '',
      scoreMath: json['score_math'],
    );
  }
}

class BreathMarkerAnalysis {
  final MarkerItem acetone;
  final MarkerItem ethanol;
  final MarkerItem hydrogen;

  BreathMarkerAnalysis({
    required this.acetone,
    required this.ethanol,
    required this.hydrogen,
  });

  factory BreathMarkerAnalysis.fromJson(Map<String, dynamic> json) {
    return BreathMarkerAnalysis(
      acetone: MarkerItem.fromJson(json['acetone'] ?? {}),
      ethanol: MarkerItem.fromJson(json['ethanol'] ?? {}),
      hydrogen: MarkerItem.fromJson(json['hydrogen'] ?? {}),
    );
  }
}

class MarkerItem {
  final String marker;
  final double ppm;
  final String interpretation;
  final String intervention;
  final String zone;
  final bool diabetic;
  final String userGoal;
  final Map<String, dynamic>? ratios;
  final MarkerAdvice? advice;

  MarkerItem({
    required this.marker,
    required this.ppm,
    required this.interpretation,
    required this.intervention,
    required this.zone,
    required this.diabetic,
    required this.userGoal,
    required this.ratios,
    required this.advice,
  });

  factory MarkerItem.fromJson(Map<String, dynamic> json) {
    return MarkerItem(
      marker: json['marker'] ?? '',
      ppm: (json['ppm'] ?? 0).toDouble(),
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      zone: json['zone'] ?? '',
      diabetic: json['diabetic'] ?? false,
      userGoal: json['user_goal'] ?? '',
      ratios: json['ratios'] != null ? Map<String, dynamic>.from(json['ratios']) : null,
      advice: json['advice'] != null ? MarkerAdvice.fromJson(json['advice']) : null,
    );
  }
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
      whatLowers: json['what_lowers'] ?? '',
      whatRaises: json['what_raises'] ?? '',
    );
  }
}

/// ✅ NEW: for scientific_interpretation {title, text}
class InterpretationBlock {
  final String title;
  final String text;

  InterpretationBlock({
    required this.title,
    required this.text,
  });

  factory InterpretationBlock.fromJson(Map<String, dynamic> json) {
    return InterpretationBlock(
      title: json['title'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class FatLossMetabolismScore {
  // ✅ Keep client interpretation as String (your current API shows {title,text} too sometimes,
  // but you asked only for scientific_interpretation update)
  final dynamic clientInterpretation;

  // ✅ UPDATED: now object {title,text}
  final InterpretationBlock scientificInterpretation;

  final double score;
  final String zone;

  // optional
  final bool? diabeticAdjustmentApplied;

  FatLossMetabolismScore({
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
    this.diabeticAdjustmentApplied,
  });

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    return FatLossMetabolismScore(
      // keeping dynamic because sometimes API gives object, sometimes string in your old model
      clientInterpretation: json['client_interpretation'],
      scientificInterpretation: InterpretationBlock.fromJson(
        json['scientific_interpretation'] ?? {},
      ),
      score: (json['score'] ?? 0).toDouble(),
      zone: json['zone'] ?? '',
      diabeticAdjustmentApplied: json['diabetic_adjustment_applied'],
    );
  }
}

/// ✅ OPTIONAL MODELS (you already added)
class DayFocus {
  final String title;
  final String note;
  final DayFocusSignals signals;

  DayFocus({
    required this.title,
    required this.note,
    required this.signals,
  });

  factory DayFocus.fromJson(Map<String, dynamic> json) {
    return DayFocus(
      title: json['title'] ?? '',
      note: json['note'] ?? '',
      signals: DayFocusSignals.fromJson(json['signals'] ?? {}),
    );
  }
}

class DayFocusSignals {
  final double absorption;
  final double detoxification;
  final double fatMetabolism;
  final double fermentation;
  final double glucoseMetabolism;
  final double hepaticStress;

  DayFocusSignals({
    required this.absorption,
    required this.detoxification,
    required this.fatMetabolism,
    required this.fermentation,
    required this.glucoseMetabolism,
    required this.hepaticStress,
  });

  factory DayFocusSignals.fromJson(Map<String, dynamic> json) {
    return DayFocusSignals(
      absorption: (json['absorption'] ?? 0).toDouble(),
      detoxification: (json['detoxification'] ?? 0).toDouble(),
      fatMetabolism: (json['fat_metabolism'] ?? 0).toDouble(),
      fermentation: (json['fermentation'] ?? 0).toDouble(),
      glucoseMetabolism: (json['glucose_metabolism'] ?? 0).toDouble(),
      hepaticStress: (json['hepatic_stress'] ?? 0).toDouble(),
    );
  }
}
