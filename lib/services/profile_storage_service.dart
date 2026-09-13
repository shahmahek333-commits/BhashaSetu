import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../models/user_profile.dart';

/// Abstract storage contract for user profile persistence.
/// Enables seamless transition to SQLite in Stage 6 without UI refactoring.
abstract class ProfileStorageService {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clearProfile();
  Future<bool> hasProfile();
}

/// SQLite / Local Database implementation of ProfileStorageService for Stage 6.
/// Features transparent auto-migration from legacy SharedPreferences so no user data is lost.
class DatabaseProfileStorageService implements ProfileStorageService {
  final UserRepository _userRepository;
  final ProfileStorageService? fallbackPrefs;

  DatabaseProfileStorageService({
    UserRepository? userRepository,
    this.fallbackPrefs,
  })  : _userRepository = userRepository ?? UserRepository();

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final dbProfile = await _userRepository.getUserProfile();
      if (dbProfile != null && dbProfile.fullName.trim().isNotEmpty) {
        return dbProfile;
      }

      // Check legacy SharedPreferences for migration if configured
      if (fallbackPrefs != null) {
        final legacyProfile = await fallbackPrefs!.getProfile();
        if (legacyProfile != null && legacyProfile.fullName.trim().isNotEmpty) {
          // Migrate to database
          await _userRepository.saveUserProfile(legacyProfile);
          return legacyProfile;
        }
      }

      return null;
    } catch (_) {
      return await fallbackPrefs?.getProfile();
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _userRepository.saveUserProfile(profile);
    } catch (_) {
      // Fallback
    }
    // Mirror to fallback if available
    await fallbackPrefs?.saveProfile(profile);
  }

  @override
  Future<void> clearProfile() async {
    try {
      await _userRepository.clearUserProfile();
    } catch (_) {}
    await fallbackPrefs?.clearProfile();
  }

  @override
  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null && profile.fullName.trim().isNotEmpty;
  }
}

/// SharedPreferences implementation of ProfileStorageService.
/// Cross-platform support for Web, Android, iOS, and Desktop.
class SharedPrefsProfileStorageService implements ProfileStorageService {
  static const String _profileKey = 'bhasa_setu_user_profile';

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final jsonString = await _asyncPrefs.getString(_profileKey);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      return UserProfile.fromJson(jsonString);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _asyncPrefs.setString(_profileKey, profile.toJson());
  }

  @override
  Future<void> clearProfile() async {
    await _asyncPrefs.remove(_profileKey);
  }

  @override
  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null && profile.fullName.trim().isNotEmpty;
  }
}
