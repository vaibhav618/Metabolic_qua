import 'package:equatable/equatable.dart';

class BluetoothInhaleState extends Equatable {
  final bool isBluetoothConnected;
  final bool isDialogShown;

  // Start counter
  final int startCounter;
  final int startCountdownFrom;
  final bool startCounterFinished;

  // Inhale phase
  final bool inhaleStarted;
  final bool inhaleFinished;
  final double progress;
  final int perfectSamples;

  // Hold phase
  final bool holdStarted;
  final bool holdFinished;
  final int holdCounter;

  // ✅ NEW
  final String? blowExhaleBaseValue;
  final bool navigateToExhaleScreen;

  final bool improperBlow;

  const BluetoothInhaleState({
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.startCounter = 5,
    this.startCountdownFrom = 5,
    this.startCounterFinished = false,
    this.inhaleStarted = false,
    this.inhaleFinished = false,
    this.progress = 0.0,
    this.perfectSamples = 0,
    this.holdStarted = false,
    this.holdFinished = false,
    this.holdCounter = 0,
    this.blowExhaleBaseValue,
    this.navigateToExhaleScreen = false,
    this.improperBlow = false,
  });

  BluetoothInhaleState copyWith({
    bool? isBluetoothConnected,
    bool? isDialogShown,
    int? startCounter,
    int? startCountdownFrom,
    bool? startCounterFinished,
    bool? inhaleStarted,
    bool? inhaleFinished,
    double? progress,
    int? perfectSamples,
    bool? holdStarted,
    bool? holdFinished,
    int? holdCounter,
    String? blowExhaleBaseValue,
    bool? navigateToExhaleScreen,
    bool? improperBlow,
  }) {
    return BluetoothInhaleState(
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      startCounter: startCounter ?? this.startCounter,
      startCountdownFrom: startCountdownFrom ?? this.startCountdownFrom,
      startCounterFinished: startCounterFinished ?? this.startCounterFinished,
      inhaleStarted: inhaleStarted ?? this.inhaleStarted,
      inhaleFinished: inhaleFinished ?? this.inhaleFinished,
      progress: progress ?? this.progress,
      perfectSamples: perfectSamples ?? this.perfectSamples,
      holdStarted: holdStarted ?? this.holdStarted,
      holdFinished: holdFinished ?? this.holdFinished,
      holdCounter: holdCounter ?? this.holdCounter,
      blowExhaleBaseValue: blowExhaleBaseValue ?? this.blowExhaleBaseValue,
      navigateToExhaleScreen: navigateToExhaleScreen ?? this.navigateToExhaleScreen,
      improperBlow: improperBlow ?? this.improperBlow,
    );
  }

  @override
  List<Object?> get props => [
    isBluetoothConnected,
    isDialogShown,
    startCounter,
    startCountdownFrom,
    startCounterFinished,
    inhaleStarted,
    inhaleFinished,
    progress,
    perfectSamples,
    holdStarted,
    holdFinished,
    holdCounter,
    blowExhaleBaseValue,
    navigateToExhaleScreen,
    improperBlow,
  ];
}
