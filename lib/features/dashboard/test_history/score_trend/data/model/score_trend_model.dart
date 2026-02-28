/// Represents a single test record from the API.
class ScoreTrendModel {
  final double absorptiveScore;
  final double fermentativeScore;
  final double fatScore;
  final double glucoseScore;
  final double hepaticStressScore;
  final double detoxificationScore;
  final double fatLossScore;
  final double acetonePpm;
  final double h2Ppm;
  final double ethanolPpm;
  final String dateTime;

  ScoreTrendModel({
    required this.absorptiveScore,
    required this.fermentativeScore,
    required this.fatScore,
    required this.glucoseScore,
    required this.hepaticStressScore,
    required this.detoxificationScore,
    required this.fatLossScore,
    required this.acetonePpm,
    required this.h2Ppm,
    required this.ethanolPpm,
    required this.dateTime,
  });

  factory ScoreTrendModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dynamic JSON values (int, double, or string) into a double.
    // Defaults to 0.0 if the value is null or cannot be parsed.
    double safeParseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ScoreTrendModel(
      absorptiveScore: safeParseDouble(json['absorptive_metabolism_score']),
      fermentativeScore: safeParseDouble(json['fermentative_metabolism_score']),
      fatScore: safeParseDouble(json['fat_metabolism_score']),
      glucoseScore: safeParseDouble(json['glucose_metabolism_score']),
      hepaticStressScore: safeParseDouble(json['hepatic_stress_metabolism_score']),
      detoxificationScore: safeParseDouble(json['detoxification_metabolism_score']),
      fatLossScore: safeParseDouble(json['fat_loss_metabolism_score']),
      acetonePpm: safeParseDouble(json['acetone_ppm']),
      h2Ppm: safeParseDouble(json['h2_ppm']),
      ethanolPpm: safeParseDouble(json['ethanol_ppm']),
      dateTime: json['date_time'] as String? ?? 'Unknown Date',
    );
  }
}