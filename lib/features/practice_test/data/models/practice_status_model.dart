class PracticeStatusModel {
  final bool success;
  final String profileId;
  final bool isPracticeDone;

  PracticeStatusModel({
    required this.success,
    required this.profileId,
    required this.isPracticeDone,
  });

  factory PracticeStatusModel.fromJson(Map<String, dynamic> json) {
    return PracticeStatusModel(
      success: json['success'] ?? false,
      profileId: json['profile_id'] ?? '',
      // Handles both boolean and string "true"/"false" from PHP
      isPracticeDone: json['status'] == true || json['status'] == "true",
    );
  }
}
