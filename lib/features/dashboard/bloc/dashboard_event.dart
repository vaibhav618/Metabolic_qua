// lib/features/dashboard/bloc/dashboard_event.dart
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

abstract class DashboardEvent {}

/// 🔹 Load dashboard by email only
class DashboardInitialized extends DashboardEvent {
  final String email;
  DashboardInitialized(this.email);
}

/// 🔹 Refresh dashboard (also by email)
class RefreshDashboard extends DashboardEvent {
  final String email;
  RefreshDashboard(this.email);
}

class RequestDietitianLink extends DashboardEvent {
  final ClientProfileModel clientProfileModel;
  final String dietitianId; // RespyrD02 etc.

  RequestDietitianLink({
    required this.clientProfileModel,
    required this.dietitianId,
  });
}

class CheckDietitianLinkStatus extends DashboardEvent {
  final String profileId;
  CheckDietitianLinkStatus(this.profileId);
}
