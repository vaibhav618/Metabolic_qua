// lib/features/log_food/data/model/food_log_day.dart
import 'dart:convert';

class FoodLogRow {
  final int id;
  final String mealTitle;
  final String mealName;
  final String mealDay;      // monday..sunday (from DB)
  final DateTime mealDate;   // full datetime
  final Map<String, dynamic> mealValues;
  final String dttm;
  final String tsstamp;

  FoodLogRow({
    required this.id,
    required this.mealTitle,
    required this.mealName,
    required this.mealDay,
    required this.mealDate,
    required this.mealValues,
    required this.dttm,
    required this.tsstamp,
  });

  factory FoodLogRow.fromJson(Map<String, dynamic> j) {
    Map<String, dynamic> mv;
    final raw = j['meal_values'];
    if (raw is Map<String, dynamic>) {
      mv = raw;
    } else if (raw is String) {
      try { mv = jsonDecode(raw) as Map<String, dynamic>; } catch (_) { mv = {}; }
    } else {
      mv = {};
    }

    return FoodLogRow(
      id: int.tryParse(j['id'].toString()) ?? 0,
      mealTitle: (j['meal_title'] ?? '').toString(),
      mealName: (j['meal_name'] ?? '').toString(),
      mealDay: (j['meal_day'] ?? '').toString(),
      mealDate: DateTime.tryParse((j['meal_date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      mealValues: mv,
      dttm: (j['dttm'] ?? '').toString(),
      tsstamp: (j['tsstamp'] ?? '').toString(),
    );
  }
}

class FoodLogDay {
  final String date;         // YYYY-MM-DD
  final String weekday;      // monday..sunday
  final int count;
  final List<FoodLogRow> items;

  FoodLogDay({
    required this.date,
    required this.weekday,
    required this.count,
    required this.items,
  });

  factory FoodLogDay.fromJson(Map<String, dynamic> j) => FoodLogDay(
    date: (j['date'] ?? '').toString(),
    weekday: (j['weekday'] ?? '').toString(),
    count: int.tryParse(j['count'].toString()) ?? 0,
    items: ((j['items'] as List?) ?? [])
        .map((e) => FoodLogRow.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
