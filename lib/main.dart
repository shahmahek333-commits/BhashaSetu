import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/state/profile_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_shell_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/profile_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BhasaSetuApp());
}

/// Root application widget for BhasaSetu.
/// Handles initial profile inspection, routing, and pastel Material 3 theme binding.
class BhasaSetuApp extends StatefulWidget {
  final ProfileStorageService? storageService;

  const BhasaSetuApp({super.key, this.storageService});

  @override
  State<BhasaSetuApp> createState() => _BhasaSetuAppState();
}

class _BhasaSetuAppState extends State<BhasaSetuApp> {
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController(storageService: widget.storageService);
    _profileController.loadProfile();
  }

  @override
  void didUpdateWidget(BhasaSetuApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storageService != widget.storageService) {
      _profileController.dispose();
      _profileController = ProfileController(storageService: widget.storageService);
      _profileController.loadProfile();
    }
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      controller: _profileController,
      child: ListenableBuilder(
        listenable: _profileController,
        builder: (context, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: _buildInitialScreen(),
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen() {
    if (_profileController.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.softCream,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: AppColors.primaryLavender,
                size: 52,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: AppColors.primaryLavender,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      );
    }

    if (_profileController.hasProfile) {
      return const MainShellScreen();
    }

    return const OnboardingScreen();
  }
}
