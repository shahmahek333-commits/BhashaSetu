import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../dashboard/student_dashboard.dart';
import '../dashboard/teacher_dashboard.dart';

/// Home view of BhashaSetu that dynamically presents the Teacher or Student dashboard
/// based strictly on the saved user role from Stage 3.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context).profile;

    final roleTitle = profile != null
        ? '${profile.role.displayName} Dashboard'
        : AppConstants.appSubtitle;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.darkCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              roleTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.charcoalMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How to Use',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.howToUse);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile & Settings',
            onPressed: () {
              onNavigateToTab?.call(AppConstants.tabProfile);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildDashboardContent(context, profile),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, UserProfile? profile) {
    if (profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: AppColors.charcoalLight,
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Profile Found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please set up your profile to open the corresponding Teacher or Student dashboard.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.profileSetup);
                },
                child: const Text('Set Up Profile Now'),
              ),
            ],
          ),
        ),
      );
    }

    if (profile.role == UserRole.student) {
      return StudentDashboard(
        profile: profile,
        onNavigateToTab: onNavigateToTab,
      );
    }

    return TeacherDashboard(
      profile: profile,
      onNavigateToTab: onNavigateToTab,
    );
  }
}
