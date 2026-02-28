class BluetoothDeviceModel {
  final String id;
  final String name;
  final int? rssi;

  const BluetoothDeviceModel({required this.id, required this.name, this.rssi});

  @override
  String toString() => "$name ($id) rssi=$rssi";
}
