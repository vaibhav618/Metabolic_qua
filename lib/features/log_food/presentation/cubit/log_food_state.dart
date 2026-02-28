import 'package:respyr_dietitian/features/log_food/domain/entities/food_item.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/meal_category.dart';

class LogFoodState {
  final List<FoodItem> items;
  final MealCategory? selectedCategory;
  final bool isCategoryListOpen;
  final bool isBottomSheetOpen;

  LogFoodState({
    required this.items,
    this.selectedCategory,
    this.isCategoryListOpen = false,
    this.isBottomSheetOpen = false,
  });

  LogFoodState copyWith({
    List<FoodItem>? items,
    MealCategory? selectedCategory,
    bool? isCategoryListOpen,
    bool? isBottomSheetOpen,
  }) {
    return LogFoodState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isCategoryListOpen: isCategoryListOpen ?? this.isCategoryListOpen,
      isBottomSheetOpen: isBottomSheetOpen ?? this.isBottomSheetOpen,
    );
  }
}
