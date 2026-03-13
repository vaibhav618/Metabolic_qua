import 'package:equatable/equatable.dart';

enum FullTestPhase {
  initial,
  inhaleCountdown, // Timer 1 (Before Inhale)
  inhaling,
  transitioning, // Inhale passed, waiting for hardware to switch
  exhaleCountdown, // Timer 2 (Before Exhale)
  exhaling,
  success
}

class PracticeFullTestState extends Equatable {
  final bool isConnected;
  final FullTestPhase phase;

  // Countdown
  final int startCounter;
  final int startCounterEndsAtEpochMs;
  final int startCounterTotalMillis;

  // Progress (used for both Inhale and Exhale)
  final double progress;
  final double progressSigned;
  final double inBandSeconds;
  final bool needRunning;

  // Errors & Navigation
  final bool isFailed;
  final String failReason;
  final bool navigateBack;

  // 🚨 NEW: Added to support the Incompatible Device Screen
  final bool showSkipButton;

  const PracticeFullTestState({
    this.isConnected = false,
    this.phase = FullTestPhase.initial,
    this.startCounter = 5,
    this.progress = 0.0,
    this.progressSigned = 0.0,
    this.inBandSeconds = 0.0,
    this.needRunning = false,
    this.isFailed = false,
    this.failReason = "",
    this.navigateBack = false,
    this.showSkipButton = false, // Initialize
    this.startCounterEndsAtEpochMs = 0, // Initialize
    this.startCounterTotalMillis = 0, // Initialize
  });

  PracticeFullTestState copyWith({
    bool? isConnected,
    FullTestPhase? phase,
    int? startCounter,
    double? progress,
    double? progressSigned,
    double? inBandSeconds,
    bool? needRunning,
    bool? isFailed,
    String? failReason,
    bool? navigateBack,
    bool? showSkipButton,
    int? startCounterEndsAtEpochMs,
    int? startCounterTotalMillis,
  }) {
    return PracticeFullTestState(
      isConnected: isConnected ?? this.isConnected,
      phase: phase ?? this.phase,
      startCounter: startCounter ?? this.startCounter,
      progress: progress ?? this.progress,
      progressSigned: progressSigned ?? this.progressSigned,
      inBandSeconds: inBandSeconds ?? this.inBandSeconds,
      needRunning: needRunning ?? this.needRunning,
      isFailed: isFailed ?? this.isFailed,
      failReason: failReason ?? this.failReason,
      navigateBack: navigateBack ?? this.navigateBack,
      showSkipButton: showSkipButton ?? this.showSkipButton,
      startCounterEndsAtEpochMs:
          startCounterEndsAtEpochMs ?? this.startCounterEndsAtEpochMs,
      startCounterTotalMillis:
          startCounterTotalMillis ?? this.startCounterTotalMillis,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        phase,
        startCounter,
        progress,
        progressSigned,
        inBandSeconds,
        needRunning,
        isFailed,
        failReason,
        navigateBack,
        showSkipButton,
        startCounterEndsAtEpochMs,
        startCounterTotalMillis,
      ];
}
