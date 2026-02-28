import 'package:flutter_bloc/flutter_bloc.dart';
import 'walkthrough_event.dart';
import 'walkthrough_state.dart';

class WalkthroughBloc extends Bloc<WalkthroughEvent, WalkthroughState> {
  static const int _lastPageIndex = 2; // 0,1,2 → 3 pages

  WalkthroughBloc() : super(WalkthroughState.initial()) {
    on<NextPressed>(_onNextPressed);
    on<PreviousPressed>(_onPreviousPressed);
    on<SkipPressed>(_onSkipPressed);
  }

  void _onNextPressed(
      NextPressed event,
      Emitter<WalkthroughState> emit,
      ) {
    if (state.currentPage < _lastPageIndex) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    } else {
      // If already on last page and Next used as Finish (optional)
      emit(state.copyWith(isCompleted: true));
    }
  }

  void _onPreviousPressed(
      PreviousPressed event,
      Emitter<WalkthroughState> emit,
      ) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void _onSkipPressed(
      SkipPressed event,
      Emitter<WalkthroughState> emit,
      ) {
    // Directly mark walkthrough as completed
    emit(state.copyWith(isCompleted: true));
  }
}
