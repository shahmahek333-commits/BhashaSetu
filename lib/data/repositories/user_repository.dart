import '../../models/user_profile.dart';
import '../database/app_database.dart';

/// Repository managing user profile persistence in local storage/SQLite.
class UserRepository {
  final AppDatabase _db;

  UserRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves the active user profile from local database.
  Future<UserProfile?> getUserProfile() async {
    try {
      final records = await _db.query(
        'users',
        orderBy: 'id DESC',
        limit: 1,
      );

      if (records.isEmpty) {
        return null;
      }

      final row = records.first;
      return UserProfile(
        fullName: row['full_name'] as String? ?? '',
        role: UserRole.fromString(row['role'] as String?),
        grade: row['grade'] as String? ?? 'Class 1',
        schoolName: row['school_name'] as String? ?? '',
        gender: row['gender'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Inserts or updates the active user profile.
  Future<void> saveUserProfile(UserProfile profile) async {
    final now = DateTime.now().toIso8601String();
    final existing = await _db.query('users', limit: 1);

    final values = {
      'full_name': profile.fullName,
      'role': profile.role.name,
      'grade': profile.grade,
      'school_name': profile.schoolName,
      'gender': profile.gender,
      'updated_at': now,
    };

    if (existing.isNotEmpty) {
      final id = existing.first['id'];
      await _db.update(
        'users',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      values['created_at'] = now;
      await _db.insert('users', values);
    }
  }

  /// Deletes the user profile (e.g. for sign out or testing reset).
  Future<void> clearUserProfile() async {
    await _db.delete('users');
  }

  /// Checks whether a valid profile exists.
  Future<bool> hasUserProfile() async {
    final profile = await getUserProfile();
    return profile != null && profile.fullName.trim().isNotEmpty;
  }
}
