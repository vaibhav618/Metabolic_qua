import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/diet_plan_repository.dart';
import 'diet_plan_event.dart';
import 'diet_plan_state.dart';

class DietPlanBloc extends Bloc<DietPlanEvent, DietPlanState> {
  final DietPlanRepository repo;
  String _dietitianId = '';
  String _clientId = '';

  DietPlanBloc(this.repo) : super(const DietPlanState()) {
    on<FetchPlans>(_onFetch);
    on<RefreshPlans>(_onRefresh);
    on<ChangeFilter>((e, emit) => emit(state.copyWith(filter: e.filter)));
  }

  Future<void> _onFetch(FetchPlans e, Emitter<DietPlanState> emit) async {
    _dietitianId = e.dietitianId;
    _clientId = e.clientId;
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final categorized = await repo.getPlans(dietitianId: _dietitianId, clientId: _clientId);
      emit(state.copyWith(status: LoadStatus.success, data: categorized));
    } catch (err) {
      emit(state.copyWith(status: LoadStatus.failure, error: err.toString()));
    }
  }

  Future<void> _onRefresh(RefreshPlans e, Emitter<DietPlanState> emit) async {
    if (_dietitianId.isEmpty || _clientId.isEmpty) return;
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final categorized = await repo.getPlans(dietitianId: _dietitianId, clientId: _clientId);
      emit(state.copyWith(status: LoadStatus.success, data: categorized));
    } catch (err) {
      emit(state.copyWith(status: LoadStatus.failure, error: err.toString()));
    }
  }
}
