class BluetoothInhaleCubitNewState {
  final bool isConnected;
  final String receivedData;
  final String? error;

  final int startCounter;
  final int startCounterMillis;
  final int startCounterTotalMillis;
  final int startCounterEndsAtEpochMs;
  final bool startCounterStarted;
  final bool startCounterFinished;

  final bool baseValueReceived;
  final double blowExhaleBaseValue;

  final double progress;
  final double progressSigned;

  final bool inhaleStarted;
  final bool inhaleFinished;

  final bool inhaleSuccess;
  final bool inhaleFailed;
  final String inhaleFailReason;

  final double inBandSeconds;

  final bool inhaleNeedRunning;
  final int inhaleNeedTotalMillis;
  final int inhaleNeedStartsAtEpochMs;
  final int inhaleNeedEndsAtEpochMs;

  final bool holdStarted;
  final bool holdFinished;
  final double holdSeconds;

  final String holdBreathViolation;

  // ✅ NEW
  final bool navigateToDashboard;

  const BluetoothInhaleCubitNewState({
    this.isConnected = false,
    this.receivedData = "",
    this.error,
    this.startCounter = 5,
    this.startCounterMillis = 0,
    this.startCounterTotalMillis = 0,
    this.startCounterEndsAtEpochMs = 0,
    this.startCounterStarted = false,
    this.startCounterFinished = false,
    this.baseValueReceived = false,
    this.blowExhaleBaseValue = 0,
    this.progress = 0,
    this.progressSigned = 0,
    this.inhaleStarted = false,
    this.inhaleFinished = false,
    this.inhaleSuccess = false,
    this.inhaleFailed = false,
    this.inhaleFailReason = "",
    this.inBandSeconds = 0,
    this.inhaleNeedRunning = false,
    this.inhaleNeedTotalMillis = 0,
    this.inhaleNeedStartsAtEpochMs = 0,
    this.inhaleNeedEndsAtEpochMs = 0,
    this.holdStarted = false,
    this.holdFinished = false,
    this.holdSeconds = 0,
    this.holdBreathViolation = "",
    this.navigateToDashboard = false,
  });

  BluetoothInhaleCubitNewState copyWith({
    bool? isConnected,
    String? receivedData,
    String? error,
    int? startCounter,
    int? startCounterMillis,
    int? startCounterTotalMillis,
    int? startCounterEndsAtEpochMs,
    bool? startCounterStarted,
    bool? startCounterFinished,
    bool? baseValueReceived,
    double? blowExhaleBaseValue,
    double? progress,
    double? progressSigned,
    bool? inhaleStarted,
    bool? inhaleFinished,
    bool? inhaleSuccess,
    bool? inhaleFailed,
    String? inhaleFailReason,
    double? inBandSeconds,
    bool? inhaleNeedRunning,
    int? inhaleNeedTotalMillis,
    int? inhaleNeedStartsAtEpochMs,
    int? inhaleNeedEndsAtEpochMs,
    bool? holdStarted,
    bool? holdFinished,
    double? holdSeconds,
    String? holdBreathViolation,
    bool? navigateToDashboard,
  }) {
    return BluetoothInhaleCubitNewState(
      isConnected: isConnected ?? this.isConnected,
      receivedData: receivedData ?? this.receivedData,
      error: error,
      startCounter: startCounter ?? this.startCounter,
      startCounterMillis: startCounterMillis ?? this.startCounterMillis,
      startCounterTotalMillis: startCounterTotalMillis ?? this.startCounterTotalMillis,
      startCounterEndsAtEpochMs: startCounterEndsAtEpochMs ?? this.startCounterEndsAtEpochMs,
      startCounterStarted: startCounterStarted ?? this.startCounterStarted,
      startCounterFinished: startCounterFinished ?? this.startCounterFinished,
      baseValueReceived: baseValueReceived ?? this.baseValueReceived,
      blowExhaleBaseValue: blowExhaleBaseValue ?? this.blowExhaleBaseValue,
      progress: progress ?? this.progress,
      progressSigned: progressSigned ?? this.progressSigned,
      inhaleStarted: inhaleStarted ?? this.inhaleStarted,
      inhaleFinished: inhaleFinished ?? this.inhaleFinished,
      inhaleSuccess: inhaleSuccess ?? this.inhaleSuccess,
      inhaleFailed: inhaleFailed ?? this.inhaleFailed,
      inhaleFailReason: inhaleFailReason ?? this.inhaleFailReason,
      inBandSeconds: inBandSeconds ?? this.inBandSeconds,
      inhaleNeedRunning: inhaleNeedRunning ?? this.inhaleNeedRunning,
      inhaleNeedTotalMillis: inhaleNeedTotalMillis ?? this.inhaleNeedTotalMillis,
      inhaleNeedStartsAtEpochMs: inhaleNeedStartsAtEpochMs ?? this.inhaleNeedStartsAtEpochMs,
      inhaleNeedEndsAtEpochMs: inhaleNeedEndsAtEpochMs ?? this.inhaleNeedEndsAtEpochMs,
      holdStarted: holdStarted ?? this.holdStarted,
      holdFinished: holdFinished ?? this.holdFinished,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      holdBreathViolation: holdBreathViolation ?? this.holdBreathViolation,
      navigateToDashboard: navigateToDashboard ?? this.navigateToDashboard,
    );
  }
}
