import '../database/app_database.dart';
import '../models/app_setting_item.dart';

/// Repository managing key-value app settings and feature flags.
class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves a setting value by key.
  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  /// Sets or updates a setting.
  Future<void> setSetting(String key, String value) async {
    final item = AppSettingItem(
      key: key,
      value: value,
      updatedAt: DateTime.now(),
    );
    await _db.insert('app_settings', item.toMap(), conflictAlgorithm: 'replace');
  }

  /// Removes a setting.
  Future<void> deleteSetting(String key) async {
    await _db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
  }
}
