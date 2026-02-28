// diet_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const dayKeys = [
  'monday','tuesday','wednesday','thursday','friday','saturday','sunday'
];

class DietTotals {
  final num protein, carbs, fat, calories;
  const DietTotals({this.protein=0,this.carbs=0,this.fat=0,this.calories=0});
  factory DietTotals.fromJson(Map<String, dynamic>? j) => DietTotals(
    protein: (j?['protein'] ?? 0) ?? 0,
    carbs: (j?['carbs'] ?? 0) ?? 0,
    fat: (j?['fat'] ?? 0) ?? 0,
    calories: (j?['calories_kcal'] ?? 0) ?? 0,
  );
}

class DietItem {
  final String name, portion;
  final num protein, carbs, fat, calories;
  DietItem({required this.name,required this.portion,this.protein=0,this.carbs=0,this.fat=0,this.calories=0});
  factory DietItem.fromJson(Map<String, dynamic> j)=>DietItem(
    name: j['name']?.toString() ?? '',
    portion: j['portion']?.toString() ?? '',
    protein: j['protein'] ?? 0,
    carbs: j['carbs'] ?? 0,
    fat: j['fat'] ?? 0,
    calories: j['calories_kcal'] ?? 0,
  );
}

class DietMeal {
  final String time;
  final List<DietItem> items;
  final DietTotals totals;
  DietMeal({required this.time, required this.items, required this.totals});
  factory DietMeal.fromJson(Map<String, dynamic> j)=>DietMeal(
    time: j['time']?.toString() ?? '',
    items: (j['items'] as List? ?? []).map((e)=>DietItem.fromJson(e)).toList(),
    totals: DietTotals.fromJson(j['totals']),
  );
}

class DietDay {
  final DietTotals totals;
  final List<DietMeal> meals;
  DietDay({required this.totals, required this.meals});
  factory DietDay.fromJson(Map<String, dynamic>? j)=>DietDay(
    totals: DietTotals.fromJson(j?['totals']),
    meals: (j?['meals'] as List? ?? []).map((e)=>DietMeal.fromJson(e)).toList(),
  );
}

class DietApi {
  static Future<Map<String, DietDay>> parseWeekFromJson(String body) async {
    final Map<String, dynamic> root = json.decode(body);

    // Keep ALL day keys that exist in the JSON (even empty)
    final out = <String, DietDay>{};
    for (final k in dayKeys) {
      if (root.containsKey(k)) {
        out[k] = DietDay.fromJson(root[k] as Map<String, dynamic>?);
      }
    }
    return out;
  }

  // If you fetch from server, use this:
  static Future<Map<String, DietDay>> fetchWeekFromServer(Uri url, {Map<String,String>? form}) async {
    final r = await http.post(url, body: form ?? {});
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    return parseWeekFromJson(r.body);
  }
}
