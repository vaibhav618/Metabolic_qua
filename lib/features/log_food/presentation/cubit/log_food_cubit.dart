import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/food_item.dart';
import 'package:respyr_dietitian/features/log_food/domain/entities/meal_category.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/log_food_state.dart';

import '../../data/repository/api_backed_log_food_repository.dart';

class LogFoodCubit extends Cubit<LogFoodState> {
  final ApiBackedLogFoodRepository repository;

  LogFoodCubit(this.repository)
    : super(
        LogFoodState(
          items: [],
          selectedCategory: MealCategory.wakeUp,
          isCategoryListOpen: false,
        ),
      ) {
    loadItems();
  }

  void loadItems() {
    final items = repository.getDummyFoodItem();
    emit(state.copyWith(items: items));
  }

  void toggleItem(int index) {
    final updatedItems = [...state.items];
    updatedItems[index] = updatedItems[index].copyWith(
      isSelected: !updatedItems[index].isSelected,
    );
    emit(state.copyWith(items: updatedItems));
  }

  void toggleSelectAll(MealCategory category, bool select) {
    final updatedItems =
        state.items.map((item) {
          if (item.category == category) {
            return item.copyWith(isSelected: select);
          }
          return item;
        }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void openCategory(MealCategory category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void closeCategory() {
    emit(state.copyWith(selectedCategory: null));
  }

  List<FoodItem> get itemsForSelectedCategory {
    if (state.selectedCategory == null) return [];
    return state.items
        .where((item) => item.category == state.selectedCategory)
        .toList();
  }

  void openCategoryList() {
    emit(state.copyWith(isCategoryListOpen: true));
  }

  void closeBottomSheet() {
    emit(state.copyWith(isBottomSheetOpen: false));
  }

  void toggleBottomSheet() {
    emit(state.copyWith(isBottomSheetOpen: !state.isBottomSheetOpen));
  }

  List<FoodItem> get itemForSelectedCategory {
    return state.items
        .where((item) => item.category == state.selectedCategory)
        .toList();
  }
}

extension LogFoodCubitX on LogFoodCubit {
  int selectedCount(MealCategory category) {
    return state.items
        .where((item) => item.category == category && item.isSelected)
        .length;
  }

  int totalCount(MealCategory category) {
    return state.items.where((item) => item.category == category).length;
  }
}
