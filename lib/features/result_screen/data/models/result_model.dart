class ResultModel {
  final double bmi;
  final double bmr;
  final int dttm; // Epoch timestamp
  final double gutAbsorptiveScore;
  final double gutFermentativeScore;
  final double fatMetabolismScore;
  final double glucoseMetabolismScore;
  final double hepaticScore;
  final double detoxScore;

  ResultModel({
    required this.bmi,
    required this.bmr,
    required this.dttm,
    required this.gutAbsorptiveScore,
    required this.gutFermentativeScore,
    required this.fatMetabolismScore,
    required this.glucoseMetabolismScore,
    required this.hepaticScore,
    required this.detoxScore,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'][0];

    return ResultModel(
      bmi: double.tryParse(data['bmi'].toString()) ?? 0.0,
      bmr: double.tryParse(data['bmr'].toString()) ?? 0.0,
      dttm: int.tryParse(data['dttm'].toString()) ?? 0,
      gutAbsorptiveScore:
          double.tryParse(data['gut_absorptive']?.toString() ?? '') ?? 97.0,
      gutFermentativeScore:
          double.tryParse(data['gut_fermentative']?.toString() ?? '') ?? 95.0,
      fatMetabolismScore:
          double.tryParse(data['fat_metabolism']?.toString() ?? '') ?? 91.0,
      glucoseMetabolismScore:
          double.tryParse(data['glucose']?.toString() ?? '') ?? 92.0,
      hepaticScore: double.tryParse(data['hepatic']?.toString() ?? '') ?? 85.0,
      detoxScore: double.tryParse(data['detox']?.toString() ?? '') ?? 89.0,
    );
  }

  /// 🔹 Dummy data for UI testing
  factory ResultModel.dummy() {
    return ResultModel(
      bmi: 25.0,
      bmr: 1827.0,
      dttm: 1747910241, // Epoch time (UNIX timestamp)
      gutAbsorptiveScore: 75.0,
      gutFermentativeScore: 90.0,
      fatMetabolismScore: 51.0,
      glucoseMetabolismScore: 43.0,
      hepaticScore: 74.0,
      detoxScore: 89.0,
    );
  }
}
