import 'package:respyr_dietitian/features/dietitian_dashboard/data/model/dietitian_dashboard_meal_model.dart';

class DietitianDashboardRepository {
  Future<DietitianDashboardMealModel> fetchDailyMealPlan(DateTime date) async {
    await Future.delayed(Duration(milliseconds: 500));

    return DietitianDashboardMealModel(
      foodItems: [
        DietitianDashboardFoodItem(
          foodDetails: "2 ladles (60g each)",
          foodName: "Moong Dal Chilla",
          foodNumber: 1,
          kCal: 220,
        ),
        DietitianDashboardFoodItem(
          foodDetails: "1 egg (50g)",
          foodName: "Boiled Egg",
          foodNumber: 2,
          kCal: 68,
        ),
        DietitianDashboardFoodItem(
          foodDetails: "1 cup (200ml)",
          foodName: "Green Tea(No Sugar)",
          foodNumber: 3,
          kCal: 3,
        ),
      ],
      totalCalories: 291,
    );
  }
}
