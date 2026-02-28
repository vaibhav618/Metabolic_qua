class WaterLogData {
  final DateTime date;
  final int totalMl;
  final int totalTargetMl;

  WaterLogData({
    required this.date,
    required this.totalMl,
    required this.totalTargetMl,
  });

  double get totalLiters => totalMl / 1000.0;
  double get targetLiters => totalTargetMl / 1000.0;

  factory WaterLogData.fromJson(Map<String, dynamic> json) {
    return WaterLogData(
      date: DateTime.parse(json['date'] as String),
      totalMl: (json['total_ml'] as num).toInt(),
      totalTargetMl: (json['total_target_ml'] as num).toInt(),
    );
  }
}
