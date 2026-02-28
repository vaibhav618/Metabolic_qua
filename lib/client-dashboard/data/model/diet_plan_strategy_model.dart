import 'dart:convert';
import '../../../features/client_profile/data/model/goals_model.dart';
import 'dietitian_model.dart';

class DietPlanStrategyModel {
  final int id;
  final String dietitianId;
  final String clientId;
  final String planTitle;
  final DateTime planStartDate;
  final DateTime planEndDate;
  final DateTime updatedAt;
  final int caloriesTarget;
  final int proteinTarget;
  final int fiberTarget;
  final int carbsTarget;
  final int fatTarget;
  final double waterTarget;
  final List<Goal> goals;         // from key: "goal" (array)
  final List<String> approaches;  // from key: "approach"
  final String status;            // active/completed/cancelled/other
  final DietitianModel? dietitianInfo;
  final bool isDiabetic;
  final int testNoAssigned;
  final String dietType;

  DietPlanStrategyModel( {
    required this.id,
    required this.dietitianId,
    required this.clientId,
    required this.planTitle,
    required this.planStartDate,
    required this.planEndDate,
    required this.updatedAt,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.fiberTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterTarget,
    required this.goals,
    required this.approaches,
    required this.status,
    required this.dietitianInfo,
    required this.isDiabetic,
    required this.testNoAssigned,
    required this.dietType,
  });

  static DateTime _d(dynamic v) =>
      DateTime.tryParse(v?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  static int _i(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
  static double _f(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;

  static List<Goal> _parseGoals(dynamic v) {
    if (v is List) {
      return v.map((e) => Goal.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is List) {
          return decoded.map((e) => Goal.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      } catch (_) {}
    }
    return <Goal>[];
  }

  static List<String> _parseApproach(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }

  factory DietPlanStrategyModel.fromJson(Map<String, dynamic> json) => DietPlanStrategyModel(
    id: _i(json['id']),
    dietitianId: json['dietitian_id']?.toString() ?? '',
    clientId: json['client_id']?.toString() ?? '',
    planTitle: json['plan_title']?.toString() ?? '',
    dietType: json['diet_type']?.toString() ?? '',
    planStartDate: _d(json['plan_start_date']),
    planEndDate: _d(json['plan_end_date']),
    updatedAt: _d(json['updated_at']),
    caloriesTarget: _i(json['calories_target']),
    proteinTarget: _i(json['protein_target']),
    fiberTarget: _i(json['fiber_target']),
    carbsTarget: _i(json['carbs_target']),
    testNoAssigned: _i(json['test_no_assigned']),
    fatTarget: _i(json['fat_target']),
    waterTarget: _f(json['water_target']),
    isDiabetic: (json['diabetic']?.toString() == "1"),
    goals: _parseGoals(json['goal'] ?? json['goals']),
    approaches: _parseApproach(json['approach']),
    status: json['status']?.toString().toLowerCase() ?? 'other',
    dietitianInfo: json['dietician_info'] == null
        ? null
        : DietitianModel.fromJson(Map<String, dynamic>.from(json['dietician_info'])),
  );



}
