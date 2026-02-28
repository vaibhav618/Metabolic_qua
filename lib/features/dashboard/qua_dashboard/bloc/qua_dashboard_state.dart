import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

abstract class QuaDashboardState extends Equatable {
  const QuaDashboardState();

  @override
  List<Object?> get props => [];
}

class QuaDashboardInitial extends QuaDashboardState {
  const QuaDashboardInitial();
}

class QuaDashboardLoading extends QuaDashboardState {
  const QuaDashboardLoading();
}

class QuaDashboardReady extends QuaDashboardState {
  static const Object _unset = Object();

  final ClientProfileModel client;
  final DietitianDetailModel? dietitian;
  final String? dietitianError;
  final bool isUpdating;

  /// ✅ transient message for SnackBar (weight update fail etc.)
  final String? errorMessage;

  const QuaDashboardReady({
    required this.client,
    required this.dietitian,
    this.dietitianError,
    this.isUpdating = false,
    this.errorMessage,
  });

  QuaDashboardReady copyWith({
    ClientProfileModel? client,
    DietitianDetailModel? dietitian,
    String? dietitianError,
    bool? isUpdating,

    /// ✅ use sentinel so we can explicitly clear to null
    Object? errorMessage = _unset,
  }) {
    return QuaDashboardReady(
      client: client ?? this.client,
      dietitian: dietitian ?? this.dietitian,
      dietitianError: dietitianError ?? this.dietitianError,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [client, dietitian, dietitianError, isUpdating, errorMessage];
}

class QuaDashboardError extends QuaDashboardState {
  final String message;
  const QuaDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
