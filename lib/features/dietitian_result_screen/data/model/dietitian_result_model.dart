// class DietitianResultModel {
//   final int status;
//   final double acetonePpm;
//   final double ppPress;
//   final double ethanolPpm;
//   final double? battery;
//   final double finalTemp;
//   final int duration;
//   final double? rawMic;
//   final double? bmHumid;
//   final double bestHumid;
//   final int bpm;
//   final double? valPress;
//   final double? peakPress;
//   final double cap;
//   final double val1820;
//   final double valFinal1820;
//   final double mvAcetone;
//   final double h2Ppm;
//   final int hwid;
//   final double? lastMv;
//   final double sugarScore;
//   final double respiratoryScore;
//   final double gutScore;
//   final double liverScore;
//   final int timestamp;
//   final dynamic blowRawValues;
//   final BlowArraysFevFvcValues? blowArraysFevFvcValues;

//   DietitianResultModel({
//     required this.status,
//     required this.acetonePpm,
//     required this.ppPress,
//     required this.ethanolPpm,
//     required this.battery,
//     required this.finalTemp,
//     required this.duration,
//     required this.rawMic,
//     required this.bmHumid,
//     required this.bestHumid,
//     required this.bpm,
//     required this.valPress,
//     required this.peakPress,
//     required this.cap,
//     required this.val1820,
//     required this.valFinal1820,
//     required this.mvAcetone,
//     required this.h2Ppm,
//     required this.hwid,
//     required this.lastMv,
//     required this.sugarScore,
//     required this.respiratoryScore,
//     required this.gutScore,
//     required this.liverScore,
//     required this.timestamp,
//     required this.blowRawValues,
//     required this.blowArraysFevFvcValues,
//   });

//   factory DietitianResultModel.fromJson(Map<String, dynamic> json) {
//     return DietitianResultModel(
//       status: json['status'] ?? 0,
//       acetonePpm: (json['AcetonePpm'] ?? 0).toDouble(),
//       ppPress: (json['pp_press'] ?? 0).toDouble(),
//       ethanolPpm: (json['ethanolPpm'] ?? 0).toDouble(),
//       battery: (json['battry'] != null) ? (json['battry']).toDouble() : null,
//       finalTemp: (json['finaltemp'] ?? 0).toDouble(),
//       duration: (json['duration'] ?? 0).toInt(),
//       rawMic: (json['rawmic'] != null) ? (json['rawmic']).toDouble() : null,
//       bmHumid: (json['bmhumid'] != null) ? (json['bmhumid']).toDouble() : null,
//       bestHumid: (json['besthumid'] ?? 0).toDouble(),
//       bpm: (json['bpm'] ?? 0).toInt(),
//       valPress:
//           (json['valpress'] != null) ? (json['valpress']).toDouble() : null,
//       peakPress:
//           (json['peak_press'] != null) ? (json['peak_press']).toDouble() : null,
//       cap: (json['cap'] ?? 0).toDouble(),
//       val1820: (json['val1820'] ?? 0).toDouble(),
//       valFinal1820: (json['valFinal1820'] ?? 0).toDouble(),
//       mvAcetone: (json['MVacetone'] ?? 0).toDouble(),
//       h2Ppm: (json['H2Ppm'] ?? 0).toDouble(),
//       hwid: (json['hwid'] ?? 0).toInt(),
//       lastMv: (json['lastmv'] != null) ? (json['lastmv']).toDouble() : null,
//       sugarScore: (json['SugarScore'] ?? 0).toDouble(),
//       respiratoryScore: (json['RespiratoryScore'] ?? 0).toDouble(),
//       gutScore: (json['GutScore'] ?? 0).toDouble(),
//       liverScore: (json['LiverScore'] ?? 0).toDouble(),
//       timestamp: (json['timestamp'] ?? 0).toInt(),
//       blowRawValues: json['BlowRawValues'],
//       blowArraysFevFvcValues:
//           json['Blow_arrays_fev_fvc_values'] != null
//               ? BlowArraysFevFvcValues.fromJson(
//                 json['Blow_arrays_fev_fvc_values'],
//               )
//               : null,
//     );
//   }

//   factory DietitianResultModel.dummy() {
//     return DietitianResultModel(
//       status: 1,
//       acetonePpm: 2.5,
//       ppPress: 101.3,
//       ethanolPpm: 0.8,
//       battery: 74.0,
//       finalTemp: 36.7,
//       duration: 3451,
//       rawMic: 0.75,
//       bmHumid: 45.2,
//       bestHumid: 50.0,
//       bpm: 72,
//       valPress: 98.6,
//       peakPress: 120.2,
//       cap: 1.23,
//       val1820: 0.87,
//       valFinal1820: 0.91,
//       mvAcetone: 3.14,
//       h2Ppm: 4.2,
//       hwid: 123456,
//       lastMv: 2.71,
//       sugarScore: 75.5,
//       respiratoryScore: 88.4,
//       gutScore: 64.3,
//       liverScore: 82.9,
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//       blowRawValues: {
//         "rawData": [
//           911.54,
//           944.55,
//           952.31,
//           958.11,
//           963.16,
//           964.89,
//           967.55,
//           970.12,
//           972.93,
//           974.09,
//           973.93,
//           973.77,
//           973.52,
//           974.15,
//           976.07,
//           977.76,
//           978.17,
//           980.98,
//           984.77,
//           985.23,
//           984.32,
//           981.45,
//           979.12,
//           976.31,
//           973.31,
//           970.96,
//           965.39,
//           961.08,
//           957.56,
//           950.98,
//           944.37,
//           938.03,
//           928.99,
//         ],
//         "extra": "sample values",
//       },
//       blowArraysFevFvcValues: BlowArraysFevFvcValues(
//         comparisonWithPredicted: {"FEV1": 95.0, "FVC": 97.5},
//         predicted: {"FEV1": 3.5, "FVC": 4.0},
//         respyrMeasured: {"FEV1": 3.3, "FVC": 3.9},
//       ),
//     );
//   }
// }

// class BlowArraysFevFvcValues {
//   final Map<String, double> comparisonWithPredicted;
//   final Map<String, double> predicted;
//   final Map<String, double> respyrMeasured;

//   BlowArraysFevFvcValues({
//     required this.comparisonWithPredicted,
//     required this.predicted,
//     required this.respyrMeasured,
//   });

//   factory BlowArraysFevFvcValues.fromJson(Map<String, dynamic> json) {
//     return BlowArraysFevFvcValues(
//       comparisonWithPredicted: Map<String, double>.from(
//         json['Comparison_with_Predicted(%)']?.map(
//               (k, v) => MapEntry(k, (v as num).toDouble()),
//             ) ??
//             {},
//       ),
//       predicted: Map<String, double>.from(
//         json['Predicted']?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
//             {},
//       ),
//       respyrMeasured: Map<String, double>.from(
//         json['Respyr_Measured']?.map(
//               (k, v) => MapEntry(k, (v as num).toDouble()),
//             ) ??
//             {},
//       ),
//     );
//   }
// }

class DietitianResultModel {
  final bool success;
  final String message;
  final int testId;
  final String urlCalled;
  final RespyrResponse respyrResponse;

  DietitianResultModel({
    required this.success,
    required this.message,
    required this.testId,
    required this.urlCalled,
    required this.respyrResponse,
  });

  factory DietitianResultModel.fromJson(Map<String, dynamic> json) {
    return DietitianResultModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      testId: json['test_id'] ?? 0,
      urlCalled: json['url_called'] ?? '',
      respyrResponse: RespyrResponse.fromJson(json['respyr_response'] ?? {}),
    );
  }
}

class RespyrResponse {
  final MetabolismScoreAnalysis metabolismScoreAnalysis;
  final BreathMarkerAnalysis breathMarkerAnalysis;
  final FatLossMetabolismScore fatLossMetabolismScore;

  RespyrResponse({
    required this.metabolismScoreAnalysis,
    required this.breathMarkerAnalysis,
    required this.fatLossMetabolismScore,
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
  final int score;
  final String whatIsThisScore;
  final String zone;

  ScoreItem({
    required this.clientState,
    required this.interpretation,
    required this.intervention,
    required this.ppmNote,
    required this.score,
    required this.whatIsThisScore,
    required this.zone,
  });

  factory ScoreItem.fromJson(Map<String, dynamic> json) {
    return ScoreItem(
      clientState: json['client_state'] ?? '',
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      ppmNote: json['ppm_note'] ?? '',
      score: (json['score'] ?? 0).toInt(),
      whatIsThisScore: json['what_is_this_score'] ?? '',
      zone: json['zone'] ?? '',
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
  final int ppm;
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
      ppm: (json['ppm'] ?? 0).toInt(),
      interpretation: json['interpretation'] ?? '',
      intervention: json['intervention'] ?? '',
      zone: json['zone'] ?? '',
      diabetic: json['diabetic'] ?? false,
      userGoal: json['user_goal'] ?? '',
      ratios:
          json['ratios'] != null
              ? Map<String, dynamic>.from(json['ratios'])
              : null,
      advice:
          json['advice'] != null ? MarkerAdvice.fromJson(json['advice']) : null,
    );
  }
}

class MarkerAdvice {
  final String whatLowers;
  final String whatRaises;

  MarkerAdvice({required this.whatLowers, required this.whatRaises});

  factory MarkerAdvice.fromJson(Map<String, dynamic> json) {
    return MarkerAdvice(
      whatLowers: json['what_lowers'] ?? '',
      whatRaises: json['what_raises'] ?? '',
    );
  }
}

class FatLossMetabolismScore {
  final String clientInterpretation;
  final String scientificInterpretation;
  final double score;
  final String zone;

  FatLossMetabolismScore({
    required this.clientInterpretation,
    required this.scientificInterpretation,
    required this.score,
    required this.zone,
  });

  factory FatLossMetabolismScore.fromJson(Map<String, dynamic> json) {
    return FatLossMetabolismScore(
      clientInterpretation: json['client_interpretation'] ?? '',
      scientificInterpretation: json['scientific_interpretation'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      zone: json['zone'] ?? '',
    );
  }
}
