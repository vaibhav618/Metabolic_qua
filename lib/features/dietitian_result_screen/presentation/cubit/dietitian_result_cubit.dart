import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_state.dart';

class DietitianResultCubit extends Cubit<DietitianResultState> {
  DietitianResultCubit() : super(const DietitianResultState());

  static const List<String> _tabs = ['Gut', 'Fat', 'Liver'];

  void changeTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void nextTab() {
    final currentIndex = _tabs.indexWhere(
      (tab) => tab.toLowerCase() == state.selectedTab.toLowerCase(),
    );
    if (currentIndex < _tabs.length - 1) {
      emit(state.copyWith(selectedTab: _tabs[currentIndex + 1]));
    }
  }

  void previousTab() {
    final currentIndex = _tabs.indexWhere(
      (tab) => tab.toLowerCase() == state.selectedTab.toLowerCase(),
    );
    if (currentIndex > 0) {
      emit(state.copyWith(selectedTab: _tabs[currentIndex - 1]));
    }
  }
}
