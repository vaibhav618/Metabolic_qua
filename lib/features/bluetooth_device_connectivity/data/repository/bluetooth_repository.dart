import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/model/bluetooth_device_model.dart';

abstract class BluetoothRepository {
  Stream<List<BluetoothDeviceModel>> scan({Duration? timeout});
  Future<void> stopScan();

  Future<void> connectById(String id);
  Future<void> disconnect();

  bool get isConnected;

  Stream<bool> connectionStatusStream();
  Stream<String> receivedDataStream();
  Stream<bool> deviceReadyStream();

  Future<String?> getAlreadyConnectedDeviceId();

  Future<void> sendData(String data);

  // ✅ NEW: must be called before scanning (Android permissions + iOS readiness)
  Future<void> ensureScanPrerequisites();
}
