import 'package:equatable/equatable.dart';
import '../../../data/model/breath_setting_model.dart' show BreathingSettings;

class BluetoothCalibrationState extends Equatable {
  final String? textError;
  final bool hasInternet;
  final bool isBluetoothConnected;
  final bool isDialogShown;
  final bool navigateToInhaleScreen;
  final int completedSteps;
  final bool isMuted;
  final bool waitForInhaleCmd;
  final bool showPleaseWaitMessage;
  final bool allSignalSent;
  final bool startCalibrationTime;

  final bool isTimeStarted;
  final int remainingSeconds;
  final bool isTimeOver;
  final BreathingSettings breathingSettings;

  // ✅ NEW (for LINK_SUPERVISION_TIMEOUT / reconnect UI)
  final bool isReconnecting;
  final String? linkMessage;

  const BluetoothCalibrationState({
    this.textError,
    this.hasInternet = false,
    this.isBluetoothConnected = false,
    this.isDialogShown = false,
    this.isMuted = false,
    this.navigateToInhaleScreen = false,
    this.completedSteps = 0,
    this.waitForInhaleCmd = false,
    this.showPleaseWaitMessage = false,
    this.allSignalSent = false,
    this.isTimeStarted = false,
    this.remainingSeconds = 100,
    this.isTimeOver = false,
    required this.breathingSettings,
    this.startCalibrationTime = false,

    // ✅ NEW
    this.isReconnecting = false,
    this.linkMessage,
  });

  factory BluetoothCalibrationState.initial() {
    return BluetoothCalibrationState(
      breathingSettings: BreathingSettings.defaults(),
    );
  }

  BluetoothCalibrationState copyWith({
    String? textError,
    bool? hasInternet,
    bool? isBluetoothConnected,
    bool? isDialogShown,
    bool? navigateToInhaleScreen,
    bool? isMuted,
    int? completedSteps,
    bool? waitForInhaleCmd,
    bool? showPleaseWaitMessage,
    bool? allSignalSent,
    bool? isTimeStarted,
    int? remainingSeconds,
    bool? isTimeOver,
    BreathingSettings? breathingSettings,
    bool? startCalibrationTime,

    // ✅ NEW
    bool? isReconnecting,
    String? linkMessage,
    bool clearLinkMessage = false,
  }) {
    return BluetoothCalibrationState(
      textError: textError ?? this.textError,
      hasInternet: hasInternet ?? this.hasInternet,
      isBluetoothConnected: isBluetoothConnected ?? this.isBluetoothConnected,
      isDialogShown: isDialogShown ?? this.isDialogShown,
      navigateToInhaleScreen: navigateToInhaleScreen ?? this.navigateToInhaleScreen,
      isMuted: isMuted ?? this.isMuted,
      completedSteps: completedSteps ?? this.completedSteps,
      waitForInhaleCmd: waitForInhaleCmd ?? this.waitForInhaleCmd,
      showPleaseWaitMessage: showPleaseWaitMessage ?? this.showPleaseWaitMessage,
      allSignalSent: allSignalSent ?? this.allSignalSent,
      isTimeStarted: isTimeStarted ?? this.isTimeStarted,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimeOver: isTimeOver ?? this.isTimeOver,
      breathingSettings: breathingSettings ?? this.breathingSettings,
      startCalibrationTime: startCalibrationTime ?? this.startCalibrationTime,

      // ✅ NEW
      isReconnecting: isReconnecting ?? this.isReconnecting,
      linkMessage: clearLinkMessage ? null : (linkMessage ?? this.linkMessage),
    );
  }

  @override
  List<Object?> get props => [
    textError,
    hasInternet,
    isBluetoothConnected,
    isDialogShown,
    navigateToInhaleScreen,
    isMuted,
    completedSteps,
    waitForInhaleCmd,
    showPleaseWaitMessage,
    allSignalSent,
    isTimeStarted,
    remainingSeconds,
    isTimeOver,
    breathingSettings,
    startCalibrationTime,

    // ✅ NEW
    isReconnecting,
    linkMessage,
  ];
}