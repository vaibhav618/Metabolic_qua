import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import '../../../../client-dashboard/extras/meal_time_helper.dart';
import '../../data/model/food_log_day.dart';
import '../../data/repository/logged_food_service.dart';
import '../widgets/logged_food_goal_card.dart';

class FoodLogByDayScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  final DietitianDetailModel dietitianModel;
  final DietPlanStrategyModel dietPlanStrategyModel;

  const FoodLogByDayScreen({
    super.key,
    required this.dietPlanStrategyModel,
    required this.clientProfileModel,
    required this.dietitianModel,
  });

  @override
  State<FoodLogByDayScreen> createState() => _FoodLogByDayScreenState();
}

class _FoodLogByDayScreenState extends State<FoodLogByDayScreen> {
  late Future<List<FoodLogDay>> future;

  int _selectedIndex = 0;
  bool _selectedInitialized = false;

  // --- NEW: scroll-to-center plumbing ---
  final _chipScrollController = ScrollController();
  final _scrollKey = GlobalKey();
  List<GlobalKey> _chipKeys = [];

  void _ensureChipKeys(int len) {
    if (_chipKeys.length != len) {
      _chipKeys = List.generate(len, (_) => GlobalKey());
    }
  }

  void _centerOnChip(int index) {
    if (index < 0 || index >= _chipKeys.length) return;
    final chipCtx = _chipKeys[index].currentContext;
    final scrollCtx = _scrollKey.currentContext;
    if (chipCtx == null || scrollCtx == null) return;

    final scrollBox = scrollCtx.findRenderObject() as RenderBox?;
    final chipBox = chipCtx.findRenderObject() as RenderBox?;
    if (scrollBox == null || chipBox == null) return;

    final chipPos = chipBox.localToGlobal(Offset.zero, ancestor: scrollBox);
    final chipCenterX = chipPos.dx + chipBox.size.width / 2;
    final viewportWidth = scrollBox.size.width;

    final current = _chipScrollController.offset;
    final target = (current + chipCenterX - viewportWidth / 2)
        .clamp(0.0, _chipScrollController.position.maxScrollExtent);

    _chipScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
  // --------------------------------------

  @override
  void initState() {
    super.initState();
    // IMPORTANT: correct param mapping
    future = LoggedFoodService.fetchPlanDays(
      dieticianId: widget.dietitianModel.dietitianId,
      profileId: widget.clientProfileModel.profileId,
      dietPlanId: widget.dietPlanStrategyModel.id.toString(),
    );
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  void _initSelectedIfNeeded(List<FoodLogDay> days) {
    if (_selectedInitialized || days.isEmpty) return;
    final today = DateTime.now();
    final todayStr =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    int idx = days.indexWhere((d) => d.date == todayStr);
    if (idx < 0) idx = days.indexWhere((d) => d.count > 0);
    _selectedIndex = idx >= 0 ? idx : 0;
    _selectedInitialized = true;

    // center initial selection after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnChip(_selectedIndex);
    });
  }

  bool _isFutureYmd(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      final today = DateTime.now();
      final dd = DateTime(d.year, d.month, d.day);
      final tt = DateTime(today.year, today.month, today.day);
      return dd.isAfter(tt);
    } catch (_) {
      return false;
    }
  }

  // --------- robust numeric parsing & totals ---------
  double _numFrom(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString();
    final m = RegExp(r'[-+]?\d*\.?\d+').firstMatch(s);
    if (m == null) return 0;
    return double.tryParse(m.group(0) ?? '0') ?? 0;
  }

  double _firstNumFromKeys(Map map, List<String> keys) {
    for (final k in keys) {
      if (map.containsKey(k) && map[k] != null && map[k].toString().trim().isNotEmpty) {
        return _numFrom(map[k]);
      }
    }
    return 0;
  }

  Map<String, double> _dayTotals(FoodLogDay day) {
    double kcal = 0, protein = 0, carbs = 0, fat = 0;

    for (final it in day.items) {
      final mv = it.mealValues ?? {};
      kcal    += _firstNumFromKeys(mv, ['foodCalories', 'calories', 'kcal']);
      protein += _firstNumFromKeys(mv, ['foodProtein', 'protein']);
      carbs   += _firstNumFromKeys(mv, ['foodCarbs', 'carbs']);
      fat     += _firstNumFromKeys(mv, ['foodFat', 'fat']);
    }

    return {
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }


  @override
  Widget build(BuildContext context) {
    String monthName(int m) => const [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ][m - 1];

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
            Text(
              "${widget.dietPlanStrategyModel.planStartDate.day} "
                  "${monthName(widget.dietPlanStrategyModel.planStartDate.month)} "
                  "${widget.dietPlanStrategyModel.planStartDate.year} - "
                  "${widget.dietPlanStrategyModel.planEndDate.day} "
                  "${monthName(widget.dietPlanStrategyModel.planEndDate.month)} "
                  "${widget.dietPlanStrategyModel.planEndDate.year}",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.10,
                letterSpacing: -0.20,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<FoodLogDay>>(
          future: future,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text("Error: ${snap.error}"));
            }
            final days = snap.data ?? const <FoodLogDay>[];
            if (days.isEmpty) {
              return const Center(child: Text("No logs in this plan window."));
            }

            _initSelectedIfNeeded(days);
            final selectedDay = days[_selectedIndex];
            final isFuture = _isFutureYmd(selectedDay.date);

            // ---- Group items by meal_title (preserve order of first appearance)
            final Map<String, List<FoodLogRow>> grouped = {};
            for (final row in selectedDay.items) {
              final key = row.mealTitle.toString();
              grouped.putIfAbsent(key, () => <FoodLogRow>[]).add(row);
            }
            final groupedEntries = grouped.entries.toList();

            // compute totals for selected date
            final totals = _dayTotals(selectedDay);

            // ensure chip keys available
            _ensureChipKeys(days.length);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: SingleChildScrollView(
                      key: _scrollKey,
                      controller: _chipScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(days.length, (i) {
                          final d = days[i];
                          final isSel = i == _selectedIndex;

                          final dateObj = DateTime.tryParse(d.date);
                          final isFutureChip = dateObj != null && dateObj.isAfter(DateTime.now());

                          final dow = d.weekday.isNotEmpty
                              ? d.weekday[0].toUpperCase() + d.weekday.substring(1, 3)
                              : (dateObj != null
                              ? ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][dateObj.weekday - 1]
                              : "");
                          String dayNum = "";
                          if (dateObj != null) {
                            dayNum = "${dateObj.day}";
                          }

                          return GestureDetector(
                            onTap: isFutureChip
                                ? null
                                : () {
                              setState(() => _selectedIndex = i);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _centerOnChip(i);
                              });
                            },
                            child: Opacity(
                              opacity: isFutureChip ? 0.4 : 1.0,
                              child: Container(
                                key: _chipKeys[i],
                                margin: const EdgeInsets.only(right: 8),
                                decoration: ShapeDecoration(
                                  color: isSel ? const Color(0xFF308BF9) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      dayNum,
                                      style: GoogleFonts.poppins(
                                        color: isSel ? Colors.white : const Color(0xFF535359),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.26,
                                        letterSpacing: -0.30,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dow,
                                      style: GoogleFonts.poppins(
                                        color: isSel ? Colors.white : const Color(0xFF535359),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Visibility(
                      visible: groupedEntries.isNotEmpty,
                      replacement: Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: loggedFoodGoalCard(
                              dietPlanStrategyModel: widget.dietPlanStrategyModel,
                              total: totals,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 19),
                            child: Text(
                              isFuture ? "Not yet tracked" : "No meals logged",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFA1A1A1),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.10,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                          SizedBox(height: 50,)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: loggedFoodGoalCard(
                              dietPlanStrategyModel: widget.dietPlanStrategyModel,
                              total: totals,
                            ),
                          ),

                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 19),
                            child: Text(
                              "Meal logged",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ListView.separated(
                            itemCount: groupedEntries.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final mealTitle = groupedEntries[index].key; // e.g., "Post Dinner at 10:00 PM"
                              final items = groupedEntries[index].value;

                              return Container(
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 11),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashFactory: NoSplash.splashFactory,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    collapsedBackgroundColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    collapsedShape: const RoundedRectangleBorder(),
                                    shape: const RoundedRectangleBorder(),
                                    childrenPadding: const EdgeInsets.only(top: 12, bottom: 31, left: 6, right: 6),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 10,
                                      children: [
                                        Text(
                                          MealTimeHelper().getMealName(mealTitle),
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.24,
                                          ),
                                        ),
                                        Text(
                                          MealTimeHelper().getMealTime(mealTitle),
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF252525),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.10,
                                            letterSpacing: -0.72,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      ...List.generate(items.length, (idx) {
                                        final it = items[idx];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            foodItemCard(index: idx+1, foodName: it.mealName, foodScale: it.mealValues['foodScale'], foodCalories: it.mealValues['foodCalories']),
                                            const SizedBox(height: 20),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                          ),
                          SizedBox(height: 50,)
                        ],
                      ),
                    ),
                  ),
                ),


              ],
            );
          },
        ),
      ),
    );
  }


   Widget foodItemCard({required int index,required String foodName, required String foodScale,required String foodCalories}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            index.toString(),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.26,
              letterSpacing: -0.30,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.26,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  foodScale,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$foodCalories kcal",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF535359),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
   }
}
