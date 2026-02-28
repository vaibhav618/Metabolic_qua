// bottom_sheets/bloc/dietitian_link_event.dart

abstract class DietitianLinkEvent {}

/// Step 1: User enters reference code -> fetch dietitian info
class FetchDietitianByCode extends DietitianLinkEvent {
  final String code;
  FetchDietitianByCode(this.code);
}

/// Step 2: User confirms link with that dietitian
class ConfirmDietitianLink extends DietitianLinkEvent {
  final String profileId;
  final String dietitianId;

  ConfirmDietitianLink({
    required this.profileId,
    required this.dietitianId,
  });
}

/// Step 0: Go back / refresh sheet to initial state
class ResetDietitianLinkFlow extends DietitianLinkEvent {}
