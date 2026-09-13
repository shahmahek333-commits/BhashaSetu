import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/dashboard/dashboard_feature_card.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../flashcards/flashcards_screen.dart';
import '../language_bank/language_bank_screen.dart';
import '../ocr/scan_textbook_screen.dart';
import '../quiz/quiz_selection_screen.dart';
import '../voice/voice_translation_screen.dart';

/// Professional Home Dashboard for Students (Santhali -> Hindi comprehension).
class StudentDashboard extends StatelessWidget {
  final UserProfile profile;
  final ValueChanged<int>? onNavigateToTab;

  const StudentDashboard({
    super.key,
    required this.profile,
    this.onNavigateToTab,
  });


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 500
                ? 3
                : 2;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Student Profile & Direction Banner
            DashboardHeader(profile: profile),
            const SizedBox(height: 20),

            // Section Header
            const SectionHeader(
              title: 'Learning Corner',
              subtitle: 'Fun bilingual practice and translation for primary school learners',
            ),

            // 10 Student Feature Cards
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                // 1. Translate
                DashboardFeatureCard(
                  title: 'Translate',
                  subtitle: 'Santhali → Hindi translation',
                  icon: Icons.translate_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                  stageTag: 'Active',
                  onTap: () => onNavigateToTab?.call(AppConstants.tabTranslate),
                ),

                // 2. Voice Translation
                DashboardFeatureCard(
                  title: 'Voice Translation',
                  subtitle: 'Speak in Santhali to hear Hindi',
                  icon: Icons.mic_rounded,
                  iconColor: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VoiceTranslationScreen(profile: profile),
                      ),
                    );
                  },
                ),

                // 3. Scan Textbook
                DashboardFeatureCard(
                  title: 'Scan Textbook',
                  subtitle: 'Scan textbook illustrations & words',
                  icon: Icons.document_scanner_rounded,
                  iconColor: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ScanTextbookScreen(profile: profile),
                      ),
                    );
                  },
                ),

                // 4. Learn Words
                DashboardFeatureCard(
                  title: 'Learn Words',
                  subtitle: 'Pictures, numbers, and animals',
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageBankScreen(),
                      ),
                    );
                  },
                ),

                // 5. Flashcards
                DashboardFeatureCard(
                  title: 'Flashcards',
                  subtitle: 'Flip and practice words',
                  icon: Icons.style_rounded,
                  iconColor: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FlashcardsScreen(),
                      ),
                    );
                  },
                ),

                // 6. Quiz
                DashboardFeatureCard(
                  title: 'Quiz',
                  subtitle: 'Earn points and stars',
                  icon: Icons.extension_rounded,
                  iconColor: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const QuizSelectionScreen(),
                      ),
                    );
                  },
                ),

                // 7. Language Bank
                DashboardFeatureCard(
                  title: 'Language Bank',
                  subtitle: 'Vocabulary with pronunciation',
                  icon: Icons.local_library_rounded,
                  iconColor: AppColors.lavenderDark,
                  containerColor: AppColors.creamAlt,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageBankScreen(),
                      ),
                    );
                  },
                ),

                // 8. Progress
                DashboardFeatureCard(
                  title: 'Progress',
                  subtitle: 'Your stars & streak',
                  icon: Icons.insights_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                  stageTag: 'Active',
                  onTap: () => onNavigateToTab?.call(AppConstants.tabProgress),
                ),

                // 9. How to Use
                DashboardFeatureCard(
                  title: 'How to Use',
                  subtitle: 'Student guide with pictures',
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                  stageTag: 'Guide',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.howToUse),
                ),

                // 10. Settings
                DashboardFeatureCard(
                  title: 'Settings',
                  subtitle: 'My profile & class',
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.darkCharcoal,
                  containerColor: AppColors.creamAlt,
                  stageTag: 'Profile',
                  onTap: () => onNavigateToTab?.call(AppConstants.tabProfile),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
