// bottom_sheets/bloc/dietitian_link_state.dart

import 'package:respyr_dietitian/features/profile_info/data/model/dietician_detail_model.dart';

class DietitianLinkState {
  final bool isLookupLoading;       // fetching dietitian info
  final bool isLinkLoading;         // sending link request
  final DietitianDetailModel? dietitian;
  final String? errorMessage;
  final String? successMessage;

  const DietitianLinkState({
    this.isLookupLoading = false,
    this.isLinkLoading = false,
    this.dietitian,
    this.errorMessage,
    this.successMessage,
  });

  factory DietitianLinkState.initial() => const DietitianLinkState();

  DietitianLinkState copyWith({
    bool? isLookupLoading,
    bool? isLinkLoading,
    DietitianDetailModel? dietitian,
    String? errorMessage,
    String? successMessage,
    bool clearDietitian = false,
  }) {
    return DietitianLinkState(
      isLookupLoading: isLookupLoading ?? this.isLookupLoading,
      isLinkLoading: isLinkLoading ?? this.isLinkLoading,
      dietitian: clearDietitian ? null : (dietitian ?? this.dietitian),
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
