import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/dietician_repository.dart';
import 'dietitian_event.dart';
import 'dietitian_state.dart';


class DietitianBloc extends Bloc<DietitianEvent, DietitianState> {
  final DietitianRepository repository;

  DietitianBloc({required this.repository}) : super(DietitianInitial()) {
    on<FetchDietitian>((event, emit) async {
      emit(DietitianLoading());
      try {
        final dietitian = await repository.fetchDietitian();
        emit(DietitianLoaded(dietitian));
      } catch (e) {
        emit(DietitianError(e.toString()));
      }
    });
  }
}
