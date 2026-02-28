import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/log_food/data/repository/fetch_food_log_api.dart';
import 'package:http/http.dart' as http;
import '../widgets/day_chip.dart';
import '../widgets/diet_plan_meal_item.dart';

class DietPlanScreen extends StatefulWidget {
  final String dieticianId;
  final String profileId;
  final DietPlanStrategyModel dietPlanStrategyModel;
  const DietPlanScreen({
    super.key,
    required this.dieticianId,
    required this.profileId,
    required this.dietPlanStrategyModel,
  });

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  bool loading = true;
  String? error;

  Map<String, dynamic> diet = {};
  String activeDay = 'monday'; // monday..sunday for the selected date
  DateTime currentDate = DateTime.now();

  // Full list of dates in plan range (start -> end)
  List<DateTime> planDates = [];

  // Logged keys cache for selected day
  Set<String> loggedKeys = <String>{};

  final Map<String, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    _initPlanDates(); // uses DateTime directly from the model

    // Default selection: today if within plan, else start date
    if (planDates.isNotEmpty) {
      final today = _stripTime(DateTime.now());
      if (planDates.any((d) => _stripTime(d) == today)) {
        currentDate = today;
      } else {
        currentDate = _stripTime(planDates.first);
      }
    }
    activeDay = _weekdayKeyFromDate(currentDate);

    _bootstrap();
  }

  void _initPlanDates() {
    try {
      // ✅ Use DateTime directly from the model (no parsing)
      final start = _stripTime(widget.dietPlanStrategyModel.planStartDate);
      final end = _stripTime(widget.dietPlanStrategyModel.planEndDate);

      if (kDebugMode) {
        print("Plan start: $start");
        print("Plan end  : $end");
      }

      final days = <DateTime>[];
      DateTime d = start;
      while (!d.isAfter(end)) {
        days.add(d);
        d = d.add(const Duration(days: 1));
      }
      planDates = days;

      // Unique keys for chip centering
      for (final d in planDates) {
        _chipKeys[_weekdayKeyFromDate(d) + d.toIso8601String()] = GlobalKey();
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Plan date range error: $e");
      planDates = [];
    }
  }

  Future<void> _bootstrap() async {
    await fetchDiet();
    await _fetchLoggedForDate(currentDate);
  }

  // ---------- helpers ----------
  String _weekdayKeyFromDate(DateTime date) {
    const names = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return names[(date.weekday - 1).clamp(0, 6)];
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isFutureDay(DateTime selected) {
    final today = _stripTime(DateTime.now());
    return _stripTime(selected).isAfter(today);
  }

  // Parse time strings like "08:30", "8:30 PM", "08:30:00", returns null if not parseable.
  TimeOfDay? _tryParseTimeOfDay(String s) {
    if (s.isEmpty) return null;
    final t = s.trim().toUpperCase();
    final regex =
    RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*([AP]M)?$');
    final m = regex.firstMatch(t);
    if (m == null) return null;
    final h = int.tryParse(m.group(1)!);
    final min = int.tryParse(m.group(2)!);
    if (h == null || min == null) return null;

    var hour = h;
    if (m.group(3) != null) {
      final ampm = m.group(3)!;
      if (ampm == 'PM' && hour < 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
    }
    if (hour < 0 || hour > 23 || min < 0 || min > 59) return null;
    return TimeOfDay(hour: hour, minute: min);
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final t = _tryParseTimeOfDay(timeStr);
    final h = t?.hour ?? 0;
    final m = t?.minute ?? 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }
  // ---------- end helpers ----------

  Future<void> fetchDiet() async {
    try {
      final uri = Uri.parse(
          'https://humorstech.com/dietitian/api/app/get_diet_plan.php');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          "login_id": widget.dieticianId,
          "profile_id": widget.profileId,
          "diet_plan_id": widget.dietPlanStrategyModel.id,
        }),
      );

      final body = utf8.decode(res.bodyBytes);
      final top = json.decode(body) as Map<String, dynamic>;
      if (res.statusCode != 200 || top['success'] != true) {
        throw Exception('Server error');
      }

      final dataArr = (top['data'] as List?) ?? [];
      if (dataArr.isEmpty) throw Exception('No data');

      final data0 = dataArr.first as Map<String, dynamic>;
      final dynDietJson = data0['diet_json'];

      late final Map<String, dynamic> parsedDiet;
      if (dynDietJson is Map) {
        parsedDiet = Map<String, dynamic>.from(dynDietJson);
      } else if (dynDietJson is String) {
        parsedDiet = json.decode(dynDietJson) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Unexpected diet_json type: ${dynDietJson.runtimeType}');
      }

      setState(() {
        diet = parsedDiet;
        activeDay = _weekdayKeyFromDate(currentDate);
        loading = false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback((_) => _centerDayChip(currentDate));
    } catch (e) {
      setState(() {
        error = 'Fetch Error: $e';
        loading = false;
      });
    }
  }

  Future<void> _fetchLoggedForDate(DateTime date) async {
    try {
      final keys = await FoodLogFetchApi.fetchLoggedKeys(
        dieticianId: widget.dieticianId,
        profileId: widget.profileId,
        dietPlanId: widget.dietPlanStrategyModel.id.toString(),
        date: date,
      );
      setState(() => loggedKeys = keys);
    } catch (e) {
      if (kDebugMode) debugPrint("Fetch logged failed: $e");
    }
  }

  Future<void> _centerDayChip(DateTime date) async {
    final chipKey =
    _chipKeys[_weekdayKeyFromDate(date) + date.toIso8601String()];
    if (chipKey?.currentContext != null) {
      await Scrollable.ensureVisible(
        chipKey!.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
          body:
          Center(child: Text(error!, textAlign: TextAlign.center)));
    }

    // Meals for the weekday of currentDate
    final dayKey = _weekdayKeyFromDate(currentDate);
    final dayData = diet[dayKey] as Map<String, dynamic>?;
    final meals = (dayData?['meals'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final bool isFuture = _isFutureDay(currentDate);
    final bool canLog = !isFuture; // allow past & today, block future

    String monthName(int m) => const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][m - 1];

    // 🔥 Find nearest meal time (for currentDate) to *now*
    int? nearestIndex;
    if (meals.isNotEmpty) {
      final now = DateTime.now();
      Duration? smallestDiff;

      for (int i = 0; i < meals.length; i++) {
        final m = meals[i];
        final mealTimeStr = (m['time'] ?? '').toString();
        final mealDateTime = _combineDateAndTime(currentDate, mealTimeStr);

        final diff = mealDateTime.difference(now).abs();

        if (smallestDiff == null || diff < smallestDiff) {
          smallestDiff = diff;
          nearestIndex = i;
        }
      }
    }

    String getFoodType(String preference) {
      final p = preference.toLowerCase();

      // Pure veg categories
      const veg = [
        "vegetarian",
        "vegan",
        "lacto vegetarian",
      ];

      // Non-veg categories
      const nonVeg = [
        "non vegetarian",
        "eggetarian",
        "fishitarian",
        "pescatarian",
        "flexitarian",
        "ovo vegetarian",
        "lacto-ovo vegetarian",
      ];

      if (veg.contains(p)) return "veg";
      if (nonVeg.contains(p)) return "non_veg";

      return "NA"; // default
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              'Diet Plan',
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.90,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  "${widget.dietPlanStrategyModel.planStartDate.day} ${monthName(widget.dietPlanStrategyModel.planStartDate.month)} ${widget.dietPlanStrategyModel.planStartDate.year} - ${widget.dietPlanStrategyModel.planEndDate.day} ${monthName(widget.dietPlanStrategyModel.planEndDate.month)} ${widget.dietPlanStrategyModel.planEndDate.year}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.10,
                    letterSpacing: -0.20,
                  ),
                ),


                // Container(
                //   decoration: BoxDecoration(color: const Color(0xFFFFDFDB)),
                //   padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                //   child: Text(widget.dietPlanStrategyModel.dietType,
                //     style: GoogleFonts.poppins(
                //       color: const Color(0xFFDA5747),
                //       fontSize: 12,
                //       fontWeight: FontWeight.w400,
                //       height: 1.10,
                //       letterSpacing: -0.24,
                //     ),
                //   ),
                //
                // )
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                child: Row(
                  spacing: 12,
                  children: [
                    for (int i = 0; i < planDates.length; i++) ...[
                      DayChip(
                        key: _chipKeys[_weekdayKeyFromDate(planDates[i]) +
                            planDates[i].toIso8601String()],
                        label:
                        _weekdayKeyFromDate(planDates[i]), // monday..sunday
                        date: planDates[i],
                        selected: _stripTime(planDates[i]) ==
                            _stripTime(currentDate),
                        onTap: () async {
                          setState(() {
                            currentDate = _stripTime(planDates[i]);
                            activeDay =
                                _weekdayKeyFromDate(currentDate);
                          });
                          await _centerDayChip(currentDate);
                          await _fetchLoggedForDate(currentDate);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: meals.length,
                itemBuilder: (_, i) {
                  final m = meals[i];
                  final mealTimeStr = (m['time'] ?? '').toString();
                  final items = (m['items'] as List? ?? const [])
                      .whereType<Map<String, dynamic>>()
                      .toList();

                  final logDate = currentDate; // concrete date for this chip
                  final logDateTime =
                  _combineDateAndTime(logDate, mealTimeStr);

                  final bool isExpandable = (nearestIndex != null &&
                      i == nearestIndex); // 👈 expand nearest-time meal

                  return Opacity(
                    opacity: canLog ? 1.0 : 0.55,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DietPlanMealItem(
                        mealTitle: mealTimeStr,
                        items: items,
                        loggedKeys: loggedKeys,
                        canLog: canLog,
                        logDate: logDate,
                        logDateTime: logDateTime,
                        dieticianId: widget.dieticianId,
                        profileId: widget.profileId,
                        dietPlanId: widget.dietPlanStrategyModel.id.toString(),
                        onLoggedKeyAdd: (key) {
                          setState(() {
                            loggedKeys =
                            Set<String>.from(loggedKeys)..add(key);
                          });
                        },
                        isExpandable: isExpandable,
                      ),
                    ),
                  );
                }, separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 20,);
              },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
