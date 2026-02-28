import 'package:equatable/equatable.dart';

class BluetoothBreatheTubeState extends Equatable {
  final String? textError;
  final bool isBluetoothConnected;
  final bool hasInternet;
  final bool isCompleted;
  final double progress;
  final bool isDialogShown;

  const BluetoothBreatheTubeState({
    this.textError,
    this.isBluetoothConnected = false,
    this.hasInternet = false,
    this.isCompleted = false,
    this.isDialogShown = false,
    this.progress = 0.0,
  });

  BluetoothBreatheTubeState copyWith({
    String? textError,
    bool? isBluetoothConnected,
    bool? hasInternet,
    bool? isCompleted,
    bool? isDialogShown,
    double? progress,
  }) {
    return BluetoothBreatheTubeState(
      textError: textError ?? this.textError,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      hasInternet: hasInternet ?? this.hasInternet,
      isCompleted: isCompleted ?? this.isCompleted,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    textError,
    isBluetoothConnected,
    hasInternet,
    isDialogShown,
    isCompleted,
    progress,
  ];
}
