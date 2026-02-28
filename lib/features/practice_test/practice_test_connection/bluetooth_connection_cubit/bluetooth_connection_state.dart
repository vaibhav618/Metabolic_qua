import 'package:equatable/equatable.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';

enum BluetoothConnectionStatus {
  initial,
  scanning,
  connecting,
  connected,
  disconnected,
  textError,
}

class BluetoothConnectionState extends Equatable {
  final BluetoothConnectionStatus status;
  final List<BluetoothDeviceModel> devices;
  final bool isScanning;
  final bool isConnected;
  final bool isConnecting;
  final String? lastData;
  final String? textError;
  final String? connectingDeviceId;
  final bool deviceReady;
  final bool isDeviceError;
  final bool deviceIsInhaleOrExhaleMode;

  const BluetoothConnectionState({
    this.status = BluetoothConnectionStatus.initial,
    this.devices = const [],
    this.isScanning = false,
    this.isConnected = false,
    this.isConnecting = false,
    this.lastData,
    this.textError,
    this.connectingDeviceId,
    this.deviceReady = false,
    this.isDeviceError = false,
    this.deviceIsInhaleOrExhaleMode=false,
  });

  BluetoothConnectionState copyWith({
    BluetoothConnectionStatus? status,
    List<BluetoothDeviceModel>? devices,
    bool? isScanning,
    bool? isConnected,
    bool? isConnecting,
    String? lastData,

    // Special handling
    String? textError,
    bool clearTextError = false,

    String? connectingDeviceId,
    bool clearConnectingDeviceId = false,

    bool? deviceReady,
    bool? isDeviceError,
    bool? deviceIsInhaleOrExhaleMode=false,
  }) {
    return BluetoothConnectionState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      lastData: lastData ?? this.lastData,
      textError: clearTextError ? null : (textError ?? this.textError),
      connectingDeviceId: clearConnectingDeviceId
          ? null
          : (connectingDeviceId ?? this.connectingDeviceId),
      deviceReady: deviceReady ?? this.deviceReady,
      isDeviceError: isDeviceError ?? this.isDeviceError,
      deviceIsInhaleOrExhaleMode: deviceIsInhaleOrExhaleMode ?? this.deviceIsInhaleOrExhaleMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    devices,
    isScanning,
    isConnected,
    isConnecting,
    lastData,
    textError,
    connectingDeviceId,
    deviceReady,
    isDeviceError,
    deviceIsInhaleOrExhaleMode,
  ];
}
