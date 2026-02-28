import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/test_result_data_model_v2.dart';

class BluetoothGeneratingResultState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToResultScreen;

  final double? acetone;
  final double? ethanol;
  final double? hydrogen;

  final int completedSteps;
  final TestResultResponse? dietitianResult;

  final int remainingSeconds;
  final bool isTimedOut;
  final bool dataReceivedFromDevice;

  const BluetoothGeneratingResultState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.navigateToResultScreen = false,
    this.acetone,
    this.ethanol,
    this.hydrogen,
    this.completedSteps = 0,
    this.dietitianResult,

    this.remainingSeconds = 300,
    this.isTimedOut = false,
    this.dataReceivedFromDevice = false,
  });

  BluetoothGeneratingResultState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToResultScreen,
    double? acetone,
    double? ethanol,
    double? hydrogen,
    int? completedSteps,
    TestResultResponse? dietitianResult,
    int? remainingSeconds,
    bool? isTimedOut,
    bool? dataReceivedFromDevice,
  }) {
    return BluetoothGeneratingResultState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToResultScreen: navigateToResultScreen ?? this.navigateToResultScreen,
      acetone: acetone ?? this.acetone,
      ethanol: ethanol ?? this.ethanol,
      hydrogen: hydrogen ?? this.hydrogen,
      completedSteps: completedSteps ?? this.completedSteps,
      dietitianResult: dietitianResult ?? this.dietitianResult,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimedOut: isTimedOut ?? this.isTimedOut,
      dataReceivedFromDevice: dataReceivedFromDevice ?? this.dataReceivedFromDevice,
    );
  }

  @override
  List<Object?> get props => [
    textError,
    hasInternet,
    isBluetoothConnected,
    isDialogShown,
    navigateToResultScreen,
    acetone,
    ethanol,
    hydrogen,
    completedSteps,
    dietitianResult,
    remainingSeconds,
    isTimedOut,
  ];
}
