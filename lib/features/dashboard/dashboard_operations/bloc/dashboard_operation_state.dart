// dashboard_operation_state.dart

abstract class DashboardOperationState {}

class DashboardOperationInitial extends DashboardOperationState {}

class DashboardOperationLoaded extends DashboardOperationState {
  // ------------------ Weight ------------------
  final double currentWeight;
  final double targetedWeight;
  final double weightProgressPercent;     // NEW ✔
  final String recommendedAction;         // NEW ✔ (weight_loss / weight_gain / maintain)

  // ------------------ Water -------------------
  final double waterIntake;               // consumed_ml
  final double targetWaterMl;             // water_target_ml
  final double waterProgressPercent;      // NEW ✔
  final double remainingWaterMl;          // NEW ✔

  // ------------------ Log Save Flags ----------
  final bool isWaterLogSaving;
  final bool lastWaterLogSaveSuccess;

  final bool isWeightLogSaving;
  final bool lastWeightLogSaveSuccess;

  final String? errorMessage;

  DashboardOperationLoaded({
    required this.currentWeight,
    required this.targetedWeight,
    required this.weightProgressPercent,
    required this.recommendedAction,
    required this.waterIntake,
    required this.targetWaterMl,
    required this.waterProgressPercent,
    required this.remainingWaterMl,
    this.isWaterLogSaving = false,
    this.lastWaterLogSaveSuccess = false,
    this.isWeightLogSaving = false,
    this.lastWeightLogSaveSuccess = false,
    this.errorMessage,
  });

  DashboardOperationLoaded copyWith({
    double? currentWeight,
    double? targetedWeight,
    double? weightProgressPercent,
    String? recommendedAction,

    double? waterIntake,
    double? targetWaterMl,
    double? waterProgressPercent,
    double? remainingWaterMl,

    bool? isWaterLogSaving,
    bool? lastWaterLogSaveSuccess,
    bool? isWeightLogSaving,
    bool? lastWeightLogSaveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardOperationLoaded(
      currentWeight: currentWeight ?? this.currentWeight,
      targetedWeight: targetedWeight ?? this.targetedWeight,
      weightProgressPercent:
      weightProgressPercent ?? this.weightProgressPercent,
      recommendedAction: recommendedAction ?? this.recommendedAction,

      waterIntake: waterIntake ?? this.waterIntake,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      waterProgressPercent:
      waterProgressPercent ?? this.waterProgressPercent,
      remainingWaterMl: remainingWaterMl ?? this.remainingWaterMl,

      isWaterLogSaving: isWaterLogSaving ?? this.isWaterLogSaving,
      lastWaterLogSaveSuccess:
      lastWaterLogSaveSuccess ?? this.lastWaterLogSaveSuccess,
      isWeightLogSaving: isWeightLogSaving ?? this.isWeightLogSaving,
      lastWeightLogSaveSuccess:
      lastWeightLogSaveSuccess ?? this.lastWeightLogSaveSuccess,

      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
