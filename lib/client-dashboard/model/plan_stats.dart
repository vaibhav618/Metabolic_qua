class PlanStats {
  // ---- tests ----
  final int testsTaken;      // test_days_till_today
  final int testsMissed;     // missed_days_till_today (or derived)
  final int testsTotal;      // test_no_assigned OR days_elapsed_till_today

  // ---- meals ----
  final int foodLogCount;     // food_log_count (rows)
  final int foodLogDays;      // food_log_days (distinct days)
  final int foodLogMissed;    // food_log_missed_days (or derived)

  // ---- plan window ----
  final int planTotalDays;    // days_elapsed_till_today

  PlanStats({
    required this.testsTaken,
    required this.testsMissed,
    required this.testsTotal,
    required this.foodLogCount,
    required this.foodLogDays,
    required this.foodLogMissed,
    required this.planTotalDays,
  });

  factory PlanStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final daysElapsed   = toInt(json['days_elapsed_till_today']);
    final testDays      = toInt(json['test_days_till_today']);
    final missedDaysIn  = toInt(json['missed_days_till_today']);
    final assigned      = toInt(json['test_no_assigned']);

    final foodCount     = toInt(json['food_log_count']);
    final foodDays      = toInt(json['food_log_days']);
    final foodMissedIn  = toInt(json['food_log_missed_days']);

    final testsTotal    = (assigned > 0) ? assigned : daysElapsed;
    final testsMissed   = (missedDaysIn > 0) ? missedDaysIn : (daysElapsed - testDays).clamp(0, 1 << 30);
    final foodMissed    = (foodMissedIn > 0) ? foodMissedIn : (daysElapsed - foodDays).clamp(0, 1 << 30);

    return PlanStats(
      testsTaken:     testDays,
      testsMissed:    testsMissed,
      testsTotal:     testsTotal,
      foodLogCount:   foodCount,
      foodLogDays:    foodDays,
      foodLogMissed:  foodMissed,
      planTotalDays:  daysElapsed,
    );
  }
}

class DietPlanStatApi {
  final bool success;
  final String message;
  final PlanStats data;

  DietPlanStatApi({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DietPlanStatApi.fromJson(Map<String, dynamic> json) {
    // API returns { data: [...] } or { data: {...} }
    dynamic raw = json['data'] ?? {};
    if (raw is List && raw.isNotEmpty) raw = raw.first;
    if (raw is! Map<String, dynamic>) raw = <String, dynamic>{};

    return DietPlanStatApi(
      success: (json['success'] ?? false) == true,
      message: (json['message'] ?? '').toString(),
      data:    PlanStats.fromJson(raw),
    );
  }
}
