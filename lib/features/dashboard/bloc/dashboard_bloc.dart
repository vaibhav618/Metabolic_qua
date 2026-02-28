// lib/features/dashboard/bloc/dashboard_bloc.dart

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/repositories/diet_plan_repository.dart';
import 'package:respyr_dietitian/client-dashboard/data/services/diet_plan_service.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_repository.dart';
import 'package:respyr_dietitian/client-dashboard/today_result/today_test_data_api_service.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';

import '../../../client-dashboard/extras/get_today_key.dart';
import '../../client_login/data/services/check_profile_client.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DietitianRepository dietitianRepository;
  final DietPlanRepository dietPlanRepository;
  final TodayTestDataRepository todayTestDataRepository;

  DashboardBloc({
    DietitianRepository? dietitianRepository,
    DietPlanRepository? dietPlanRepository,
    TodayTestDataRepository? todayTestDataRepository,
  })  : dietitianRepository = dietitianRepository ?? DietitianRepository(),
        dietPlanRepository =
            dietPlanRepository ?? DietPlanRepository(DietPlanService()),
        todayTestDataRepository =
            todayTestDataRepository ??
                TodayTestDataRepository(TodayTestDataApiService()),
        super(const DashboardInitial()) {
    on<DashboardInitialized>(_onLoadDashboard);
    on<RefreshDashboard>(_onLoadDashboard);
    on<CheckDietitianLinkStatus>(_onCheckDietitianLinkStatus);
    // (optional) on<RequestDietitianLink>(_onRequestDietitianLink);
  }

  // ----------------------------------------------------
  // 🔁 Fetch client profile from server using email only
  //     phone_no is always "NA"
  // ----------------------------------------------------
  Future<ClientProfileModel> _fetchClientProfileByEmail(String email) async {
    final result = await checkClientProfile(userEmail: email); // phoneNo = "NA"

    if (result == null) {
      throw Exception("Client profile not found for email $email");
    }

    return result;
  }

  // ----------------------------------------------------
  // COMMON DASHBOARD LOADER (for init + refresh)
  // ----------------------------------------------------
  Future<void> _onLoadDashboard(
      DashboardEvent event,
      Emitter<DashboardState> emit,
      ) async {
    // 1️⃣ Get email from event
    late final String email;

    if (event is DashboardInitialized) {
      email = event.email;
    } else if (event is RefreshDashboard) {
      email = event.email;
    } else {
      // Should not happen for other events
      return;
    }

    emit(const DashboardLoading());

    try {
      // 2️⃣ Always fetch profile from server using email
      final client = await _fetchClientProfileByEmail(email);

      // 3️⃣ TODAY TEST RESULT
      GeneratingResultModel? todayResult;
      try {
        todayResult = await todayTestDataRepository.fetchDay(
          profileId: client.profileId.toString(),
          dietitianId: client.dietitianId,
        );
      } catch (_) {
        todayResult = null;
      }

      // 4️⃣ DIETITIAN + PLANS (if assigned)
      DietitianDetailModel? dietitian;
      CategorizedPlans? plans;
      String? plansError;
      Map<String, dynamic>? todayDietData;
      String? todayDietError;

      final dietitianId = client.dietitianId;
      final hasDietitianAssigned =
          dietitianId.isNotEmpty && dietitianId != "NA";

      if (hasDietitianAssigned) {
        try {
          dietitian = await dietitianRepository.fetchDietitian(dietitianId);
        } catch (_) {
          dietitian = null;
        }

        if (dietitian != null) {
          try {
            plans = await dietPlanRepository.getPlans(
              dietitianId: dietitianId,
              clientId: client.profileId.toString(),
            );
          } catch (e) {
            plansError = "Failed to fetch plans: ${e.toString()}";
          }

          if (plans != null && plans.active.isNotEmpty) {
            final activePlan = plans.active.first;
            try {
              todayDietData = await _fetchTodayDiet(
                dietitianId: dietitianId,
                profileId: client.profileId.toString(),
                dietPlanId: activePlan.id.toString(),
              );
            } catch (e) {
              todayDietData = null;
              todayDietError = e.toString();
            }
          }
        }
      }

      // 5️⃣ Final ready state
      emit(
        DashboardReady(
          client,
          dietitianDetailModel: dietitian,
          categorizedPlans: plans,
          todayResult: todayResult,
          todayDietData: todayDietData,
          plansError: plansError,
          todayDietError: todayDietError,
        ),
      );
    } catch (e) {
      emit(
        DashboardError(
          "Dashboard flow failed: ${e.toString()}",
        ),
      );
    }
  }

  // ----------------------------------------------------
  // 🔥 Check dietitian link status via API
  // DOES NOT leave DashboardReady
  // ----------------------------------------------------
  Future<void> _onCheckDietitianLinkStatus(
      CheckDietitianLinkStatus event,
      Emitter<DashboardState> emit,
      ) async {
    final current = state;

    if (current is! DashboardReady) return;

    final ready = current;

    // 1) Set loader on button
    emit(
      ready.copyWith(
        isCheckingLinkStatus: true,
        dietitianLinkStatusError: null,
      ),
    );

    try {
      final uri = Uri.parse(
        "https://humorstech.com/dietitian/api/app/get_dietitian_link_status.php",
      );

      final body = jsonEncode({
        "profile_id": event.profileId,
      });

      final res = await http.post(
        uri,
        headers: const {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      if (res.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      final success = decoded["success"] == true;
      final statusRaw = decoded["status"];
      final dataRaw = decoded["data"];

      String finalStatus;
      Map<String, dynamic>? finalData;

      if (success && statusRaw is String && statusRaw.isNotEmpty) {
        finalStatus = statusRaw.toUpperCase().trim();

        if (dataRaw is Map<String, dynamic>) {
          finalData = Map<String, dynamic>.from(dataRaw);
        }
      } else if (!success && decoded["error_code"] == "NOT_FOUND") {
        finalStatus = "NOT_REQUESTED";
        finalData = null;
      } else {
        final msg = decoded["message"]?.toString() ?? "Unknown error";
        throw Exception(msg);
      }

      // 2) Apply final status + full data, remove loader
      emit(
        ready.copyWith(
          dietitianLinkStatus: finalStatus,
          dietitianLinkData: finalData,
          isCheckingLinkStatus: false,
          dietitianLinkStatusError: null,
        ),
      );
    } catch (e) {
      // 3) Keep dashboard as-is, only set error + stop loader
      emit(
        ready.copyWith(
          isCheckingLinkStatus: false,
          dietitianLinkStatusError: e.toString(),
        ),
      );
    }
  }

  // ----------------------------------------------------
  // PRIVATE: fetch today's diet JSON
  // ----------------------------------------------------
  Future<Map<String, dynamic>> _fetchTodayDiet({
    required String dietitianId,
    required String profileId,
    required String dietPlanId,
  }) async {
    final body = jsonEncode({
      'login_id': dietitianId,
      'profile_id': profileId,
      'diet_plan_id': dietPlanId,
    });

    final res = await http.post(
      Uri.parse("https://humorstech.com/dietitian/api/app/get_diet_plan.php"),
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) {
      throw Exception('Empty response body');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response shape');
    }

    final dataList = decoded['data'] as List? ?? [];
    if (dataList.isEmpty) {
      throw Exception('No data in response');
    }

    final first = dataList.first as Map<String, dynamic>;
    final dietJson = (first['diet_json'] ?? {}) as Map<String, dynamic>;

    final todayKey = TodayKey().todayKey();
    final today = (dietJson[todayKey] ?? {}) as Map<String, dynamic>;

    if (today.isEmpty && dietJson.isNotEmpty) {
      final keys =
      dietJson.keys.map((e) => e.toString().toLowerCase()).toList();
      if (keys.length == 1) {
        final k = keys.first;
        return {
          'dayKey': k,
          'totals': dietJson[k]?['totals'] ?? const {},
          'meals': dietJson[k]?['meals'] ?? const [],
        };
      }
    }

    return {
      'dayKey': todayKey,
      'totals': today['totals'] ?? const {},
      'meals': today['meals'] ?? const [],
    };
  }
}
