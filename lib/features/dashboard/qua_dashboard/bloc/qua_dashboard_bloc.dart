import 'package:bloc/bloc.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import '../../../client_login/data/services/check_profile_client.dart';
import '../../dashboard_operations/data/repository/dashboard_operation_repository.dart';
import 'qua_dashboard_event.dart';
import 'qua_dashboard_state.dart';

class QuaDashboardBloc extends Bloc<QuaDashboardEvent, QuaDashboardState> {
  final DietitianRepository dietitianRepository;
  final DashboardOperationRepository operationRepository;

  QuaDashboardBloc({
    DietitianRepository? dietitianRepository,
    DashboardOperationRepository? operationRepository,
  })  : dietitianRepository = dietitianRepository ?? DietitianRepository(),
        operationRepository = operationRepository ?? DashboardOperationRepository(),
        super(const QuaDashboardInitial()) {
    on<QuaLoadClientAndDietitian>(_onLoad);
    on<QuaRefreshClientAndDietitian>(_onLoad);
    on<QuaUpdateWeight>(_onUpdateWeight);
    on<QuaReset>(_onReset);
  }

  Future<void> _onLoad(QuaDashboardEvent event, Emitter<QuaDashboardState> emit) async {
    final String email = (event is QuaLoadClientAndDietitian)
        ? event.email
        : (event as QuaRefreshClientAndDietitian).email;

    // ISSUE RESOLVED: Only emit global Loading if we don't have data yet
    if (state is QuaDashboardReady) {
      emit((state as QuaDashboardReady).copyWith(isUpdating: true));
    } else {
      emit(const QuaDashboardLoading());
    }

    try {
      final client = await _fetchClientByEmail(email);
      final dietitianId = (client.dietitianId).trim();
      final hasDietitian = dietitianId.isNotEmpty && dietitianId.toUpperCase() != "NA";

      DietitianDetailModel? dietitian;
      String? dietitianError;

      if (hasDietitian) {
        try { dietitian = await dietitianRepository.fetchDietitian(dietitianId); }
        catch (e) { dietitianError = e.toString(); }
      }

      emit(QuaDashboardReady(
        client: client,
        dietitian: dietitian,
        dietitianError: dietitianError,
        isUpdating: false, // Turn off loader
      ));
    } catch (e) {
      emit(QuaDashboardError(e.toString()));
    }
  }

  Future<void> _onUpdateWeight(QuaUpdateWeight event, Emitter<QuaDashboardState> emit) async {
    if (state is QuaDashboardReady) {
      final currentState = state as QuaDashboardReady;
      emit(currentState.copyWith(isUpdating: true));
      try {
        await operationRepository.insertWeightLog(event.profileId, event.weightKg, 'dietitian', 'system', 'Update');
        // This triggers _onLoad which now handles background refresh smoothly
        add(QuaLoadClientAndDietitian(email: event.email));
      } catch (e) {
        emit(QuaDashboardError(e.toString()));
      }
    }
  }

  Future<ClientProfileModel> _fetchClientByEmail(String email) async {
    final result = await checkClientProfile(userEmail: email.trim());
    if (result == null) throw Exception("Profile not found");
    return result;
  }

  void _onReset(QuaReset event, Emitter<QuaDashboardState> emit) => emit(const QuaDashboardInitial());
}