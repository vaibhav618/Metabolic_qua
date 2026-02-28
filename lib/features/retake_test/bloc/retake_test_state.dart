class RetakeTestState {
  final String? selectedReason;
  final String details;
  final bool isButtonEnabled;
  final bool submitted;

  const RetakeTestState({
    this.selectedReason,
    this.details = "",
    this.isButtonEnabled = false,
    this.submitted = false,
  });

  RetakeTestState copyWith({
    String? selectedReason,
    String? details,
    bool? isButtonEnabled,
    bool? submitted,
  }) {
    return RetakeTestState(
      selectedReason: selectedReason ?? this.selectedReason,
      details: details ?? this.details,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
      submitted: submitted ?? this.submitted,
    );
  }
}
