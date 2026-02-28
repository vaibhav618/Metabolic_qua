import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit will hold the current page index: 0, 1, or 2
class WalkthroughCubit extends Cubit<int> {
  WalkthroughCubit() : super(0); // start at page 0

  /// Go to next page (max 2)
  void nextPage() {
    if (state < 2) {
      emit(state + 1);
    }
  }

  /// Go to previous page (min 0)
  void previousPage() {
    if (state > 0) {
      emit(state - 1);
    }
  }
}
