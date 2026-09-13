import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/section_header.dart';
import 'profile_setup_screen.dart';

/// Profile screen for BhasaSetu.
/// Displays active user identity, role, school details, and allows editing.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileScope.of(context);
    final profile = controller.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How to Use',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.howToUse);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: profile == null
            ? _buildNoProfileView(context)
            : _buildProfileDetailsView(context, profile, controller),
      ),
    );
  }

  Widget _buildNoProfileView(BuildContext context) {
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
              'No Profile Configured',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your profile to set up your classroom translation direction.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.profileSetup);
              },
              child: const Text('Create Profile Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsView(
    BuildContext context,
    UserProfile profile,
    ProfileController controller,
  ) {
    final isTeacher = profile.role == UserRole.teacher;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        // User Identity Hero Card
        CustomCard(
          backgroundColor: isTeacher ? AppColors.lavenderLight : AppColors.blueLight,
          borderColor: isTeacher
              ? AppColors.lavenderMedium.withValues(alpha: 0.3)
              : AppColors.blueMedium.withValues(alpha: 0.3),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    isTeacher ? AppColors.primaryLavender : AppColors.secondaryBlue,
                child: Icon(
                  isTeacher ? Icons.school_rounded : Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.whiteCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (isTeacher
                                  ? AppColors.primaryLavender
                                  : AppColors.secondaryBlue)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${profile.role.displayName} Mode (${profile.translationDirectionLabel})',
                        style: TextStyle(
                          color: isTeacher
                              ? AppColors.lavenderDark
                              : AppColors.blueDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Edit Profile Action Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => const ProfileSetupScreen(isEditing: true),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile Information'),
          ),
        ),
        const SizedBox(height: 20),

        const SectionHeader(
          title: 'Institutional Affiliation',
          subtitle: 'School and classroom grade configuration',
        ),

        _buildDetailTile(
          context,
          label: 'School Name',
          value: profile.schoolName,
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 10),
        _buildDetailTile(
          context,
          label: 'Assigned Role',
          value: profile.role.displayName,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 10),
        _buildDetailTile(
          context,
          label: 'Grade / Class',
          value: profile.grade,
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 10),
        _buildDetailTile(
          context,
          label: 'Translation Direction',
          value: profile.translationDirectionLabel,
          icon: Icons.swap_horiz_rounded,
        ),
        if (profile.gender != null && profile.gender!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildDetailTile(
            context,
            label: 'Gender',
            value: profile.gender!,
            icon: Icons.person_outline_rounded,
          ),
        ],
        const SizedBox(height: 20),

        const SectionHeader(
          title: 'Support & Help',
        ),
        CustomCard(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.howToUse);
          },
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.tertiaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use BhasaSetu',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Read instructions for classroom translation & learning',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.charcoalMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.charcoalLight,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Reset Profile / Switch User Button
        Center(
          child: TextButton.icon(
            onPressed: () => _confirmResetProfile(context, controller),
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.statusError,
              size: 18,
            ),
            label: const Text(
              'Reset Profile & Return to Onboarding',
              style: TextStyle(
                color: AppColors.statusError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _confirmResetProfile(BuildContext context, ProfileController controller) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Profile?'),
          content: const Text(
            'This will clear your locally saved profile and return to the onboarding setup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusError,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.clearProfile();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.onboarding,
                    (route) => false,
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDetailTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.charcoalMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.charcoalMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.darkCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
