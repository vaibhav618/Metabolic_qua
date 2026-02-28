import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'dashboard_operation_event.dart';
import 'dashboard_operation_state.dart';

class DashboardOperationBloc
    extends Bloc<DashboardOperationEvent, DashboardOperationState> {
  static const String _baseUrl = 'https://humorstech.com/dietitian/api/app';

  // To support RefreshDashboardTrackingStats
  String? _lastProfileId;
  int? _lastDietPlanId;
  String? _lastDate;


  DashboardOperationBloc({
    required String profileId,
    int dietPlanId = 0,
    String? date,
  }) : super(DashboardOperationInitial()) {
    // Save last fetch params for Refresh
    _lastProfileId = profileId;
    _lastDietPlanId = dietPlanId;
    _lastDate = date;

    // Local UI operations
    on<IncrementWeight>(_onIncrementWeight);
    on<DecrementWeight>(_onDecrementWeight);
    on<IncrementWater>(_onIncrementWater);
    on<DecrementWater>(_onDecrementWater);
    on<UpdateCurrentWeight>(_onUpdateCurrentWeight);
    on<ResetWaterLocal>(_onResetWaterLocal);

    // API operations
    on<InsertWaterLog>(_onInsertWaterLog);
    on<SubmitWeightLog>(_onSubmitWeightLog);

    // Fetch dashboard stats from PHP API
    on<FetchDashboardTrackingStats>(_onFetchDashboardTrackingStats);
    on<RefreshDashboardTrackingStats>(_onRefreshDashboardTrackingStats);

    // 🚀 Trigger initial fetch as soon as bloc is created
    add(
      FetchDashboardTrackingStats(
        profileId: profileId,
        dietPlanId: dietPlanId,
        date: date,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  String _parseString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  // ---------------------------------------------------------------------------
  // LOCAL WEIGHT OPERATIONS
  // ---------------------------------------------------------------------------

  void _onIncrementWeight(
      IncrementWeight event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      emit(
        currentState.copyWith(
          currentWeight: currentState.currentWeight + 1,
          // we don't recompute progress here, it will refresh from API after save
          clearError: true,
        ),
      );
    }
  }

  void _onDecrementWeight(
      DecrementWeight event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newValue = currentState.currentWeight - 1;
      emit(
        currentState.copyWith(
          currentWeight: newValue < 0 ? 0 : newValue,
          clearError: true,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LOCAL WATER OPERATIONS
  // ---------------------------------------------------------------------------

  void _onIncrementWater(
      IncrementWater event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newWater = currentState.waterIntake + 250;
      final safeWater = newWater < 0 ? 0 : newWater;
      final target = currentState.targetWaterMl;

      final progress = target > 0
          ? double.parse(
        ((safeWater / target) * 100).clamp(0, 100).toStringAsFixed(1),
      )
          : 0.0;
      final remaining = (target - safeWater) < 0 ? 0 : (target - safeWater);

      emit(
        currentState.copyWith(
          waterIntake: safeWater.toDouble(),
          waterProgressPercent: progress,
          remainingWaterMl: remaining.toDouble(),
          lastWaterLogSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }

  void _onDecrementWater(
      DecrementWater event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final newWater = currentState.waterIntake - 250;
      final safeWater = newWater < 0 ? 0 : newWater;
      final target = currentState.targetWaterMl;

      final progress = target > 0
          ? double.parse(
        ((safeWater / target) * 100).clamp(0, 100).toStringAsFixed(1),
      )
          : 0.0;
      final remaining = (target - safeWater) < 0 ? 0 : (target - safeWater);

      emit(
        currentState.copyWith(
          waterIntake: safeWater.toDouble(),
          waterProgressPercent: progress,
          remainingWaterMl: remaining.toDouble(),
          lastWaterLogSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // INSERT WATER LOG (API)
  // ---------------------------------------------------------------------------

  Future<void> _onInsertWaterLog(
      InsertWaterLog event,
      Emitter<DashboardOperationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! DashboardOperationLoaded) return;

    emit(
      currentState.copyWith(
        isWaterLogSaving: true,
        lastWaterLogSaveSuccess: false,
        clearError: true,
      ),
    );

    try {
      final uri = Uri.parse('$_baseUrl/insert_water_log.php');

      final body = {
        "profile_id": event.profileId,
        "consumed_ml": event.consumedMl,
        "targeted_ml": event.targetedMl,
        "logged_by": event.loggedBy,
        "logged_by_id": event.loggedById,
        "notes": event.notes,
      };

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool success = data["status"] == true ||
            data["status"] == 1 ||
            data["status"] == "1";

        if (success) {
          emit(
            currentState.copyWith(
              isWaterLogSaving: false,
              lastWaterLogSaveSuccess: true,
              clearError: true,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              isWaterLogSaving: false,
              lastWaterLogSaveSuccess: false,
              errorMessage:
              data["message"]?.toString() ?? "Failed to insert water log",
            ),
          );
        }
      } else {
        emit(
          currentState.copyWith(
            isWaterLogSaving: false,
            lastWaterLogSaveSuccess: false,
            errorMessage: "Server error: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isWaterLogSaving: false,
          lastWaterLogSaveSuccess: false,
          errorMessage: "Something went wrong. Please try again.",
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SUBMIT WEIGHT LOG (API)
  // ---------------------------------------------------------------------------

  Future<void> _onSubmitWeightLog(
      SubmitWeightLog event,
      Emitter<DashboardOperationState> emit,
      ) async {
    final currentState = state;
    if (currentState is! DashboardOperationLoaded) return;

    emit(
      currentState.copyWith(
        isWeightLogSaving: true,
        lastWeightLogSaveSuccess: false,
        clearError: true,
      ),
    );

    try {
      final uri = Uri.parse('$_baseUrl/insert_weight_log.php');

      final body = {
        "profile_id": event.profileId,
        "weight_kg": event.currentWeight.toString(),
        "target_weight": event.targetWeight.toString(),
        "logged_by": event.loggedBy,
        "logged_by_id": event.loggedById,
        // For now we hard-code; if you track from API, you can pass actual type
        "weight_change_type": "weight_loss",
        "notes": event.notes ?? '',
      };

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool success = data["status"] == true ||
            data["status"] == 1 ||
            data["status"] == "1";

        if (success) {
          emit(
            currentState.copyWith(
              isWeightLogSaving: false,
              lastWeightLogSaveSuccess: true,
              clearError: true,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              isWeightLogSaving: false,
              lastWeightLogSaveSuccess: false,
              errorMessage:
              data["message"]?.toString() ?? "Failed to submit weight log",
            ),
          );
        }
      } else {
        emit(
          currentState.copyWith(
            isWeightLogSaving: false,
            lastWeightLogSaveSuccess: false,
            errorMessage: "Server error: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          isWeightLogSaving: false,
          lastWeightLogSaveSuccess: false,
          errorMessage: "Something went wrong. Please try again.",
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // RESET WATER LOCAL
  // ---------------------------------------------------------------------------

  void _onResetWaterLocal(
      ResetWaterLocal event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      final target = currentState.targetWaterMl;
      const double newWater = 0;
      final progress = target > 0
          ? double.parse(
        ((newWater / target) * 100).clamp(0, 100).toStringAsFixed(1),
      )
          : 0.0;
      final remaining = target;

      emit(
        currentState.copyWith(
          waterIntake: 0,
          waterProgressPercent: progress,
          remainingWaterMl: remaining,
          isWaterLogSaving: false,
          lastWaterLogSaveSuccess: false,
          clearError: true,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE CURRENT WEIGHT LOCALLY
  // ---------------------------------------------------------------------------

  void _onUpdateCurrentWeight(
      UpdateCurrentWeight event,
      Emitter<DashboardOperationState> emit,
      ) {
    final currentState = state;
    if (currentState is DashboardOperationLoaded) {
      emit(
        currentState.copyWith(
          currentWeight: event.newWeight,
          clearError: true,
          lastWeightLogSaveSuccess: false,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FETCH DASHBOARD TRACKING STATS (API)
  // ---------------------------------------------------------------------------

  Future<void> _onFetchDashboardTrackingStats(
      FetchDashboardTrackingStats event,
      Emitter<DashboardOperationState> emit,
      ) async {
    // Save last fetch params for Refresh
    _lastProfileId = event.profileId;
    _lastDietPlanId = event.dietPlanId;
    _lastDate = event.date;

    final previousState = state;

    try {
      final uri = Uri.parse('$_baseUrl/get_dashboard_tracking_stat.php');

      final body = <String, dynamic>{
        "profile_id": event.profileId,
        "diet_plan_id": event.dietPlanId,
      };

      if (event.date != null && event.date!.isNotEmpty) {
        body["date"] = event.date;
      }

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);

      if (decoded["status"] != true &&
          decoded["status"] != 1 &&
          decoded["status"] != "1") {
        final msg =
            decoded["message"]?.toString() ?? "Failed to fetch dashboard stats";
        throw Exception(msg);
      }

      final data = decoded["data"] ?? {};
      final weight = data["weight"] ?? {};
      final water = data["water"] ?? {};

      final currentWeight = _parseDouble(weight["current_weight"]);
      final targetedWeight = _parseDouble(weight["target_weight"]);
      final weightProgressPercent =
      _parseDouble(weight["weight_progress_percent"]);
      final recommendedAction = _parseString(
        weight["recommended_action"],
        fallback: "maintain",
      );

      final waterIntake = _parseDouble(water["consumed_ml"]);
      final targetWaterMl = _parseDouble(water["water_target_ml"]);
      final waterProgressPercent = _parseDouble(water["progress_percent"]);
      final remainingWaterMl = _parseDouble(water["remaining_ml"]);

      emit(
        DashboardOperationLoaded(
          currentWeight: currentWeight,
          targetedWeight: targetedWeight,
          weightProgressPercent: weightProgressPercent,
          recommendedAction: recommendedAction,
          waterIntake: waterIntake,
          targetWaterMl: targetWaterMl,
          waterProgressPercent: waterProgressPercent,
          remainingWaterMl: remainingWaterMl,
          isWaterLogSaving: false,
          lastWaterLogSaveSuccess: false,
          isWeightLogSaving: false,
          lastWeightLogSaveSuccess: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      // On failure, keep previous state but attach error
      if (previousState is DashboardOperationLoaded) {
        emit(
          previousState.copyWith(
            errorMessage: e.toString(),
          ),
        );
      } else {
        // If it was initial or something else, emit a safe default state with error
        emit(
          DashboardOperationLoaded(
            currentWeight: 0,
            targetedWeight: 0,
            weightProgressPercent: 0,
            recommendedAction: "maintain",
            waterIntake: 0,
            targetWaterMl: 0,
            waterProgressPercent: 0,
            remainingWaterMl: 0,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // REFRESH DASHBOARD STATS (RE-USE LAST PARAMS)
  // ---------------------------------------------------------------------------

  Future<void> _onRefreshDashboardTrackingStats(
      RefreshDashboardTrackingStats event,
      Emitter<DashboardOperationState> emit,
      ) async {
    if (_lastProfileId == null) {
      // nothing fetched yet; you can choose to do nothing
      return;
    }

    add(
      FetchDashboardTrackingStats(
        profileId: _lastProfileId!,
        dietPlanId: _lastDietPlanId ?? 0,
        date: _lastDate,
      ),
    );
  }
}
