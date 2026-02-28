abstract class DashboardOperationEvent {}

class IncrementWeight extends DashboardOperationEvent {}

class DecrementWeight extends DashboardOperationEvent {}

class IncrementWater extends DashboardOperationEvent {}

class DecrementWater extends DashboardOperationEvent {}

class InsertWaterLog extends DashboardOperationEvent {
  final String profileId;
  final int consumedMl;
  final int targetedMl;
  final String loggedBy;
  final String loggedById;
  final String? notes;

  InsertWaterLog({
    required this.profileId,
    required this.consumedMl,
    required this.targetedMl,
    required this.loggedBy,
    required this.loggedById,
    this.notes,
  });
}

/// 🔹 Submit weight log event to handle submitting the weight data
class SubmitWeightLog extends DashboardOperationEvent {
  final String profileId;
  final double currentWeight;
  final double targetWeight;
  final String loggedBy;
  final String loggedById;
  final String? notes;

  SubmitWeightLog({
    required this.profileId,
    required this.currentWeight,
    required this.targetWeight,
    required this.loggedBy,
    required this.loggedById,
    this.notes,
  });
}

/// 🔹 Reset only local added water + flags after a successful save
class ResetWaterLocal extends DashboardOperationEvent {}

class UpdateCurrentWeight extends DashboardOperationEvent {
  final double newWeight;
  UpdateCurrentWeight({required this.newWeight});
}

/// ---------------------------------------------------------------------------
/// 🚀 NEW EVENTS FOR FETCHING DASHBOARD TRACKING STATS (weight + water)
///    This will call get_dashboard_tracking_stat.php
///    Completely independent from the above local increment/decrement events.
/// ---------------------------------------------------------------------------

/// Fetch dashboard tracking stats for a given day.
/// - If dietPlanId = 0  → API will ignore plan and auto-calc targets.
/// - date is in "YYYY-MM-DD" format. If null, backend can default to today.
class FetchDashboardTrackingStats extends DashboardOperationEvent {
  final String profileId;
  final int dietPlanId;   // pass 0 to ignore diet plan completely
  final String? date;     // optional, e.g. "2025-12-04"

  FetchDashboardTrackingStats({
    required this.profileId,
    this.dietPlanId = 0,
    this.date,
  });
}

/// Optional: a simple "refresh" event that can re-trigger the last fetch
/// (You can use this if you want pull-to-refresh etc.)
class RefreshDashboardTrackingStats extends DashboardOperationEvent {}
