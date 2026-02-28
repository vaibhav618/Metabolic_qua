import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/generating_result_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/repositories/diet_plan_repository.dart';

abstract class DashboardState {
  final ClientProfileModel? clientProfileModel;
  final bool isLoading;
  final String? errorText;

  const DashboardState({
    this.clientProfileModel,
    this.isLoading = false,
    this.errorText,
  });
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super(isLoading: false);
}

class DashboardLoading extends DashboardState {
  const DashboardLoading() : super(isLoading: true);
}

class DashboardReady extends DashboardState {
  final DietitianDetailModel? dietitianDetailModel;
  final CategorizedPlans? categorizedPlans;
  final GeneratingResultModel? todayResult;
  final Map<String, dynamic>? todayDietData;
  final String? plansError;
  final String? todayDietError;

  /// 🔥 Link status fields
  final bool isCheckingLinkStatus;
  final String? dietitianLinkStatus;          // PENDING / ACCEPTED / REJECTED / NOT_REQUESTED
  final String? dietitianLinkStatusError;
  final Map<String, dynamic>? dietitianLinkData; // full JSON "data" from API

  const DashboardReady(
      ClientProfileModel clientProfileModel, {
        this.dietitianDetailModel,
        this.categorizedPlans,
        this.todayResult,
        this.todayDietData,
        this.plansError,
        this.todayDietError,
        this.isCheckingLinkStatus = false,
        this.dietitianLinkStatus,
        this.dietitianLinkStatusError,
        this.dietitianLinkData,
      }) : super(
    clientProfileModel: clientProfileModel,
    isLoading: false,
  );

  /// 🔁 copyWith used by Bloc to update only some fields
  DashboardReady copyWith({
    ClientProfileModel? clientProfileModel,
    DietitianDetailModel? dietitianDetailModel,
    CategorizedPlans? categorizedPlans,
    GeneratingResultModel? todayResult,
    Map<String, dynamic>? todayDietData,
    String? plansError,
    String? todayDietError,
    bool? isCheckingLinkStatus,
    String? dietitianLinkStatus,
    String? dietitianLinkStatusError,
    Map<String, dynamic>? dietitianLinkData,
  }) {
    return DashboardReady(
      clientProfileModel ?? this.clientProfileModel!,
      dietitianDetailModel: dietitianDetailModel ?? this.dietitianDetailModel,
      categorizedPlans: categorizedPlans ?? this.categorizedPlans,
      todayResult: todayResult ?? this.todayResult,
      todayDietData: todayDietData ?? this.todayDietData,
      plansError: plansError ?? this.plansError,
      todayDietError: todayDietError ?? this.todayDietError,
      isCheckingLinkStatus:
      isCheckingLinkStatus ?? this.isCheckingLinkStatus,
      dietitianLinkStatus:
      dietitianLinkStatus ?? this.dietitianLinkStatus,
      dietitianLinkStatusError:
      dietitianLinkStatusError ?? this.dietitianLinkStatusError,
      dietitianLinkData: dietitianLinkData ?? this.dietitianLinkData,
    );
  }
}

class DashboardError extends DashboardState {
  const DashboardError(
      String errorText, {
        ClientProfileModel? clientProfileModel,
      }) : super(
    errorText: errorText,
    clientProfileModel: clientProfileModel,
    isLoading: false,
  );
}
