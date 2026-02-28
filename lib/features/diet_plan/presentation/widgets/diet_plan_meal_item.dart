import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../client-dashboard/extras/meal_time_helper.dart';
import '../../../log_food/data/repository/fetch_food_log_api.dart';
import '../pages/diet_plan_screen.dart';
import 'diet_plan_food_item.dart'; // for dietPlanFoodItem()

class DietPlanMealItem extends StatelessWidget {
  final String mealTitle;
  final List<Map<String, dynamic>> items;
  final Set<String> loggedKeys;
  final bool canLog;
  final DateTime logDate;
  final DateTime logDateTime;
  final String dieticianId;
  final String profileId;
  final String dietPlanId;
  final bool isExpandable;
  final Function(String key) onLoggedKeyAdd;

  const DietPlanMealItem({
    super.key,
    required this.mealTitle,
    required this.items,
    required this.loggedKeys,
    required this.canLog,
    required this.logDate,
    required this.logDateTime,
    required this.dieticianId,
    required this.profileId,
    required this.dietPlanId,
    required this.onLoggedKeyAdd,
    required this.isExpandable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
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
          childrenPadding: const EdgeInsets.only(
            top: 12,
            bottom: 12,
            left: 6,
            right: 6,
          ),

          // 👇 THIS LINE DOES THE MAGIC
          initiallyExpanded: isExpandable,

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
            ...List.generate(items.length * 2 - 1, (index) {
              // Even index → FOOD ITEM
              if (index % 2 == 0) {
                final realIndex = index ~/ 2;
                final it = items[realIndex];

                final foodName = (it['name'] ?? '').toString();
                final key = FoodLogFetchApi.makeKey(mealTitle, foodName);
                final isLogged = loggedKeys.contains(key);

                return dietPlanFoodItem(
                  index: realIndex + 1,
                  mealTitle: mealTitle,
                  foodName: foodName,
                  foodType: 'None',
                  foodScale: (it['portion'] ?? '').toString(),
                  foodCalories: (it['calories_kcal'] ?? '').toString(),
                  foodProtein: (it['protein'] ?? '').toString(),
                  foodFat: (it['fat'] ?? '').toString(),
                  foodCarbs: (it['carbs'] ?? '').toString(),
                  context: context,
                  isLogged: isLogged,
                  onLogged: () => onLoggedKeyAdd(key),
                  onAlreadyLogged: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Already logged")),
                    );
                  },
                  dieticianId: dieticianId,
                  profileId: profileId,
                  dietPlanId: dietPlanId,
                  canLog: canLog,
                  logDate: logDate,
                  mealTime: mealTitle,
                  logDateTime: logDateTime,
                );
              }

              // Odd index → SEPARATOR
              return const SizedBox(height: 20);
            }),

            SizedBox(height: 30,),
            Align(
              alignment: Alignment.centerLeft,
                child: Text("Click on food item to log food",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.20,
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
