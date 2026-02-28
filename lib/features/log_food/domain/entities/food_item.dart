import 'package:respyr_dietitian/features/log_food/domain/entities/meal_category.dart';

class FoodItem {
  final String title;
  final String? subTitle;
  final bool isSelected;
  final MealCategory category;

  FoodItem({
    required this.title,
    this.subTitle,
    this.isSelected = false,
    required this.category,
  });

  FoodItem copyWith({bool? isSelected}) {
    return FoodItem(
      title: title,
      subTitle: subTitle,
      isSelected: isSelected ?? this.isSelected,
      category: category,
    );
  }
}
