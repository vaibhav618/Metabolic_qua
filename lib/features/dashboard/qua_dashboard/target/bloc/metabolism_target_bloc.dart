import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/metabolism_target_repository.dart';
import 'metabolism_target_event.dart';
import 'metabolism_target_state.dart';

class MetabolismTargetBloc
    extends Bloc<MetabolismTargetEvent, MetabolismTargetState> {
  final MetabolismTargetRepository repo;

  MetabolismTargetBloc({required this.repo})
      : super(MetabolismTargetInitial()) {
    on<FetchMetabolismTarget>((event, emit) async {
      emit(MetabolismTargetLoading());
      try {
        final data = await repo.getTarget(
          age: event.age,
          gender: event.gender,
          heightCm: event.heightCm,
          currentWeight: event.currentWeight,
          diabetic: event.diabetic,
        );
        emit(MetabolismTargetLoaded(data));
      } catch (e) {
        print(e.toString());
        emit(MetabolismTargetError(e.toString()));
      }
    });
  }
}
