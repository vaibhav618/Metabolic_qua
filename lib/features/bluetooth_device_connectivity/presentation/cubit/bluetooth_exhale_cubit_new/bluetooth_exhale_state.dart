import 'package:equatable/equatable.dart';

class BluetoothExhaleState extends Equatable {
  final bool isConnected;
  final String? receivedData;
  final String? error;
  final double progress;
  final bool exhaleStarted;
  final bool inRange;
  final int holdSecondsLeft;
  final bool exhaleSuccess;
  final bool exhaleFailed;
  final bool analysisReady;
  final List<double> blowValues;
  final int inRangeDurationMs;

  final bool navigateToDashboard;
  final bool cancelTest;

  final bool startTimeoutRunning;
  final int startTimeoutLeftSec;

  const BluetoothExhaleState({
    this.isConnected = false,
    this.receivedData,
    this.error,
    this.progress = 0,
    this.exhaleStarted = false,
    this.inRange = false,
    this.holdSecondsLeft = 3,
    this.exhaleSuccess = false,
    this.exhaleFailed = false,
    this.analysisReady = false,
    this.blowValues = const [],
    this.inRangeDurationMs = 0,
    this.navigateToDashboard = false,
    this.cancelTest = false,
    this.startTimeoutRunning = false,
    this.startTimeoutLeftSec = 30,
  });

  BluetoothExhaleState copyWith({
    bool? isConnected,
    String? receivedData,
    String? error,
    double? progress,
    bool? exhaleStarted,
    bool? inRange,
    int? holdSecondsLeft,
    bool? exhaleSuccess,
    bool? exhaleFailed,
    bool? analysisReady,
    List<double>? blowValues,
    int? inRangeDurationMs,
    bool? navigateToDashboard,
    bool? cancelTest,
    bool? startTimeoutRunning,
    int? startTimeoutLeftSec,
  }) {
    return BluetoothExhaleState(
      isConnected: isConnected ?? this.isConnected,
      receivedData: receivedData ?? this.receivedData,
      error: error,
      progress: progress ?? this.progress,
      exhaleStarted: exhaleStarted ?? this.exhaleStarted,
      inRange: inRange ?? this.inRange,
      holdSecondsLeft: holdSecondsLeft ?? this.holdSecondsLeft,
      exhaleSuccess: exhaleSuccess ?? this.exhaleSuccess,
      exhaleFailed: exhaleFailed ?? this.exhaleFailed,
      analysisReady: analysisReady ?? this.analysisReady,
      blowValues: blowValues ?? this.blowValues,
      inRangeDurationMs: inRangeDurationMs ?? this.inRangeDurationMs,
      navigateToDashboard: navigateToDashboard ?? this.navigateToDashboard,
      cancelTest: cancelTest ?? this.cancelTest,
      startTimeoutRunning: startTimeoutRunning ?? this.startTimeoutRunning,
      startTimeoutLeftSec: startTimeoutLeftSec ?? this.startTimeoutLeftSec,
    );
  }

  @override
  List<Object?> get props => [
    isConnected,
    receivedData,
    error,
    progress,
    exhaleStarted,
    inRange,
    holdSecondsLeft,
    exhaleSuccess,
    exhaleFailed,
    analysisReady,
    blowValues,
    inRangeDurationMs,
    navigateToDashboard,
    cancelTest,
    startTimeoutRunning,
    startTimeoutLeftSec,
  ];
}
