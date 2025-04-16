import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 7, // Increment the version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      // Drop the existing devices table
      await db.execute('DROP TABLE IF EXISTS devices');

      // Recreate the devices table with the correct schema
      await db.execute('''
      CREATE TABLE devices (
        mac_id TEXT PRIMARY KEY
      )
      ''');
      await db.execute('DROP TABLE IF EXISTS wacs');

      // Recreate the wacs table with the correct schema
      await db.execute('''
      CREATE TABLE wacs (
        mac_id TEXT PRIMARY KEY,
        ip_address TEXT NOT NULL,
        is_push_required INTEGER NOT NULL
      )
      ''');
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE wacs (
      mac_id TEXT PRIMARY KEY,
      ip_address TEXT NOT NULL,
      is_push_required INTEGER NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE devices (
    mac_id TEXT PRIMARY KEY
  )
''');
    await db.execute('''
    CREATE TABLE wac_devices_mapping (
      wac_id TEXT NOT NULL,
      device_id TEXT NOT NULL
    )
  ''');
  }

  Future<int> insertWac(Map<String, dynamic> wac) async {
    final db = await database;
    return await db.insert('wacs', wac);
  }

  Future<List<Map<String, dynamic>>> getWacs() async {
    final db = await database;
    return await db.query('wacs');
  }

  Future<int> deleteAllWacs() async {
    final db = await database;
    return await db.delete('wacs');
  }

  Future<int> deleteWac(String id) async {
    final db = await database;

    // Get the device IDs associated with the WAC ID from the mapping table
    final mappings = await db.query(
      'wac_devices_mapping',
      columns: ['device_id'],
      where: 'wac_id = ?',
      whereArgs: [id],
    );

    // Extract the device IDs
    final deviceIds = mappings.map((mapping) => mapping['device_id'] as String).toList();

    // Delete the entries in the wac_devices_mapping table
    await db.delete(
      'wac_devices_mapping',
      where: 'wac_id = ?',
      whereArgs: [id],
    );

    // Delete the devices associated with the WAC ID
    if (deviceIds.isNotEmpty) {
      final ids = deviceIds.map((deviceId) => "'$deviceId'").join(', ');
      await db.rawDelete('DELETE FROM devices WHERE mac_id IN ($ids)');
    }

    // Finally, delete the WAC entry
    return await db.delete(
      'wacs',
      where: 'mac_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('devices');
    return result;
  }

  Future<int> deleteAllDevices() async {
    final db = await database;
    return await db.delete('devices');
  }

  Future<int> deleteDevice(String id) async {
    final db = await database;

    // Delete the device entry from wac_devices_mapping table
    await db.delete(
      'wac_devices_mapping',
      where: 'device_id = ?',
      whereArgs: [id],
    );

    // Delete the device entry from devices table
    return await db.delete('devices', where: 'mac_id = ?', whereArgs: [id]);
  }

  Future<int> insertDevice(Map<String, dynamic> device) async {
  final db = await database;

  // Check if the mac_id already exists
  final existingDevice = await db.query(
    'devices',
    where: 'mac_id = ?',
    whereArgs: [device['mac_id']],
  );

  if (existingDevice.isNotEmpty) {
    // If the device already exists, return 0 or handle it as needed
    print('Device with mac_id ${device['mac_id']} already exists.');
    return 0;
  }

  // Insert the new device if it doesn't exist
  return await db.insert('devices', device);
}

  Future<int> insertWacDeviceMapping(Map<String, dynamic> mapping) async {
    final db = await database;
    return await db.insert('wac_devices_mapping', mapping);
  }

   getWacDeviceMappings(String wacId) async {
    final db = await database;
  final result = await db.query(
    'wac_devices_mapping',
    columns: ['device_id'], // Only fetch the device_id column
    where: 'wac_id = ?',
    whereArgs: [wacId],
  );

  // Explicitly map the result to a List<String>
  return result.map((mapping) => mapping['device_id'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getDevicesByIds(
    List<String> deviceIds,
  ) async {
    final db = await database;
    final ids = deviceIds.map((id) => "'$id'").join(', ');
    return await db.rawQuery('SELECT * FROM devices WHERE mac_id IN ($ids)');
  }

  Future<int> getWacPushRequired(String wacId) async {
    final db = await database;
    final result = await db.query(
      'wacs',
      columns: ['is_push_required'],
      where: 'mac_id = ?',
      whereArgs: [wacId],
    );

    if (result.isNotEmpty) {
      return result.first['is_push_required'] as int;
    } else {
      throw Exception('WAC ID not found');
    }
  }

  Future<void> updateWacPushRequired(String wacId, int isPushRequired) async {
    final db = await database;
    await db.update(
      'wacs',
      {'is_push_required': isPushRequired},
      where: 'mac_id = ?',
      whereArgs: [wacId],
    );
  }

  Future<Map<String, dynamic>> getWacDetails(String wacId) async {
    final db = await database;
    final result = await db.query(
      'wacs',
      columns: ['ip_address'],
      where: 'mac_id = ?',
      whereArgs: [wacId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('WAC ID not found');
    }
  }
}
