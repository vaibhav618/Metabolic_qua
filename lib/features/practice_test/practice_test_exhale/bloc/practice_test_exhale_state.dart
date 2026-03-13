import 'package:equatable/equatable.dart';

class PracticeTestExhaleState extends Equatable {
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

  final bool exhaleStarted;
  final bool exhaleFinished;

  final bool exhaleSuccess;
  final bool exhaleFailed;
  final String exhaleFailReason;

  final double inBandSeconds;

  final bool exhaleNeedRunning;
  final int exhaleNeedTotalMillis;
  final int exhaleNeedStartsAtEpochMs;
  final int exhaleNeedEndsAtEpochMs;

  final bool navigateBack;

  // 🚨 NEW: Compatibility Timer Flag
  final bool showSkipButton;

  const PracticeTestExhaleState({
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
    this.exhaleStarted = false,
    this.exhaleFinished = false,
    this.exhaleSuccess = false,
    this.exhaleFailed = false,
    this.exhaleFailReason = "",
    this.inBandSeconds = 0,
    this.exhaleNeedRunning = false,
    this.exhaleNeedTotalMillis = 0,
    this.exhaleNeedStartsAtEpochMs = 0,
    this.exhaleNeedEndsAtEpochMs = 0,
    this.navigateBack = false,
    this.showSkipButton = false, // 🚨 NEW
  });

  PracticeTestExhaleState copyWith({
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
    bool? exhaleStarted,
    bool? exhaleFinished,
    bool? exhaleSuccess,
    bool? exhaleFailed,
    String? exhaleFailReason,
    double? inBandSeconds,
    bool? exhaleNeedRunning,
    int? exhaleNeedTotalMillis,
    int? exhaleNeedStartsAtEpochMs,
    int? exhaleNeedEndsAtEpochMs,
    bool? navigateBack,
    bool? showSkipButton, // 🚨 NEW
  }) {
    return PracticeTestExhaleState(
      isConnected: isConnected ?? this.isConnected,
      receivedData: receivedData ?? this.receivedData,
      error: error,
      startCounter: startCounter ?? this.startCounter,
      startCounterMillis: startCounterMillis ?? this.startCounterMillis,
      startCounterTotalMillis:
          startCounterTotalMillis ?? this.startCounterTotalMillis,
      startCounterEndsAtEpochMs:
          startCounterEndsAtEpochMs ?? this.startCounterEndsAtEpochMs,
      startCounterStarted: startCounterStarted ?? this.startCounterStarted,
      startCounterFinished: startCounterFinished ?? this.startCounterFinished,
      baseValueReceived: baseValueReceived ?? this.baseValueReceived,
      blowExhaleBaseValue: blowExhaleBaseValue ?? this.blowExhaleBaseValue,
      progress: progress ?? this.progress,
      progressSigned: progressSigned ?? this.progressSigned,
      exhaleStarted: exhaleStarted ?? this.exhaleStarted,
      exhaleFinished: exhaleFinished ?? this.exhaleFinished,
      exhaleSuccess: exhaleSuccess ?? this.exhaleSuccess,
      exhaleFailed: exhaleFailed ?? this.exhaleFailed,
      exhaleFailReason: exhaleFailReason ?? this.exhaleFailReason,
      inBandSeconds: inBandSeconds ?? this.inBandSeconds,
      exhaleNeedRunning: exhaleNeedRunning ?? this.exhaleNeedRunning,
      exhaleNeedTotalMillis:
          exhaleNeedTotalMillis ?? this.exhaleNeedTotalMillis,
      exhaleNeedStartsAtEpochMs:
          exhaleNeedStartsAtEpochMs ?? this.exhaleNeedStartsAtEpochMs,
      exhaleNeedEndsAtEpochMs:
          exhaleNeedEndsAtEpochMs ?? this.exhaleNeedEndsAtEpochMs,
      navigateBack: navigateBack ?? this.navigateBack,
      showSkipButton: showSkipButton ?? this.showSkipButton, // 🚨 NEW
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        receivedData,
        error,
        startCounter,
        startCounterMillis,
        startCounterTotalMillis,
        startCounterEndsAtEpochMs,
        startCounterStarted,
        startCounterFinished,
        baseValueReceived,
        blowExhaleBaseValue,
        progress,
        progressSigned,
        exhaleStarted,
        exhaleFinished,
        exhaleSuccess,
        exhaleFailed,
        exhaleFailReason,
        inBandSeconds,
        exhaleNeedRunning,
        exhaleNeedTotalMillis,
        exhaleNeedStartsAtEpochMs,
        exhaleNeedEndsAtEpochMs,
        navigateBack,
        showSkipButton, // 🚨 NEW
      ];
}
