// features/log_food/data/repository/api_backed_log_food_repository.dart
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_category.dart';

/// Contract your LogFoodCubit already expects.
/// (If you have this interface/type somewhere else, keep it.
/// Otherwise this lightweight interface is fine.)
abstract class LogFoodRepository {
  List<FoodItem> getDummyFoodItem();
}

/// API-backed repository built from a single day’s meals.
/// It maps each meal's `time` (dietTitle) -> MealCategory and
/// keeps foods under their correct category (no mixing).
class ApiBackedLogFoodRepository implements LogFoodRepository {
  final List<FoodItem> _items;

  ApiBackedLogFoodRepository._(this._items);

  /// Build from API day's `meals` list (each meal: { time, items, ... }).
  factory ApiBackedLogFoodRepository.fromDayMeals(
      List<Map<String, dynamic>> meals,
      ) {
    final items = <FoodItem>[];

    for (final m in meals) {
      final dietTitle = (m['time'] ?? '').toString(); // e.g., "Breakfast 08:00 AM"
      final category = _mapDietTitleToCategory(dietTitle);

      final foodList = (m['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      for (final it in foodList) {
        items.add(
          FoodItem(
            title: (it['name'] ?? '').toString(),
            subTitle: (it['portion'] ?? '').toString().trim().isEmpty
                ? null
                : (it['portion']).toString(),
            category: category,
          ),
        );
      }
    }

    return ApiBackedLogFoodRepository._(items);
  }

  @override
  List<FoodItem> getDummyFoodItem() => _items;
}

/// Heuristic mapper from dietTitle/time string -> MealCategory.
/// Keeps categories stable so foods don't mix.
MealCategory _mapDietTitleToCategory(String dietTitle) {
  final t = dietTitle.toLowerCase();

  // Keyword mapping first
  if (t.contains('wake')) return MealCategory.wakeUp;
  if (t.contains('break')) return MealCategory.breakfast;
  if (t.contains('lunch')) return MealCategory.lunch;
  if (t.contains('snack') || t.contains('eve')) return MealCategory.snacks;
  if (t.contains('dinner')) return MealCategory.dinner;
  if (t.contains('sleep') || t.contains('bed')) return MealCategory.sleep;

  // Time window fallbacks (optional)
  // Morning -> breakfast
  if (RegExp(r'\b(6|7|8|9|10):\d{2}\s*am\b').hasMatch(t)) {
    return MealCategory.breakfast;
  }
  // Late morning / early afternoon -> lunch
  if (RegExp(r'\b(11|12):\d{2}\s*am\b').hasMatch(t) ||
      RegExp(r'\b(12|1|2):\d{2}\s*pm\b').hasMatch(t)) {
    return MealCategory.lunch;
  }
  // Evening -> snacks
  if (RegExp(r'\b(3|4|5|6):\d{2}\s*pm\b').hasMatch(t)) {
    return MealCategory.snacks;
  }
  // Night -> dinner
  if (RegExp(r'\b(7|8|9|10|11):\d{2}\s*pm\b').hasMatch(t)) {
    return MealCategory.dinner;
  }

  // Safe default
  return MealCategory.lunch;
}
