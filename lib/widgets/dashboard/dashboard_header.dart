import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../common/custom_card.dart';

/// Reusable dashboard hero header displaying user identity, institutional affiliation,
/// and active translation direction based on user role.
class DashboardHeader extends StatelessWidget {
  final UserProfile profile;

  const DashboardHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isTeacher = profile.role == UserRole.teacher;
    final primaryColor = isTeacher ? AppColors.primaryLavender : AppColors.secondaryBlue;
    final containerColor = isTeacher ? AppColors.lavenderLight : AppColors.blueLight;
    final darkTextColor = isTeacher ? AppColors.lavenderDark : AppColors.blueDark;

    return CustomCard(
      backgroundColor: containerColor,
      borderColor: primaryColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryColor,
                child: Icon(
                  isTeacher ? Icons.school_rounded : Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${profile.fullName}!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.schoolName} • ${profile.grade}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.charcoalMuted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.whiteCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 16,
                  color: darkTextColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${profile.role.displayName} Mode: ${profile.translationDirectionLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: darkTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
