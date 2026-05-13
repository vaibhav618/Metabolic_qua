enum DeviceUpdateStatus {
  initial,
  checkingVersion,
  updateAvailable,
  upToDate,
  enteringBootloader,
  flashing,
  success,
  error
}

class DeviceUpdateState {
  final DeviceUpdateStatus status;
  final String currentVersion;
  final String latestVersion;
  final double progress; // 0.0 to 1.0 for the progress bar later
  final String? errorMessage;

  const DeviceUpdateState({
    this.status = DeviceUpdateStatus.initial,
    this.currentVersion = "",
    this.latestVersion = "",
    this.progress = 0.0,
    this.errorMessage,
  });

  DeviceUpdateState copyWith({
    DeviceUpdateStatus? status,
    String? currentVersion,
    String? latestVersion,
    double? progress,
    String? errorMessage,
  }) {
    return DeviceUpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      progress: progress ?? this.progress,
      errorMessage:
          errorMessage, // Notice we don't fall back to 'this.errorMessage' so we can clear errors
    );
  }
}
