import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BleLocalDb {
  static final BleLocalDb _i = BleLocalDb._();
  BleLocalDb._();
  factory BleLocalDb() => _i;

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, "respyr_ble.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE ble_last_device(
            dietitian_id TEXT NOT NULL,
            profile_id   TEXT NOT NULL,
            device_id    TEXT NOT NULL,
            updated_at   INTEGER NOT NULL,
            PRIMARY KEY (dietitian_id, profile_id)
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> saveLastDevice({
    required String dietitianId,
    required String profileId,
    required String deviceId,
  }) async {
    final db = await _open();
    await db.insert(
      "ble_last_device",
      {
        "dietitian_id": dietitianId,
        "profile_id": profileId,
        "device_id": deviceId,
        "updated_at": DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getLastDeviceId({
    required String dietitianId,
    required String profileId,
  }) async {
    final db = await _open();
    final rows = await db.query(
      "ble_last_device",
      columns: ["device_id"],
      where: "dietitian_id=? AND profile_id=?",
      whereArgs: [dietitianId, profileId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first["device_id"] as String?;
  }

  Future<void> clearLastDevice({
    required String dietitianId,
    required String profileId,
  }) async {
    final db = await _open();
    await db.delete(
      "ble_last_device",
      where: "dietitian_id=? AND profile_id=?",
      whereArgs: [dietitianId, profileId],
    );
  }
}
