// lib/models/models.dart
import 'dart:convert';

/// ---- Root API response ----
class DietPlanModel {
  final bool success;
  final int count;
  final List<DietDataItem> data;

  DietPlanModel({
    required this.success,
    required this.count,
    required this.data,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => DietDataItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return DietPlanModel(
      success: json['success'] == true,
      count: json['count'] is int ? json['count'] as int : list.length,
      data: list,
    );
  }

  static DietPlanModel fromJsonString(String body) =>
      DietPlanModel.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

/// ---- One record inside "data" ----
class DietDataItem {
  final int id;
  final String loginId;
  final String profileId;
  final String mimeType;
  final int payloadLen;
  final String sha256;
  final String dttm; // Keep as string unless you need DateTime
  final WeeklyDiet dietJson;
  final String? dietPlanId;
  final String? startDate; // nullable in your sample
  final String? endDate;   // nullable in your sample

  DietDataItem({
    required this.id,
    required this.loginId,
    required this.profileId,
    required this.mimeType,
    required this.payloadLen,
    required this.sha256,
    required this.dttm,
    required this.dietJson,
    required this.dietPlanId,
    required this.startDate,
    required this.endDate,
  });

  factory DietDataItem.fromJson(Map<String, dynamic> json) {
    return DietDataItem(
      id: _i(json['id']),
      loginId: json['login_id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      payloadLen: _i(json['payload_len']),
      sha256: json['sha256']?.toString() ?? '',
      dttm: json['dttm']?.toString() ?? '',
      dietJson: WeeklyDiet.fromJson(Map<String, dynamic>.from(json['diet_json'] ?? {})),
      dietPlanId: json['diet_plan_id']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}

/// ---- Weekly diet wrapper (days map + notes) ----
/// We map day-keys (monday..sunday) dynamically.
/// Unknown keys (like "_notes") are routed into `notes`.
class WeeklyDiet {
  final Map<String, DayPlan> days; // key: monday/tuesday/...
  final Notes notes;

  WeeklyDiet({
    required this.days,
    required this.notes,
  });

  /// Ordered list of days you can show in UI
  static const orderedDays = <String>[
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday'
  ];

  factory WeeklyDiet.fromJson(Map<String, dynamic> json) {
    final map = <String, DayPlan>{};
    Notes notes = Notes.empty();

    json.forEach((key, value) {
      if (key == '_notes') {
        notes = Notes.fromJson(Map<String, dynamic>.from(value ?? {}));
      } else {
        // treat as day if it has totals/meals
        if (value is Map && (value['totals'] != null || value['meals'] != null)) {
          map[key.toString().toLowerCase()] = DayPlan.fromJson(Map<String, dynamic>.from(value));
        }
      }
    });

    return WeeklyDiet(days: map, notes: notes);
  }

  /// Return day keys in logical order but only those present.
  List<String> availableDayKeysOrdered() {
    final present = days.keys.map((e) => e.toLowerCase()).toSet();
    final out = <String>[];
    for (final d in orderedDays) {
      if (present.contains(d)) out.add(d);
    }
    // include any extra unexpected keys at the end
    for (final k in days.keys) {
      if (!out.contains(k)) out.add(k);
    }
    return out;
  }
}

/// ---- One day ----
class DayPlan {
  final Macros totals;
  final List<Meal> meals;

  DayPlan({required this.totals, required this.meals});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      totals: Macros.fromJson(Map<String, dynamic>.from(json['totals'] ?? {})),
      meals: (json['meals'] as List? ?? [])
          .map((e) => Meal.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// ---- Totals / Macros ----
class Macros {
  final int protein;
  final int carbs;
  final int fat;
  final int caloriesKcal;

  Macros({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.caloriesKcal,
  });

  factory Macros.fromJson(Map<String, dynamic> json) => Macros(
    protein: _i(json['protein']),
    carbs: _i(json['carbs']),
    fat: _i(json['fat']),
    caloriesKcal: _i(json['calories_kcal']),
  );
}

/// ---- Meal (time + items + totals) ----
class Meal {
  final String time;      // e.g., "Breakfast at 10:00 AM"
  final List<MealItem> items;
  final Macros totals;

  Meal({
    required this.time,
    required this.items,
    required this.totals,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
    time: json['time']?.toString() ?? '',
    items: (json['items'] as List? ?? [])
        .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    totals: Macros.fromJson(Map<String, dynamic>.from(json['totals'] ?? {})),
  );
}


class MealItem {
  final String name;
  final String portion;
  final int protein;
  final int carbs;
  final int fat;
  final int caloriesKcal;

  MealItem({
    required this.name,
    required this.portion,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.caloriesKcal,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    name: json['name']?.toString() ?? '',
    portion: json['portion']?.toString() ?? '',
    protein: _i(json['protein']),
    carbs: _i(json['carbs']),
    fat: _i(json['fat']),
    caloriesKcal: _i(json['calories_kcal']),
  );
}

/// ---- Notes (optional) ----
class Notes {
  final List<dynamic> warnings;
  final List<dynamic> illegible;
  final List<dynamic> omissions;

  Notes({
    required this.warnings,
    required this.illegible,
    required this.omissions,
  });

  factory Notes.empty() => Notes(warnings: const [], illegible: const [], omissions: const []);

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    warnings: (json['warnings'] as List? ?? const []),
    illegible: (json['illegible'] as List? ?? const []),
    omissions: (json['omissions'] as List? ?? const []),
  );
}

/// ---- helpers ----
int _i(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
