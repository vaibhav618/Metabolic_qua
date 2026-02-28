// lib/features/tracking/weight_tracking/data/models/weight_log_model.dart

class WeightLogModel {
  final String id;
  final String profileId;
  final double weightKg;
  final double targetWeight;
  final String weightChangeType; // "weight_loss" / "weight_gain"
  final String weightProgress;
  final String loggedBy;
  final String loggedById;
  final String? notes;
  final String logDate; // "YYYY-MM-DD"
  final String logTime; // "HH:MM:SS"
  final String createdAt;

  WeightLogModel({
    required this.id,
    required this.profileId,
    required this.weightKg,
    required this.targetWeight,
    required this.weightChangeType,
    required this.weightProgress,
    required this.loggedBy,
    required this.loggedById,
    required this.notes,
    required this.logDate,
    required this.logTime,
    required this.createdAt,
  });

  factory WeightLogModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return WeightLogModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      weightKg: _toDouble(json['weight_kg']),
      targetWeight: _toDouble(json['target_weight']),
      weightChangeType: json['weight_change_type']?.toString() ?? '',
      weightProgress: json['weight_progress']?.toString() ?? '',
      loggedBy: json['logged_by']?.toString() ?? '',
      loggedById: json['logged_by_id']?.toString() ?? '',
      notes: json['notes']?.toString(),
      logDate: json['log_date']?.toString() ?? '',
      logTime: json['log_time']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
