import 'package:equatable/equatable.dart';

enum ActiveDialog { none, disconnect, timeout, improper }

class BluetoothExhaleState extends Equatable {
  final double progress;
  final int secondsRemaining;
  final bool isConnected;
  final double? thresholdPercentage;
  final String? textError;
  final bool exhaleComplete;
  final bool exhaleImproper;
  final bool exhaleSessionTimeout;
  final ActiveDialog activeDialog;

  const BluetoothExhaleState({
    this.progress = 0.0,
    this.secondsRemaining = 30,
    this.isConnected = false,
    this.thresholdPercentage,
    this.textError,
    this.exhaleComplete = false,
    this.exhaleImproper = false,
    this.exhaleSessionTimeout = false,
    this.activeDialog = ActiveDialog.none,
  });

  BluetoothExhaleState copyWith({
    double? progress,
    int? secondsRemaining,
    bool? isConnected,
    double? thresholdPercentage,
    String? textError,
    bool? exhaleComplete,
    bool? exhaleImproper,
    bool? exhaleSessionTimeout,
    ActiveDialog? activeDialog,
  }) {
    return BluetoothExhaleState(
      progress: progress ?? this.progress,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isConnected: isConnected ?? this.isConnected,
      thresholdPercentage: thresholdPercentage ?? this.thresholdPercentage,
      textError: textError ?? this.textError,
      exhaleComplete: exhaleComplete ?? this.exhaleComplete,
      exhaleImproper: exhaleImproper ?? this.exhaleImproper,
      exhaleSessionTimeout: exhaleSessionTimeout ?? this.exhaleSessionTimeout,
      activeDialog: activeDialog ?? this.activeDialog,
    );
  }

  @override
  List<Object?> get props => [
    progress,
    secondsRemaining,
    isConnected,
    thresholdPercentage,
    textError,
    exhaleComplete,
    exhaleImproper,
    exhaleSessionTimeout,
    activeDialog,
  ];
}
