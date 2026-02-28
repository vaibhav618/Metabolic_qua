import '../../../../../client-dashboard/data/model/diet_plan_strategy_model.dart';
import '../../../../../client-dashboard/data/model/dietitian_model.dart';
import '../../../../../client-dashboard/data/repositories/diet_plan_repository.dart';
import '../../../../client_profile/data/model/goals_model.dart';

class DietPlanMockData {
  final DietitianModel dietitianModel;

  // Constructor to take the model
  DietPlanMockData(this.dietitianModel);

  /// Generates a list of dummy Goals (can remain static as it's independent)
  static List<Goal> mockGoals() {
    return [
      Goal(
        name: "Weight Loss",
        currentStat: 85,
        targetStat: 75,
        unit: "kg",
      ),
      Goal(
        name: "Daily Water Intake",
        currentStat: 2,
        targetStat: 4,
        unit: "Liters",
      ),
    ];
  }

  /// Generates a single Diet Plan using the dietitian passed in constructor
  DietPlanStrategyModel mockPlan({
    int id = 99999999,
    String status = 'active',
    String title = "Transformation Phase 1",
  }) {
    return DietPlanStrategyModel(
      id: id,
      dietitianId: dietitianModel.dietitianId, // Using data from constructor
      clientId: "CLI-9988",
      planTitle: title,
      planStartDate: DateTime.now(),
      planEndDate: DateTime.now().add(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      caloriesTarget: 1800,
      proteinTarget: 140,
      fiberTarget: 30,
      carbsTarget: 200,
      fatTarget: 50,
      waterTarget: 3.5,
      goals: mockGoals(),
      approaches: ["Keto-Friendly", "Low Sodium", "High Protein"],
      status: status,
      dietitianInfo: dietitianModel, // Passing the dietitian here
      isDiabetic: false,
      testNoAssigned: 3,
      dietType: "Non-Veg",
    );
  }

  /// Generates the full CategorizedPlans object
  CategorizedPlans mockCategorizedPlans() {
    return CategorizedPlans(
      active: [
        mockPlan(id: 1, status: 'active', title: "Summer Shred"),
      ],
      completed: [
        mockPlan(id: 2, status: 'completed', title: "Initial Consultation Plan"),
      ],
      cancelled: [
        mockPlan(id: 3, status: 'cancelled', title: "Intermittent Fasting Trial"),
      ],
      other: [],
    );
  }
}