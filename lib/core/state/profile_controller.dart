import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/profile_storage_service.dart';

/// Controller that manages the active UserProfile state and notifies listeners of changes.
class ProfileController extends ChangeNotifier {
  final ProfileStorageService _storageService;

  UserProfile? _profile;
  bool _isLoading = true;

  ProfileController({ProfileStorageService? storageService})
      : _storageService = storageService ?? DatabaseProfileStorageService();

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null && _profile!.fullName.trim().isNotEmpty;

  /// Loads the profile from local storage.
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _storageService.getProfile();
    } catch (_) {
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves or updates the profile in local storage and updates runtime state.
  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _storageService.saveProfile(newProfile);
  }

  /// Clears the profile from local storage and updates state.
  Future<void> clearProfile() async {
    _profile = null;
    notifyListeners();
    await _storageService.clearProfile();
  }
}

/// InheritedNotifier providing access to ProfileController throughout the widget tree.
class ProfileScope extends InheritedNotifier<ProfileController> {
  const ProfileScope({
    super.key,
    required ProfileController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProfileController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProfileScope>();
    assert(scope != null, 'No ProfileScope found in context');
    return scope!.notifier!;
  }
}
