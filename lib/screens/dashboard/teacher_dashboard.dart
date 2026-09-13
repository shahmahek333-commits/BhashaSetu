import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/dashboard/dashboard_feature_card.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../common/module_placeholder_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../language_bank/language_bank_screen.dart';
import '../ocr/scan_textbook_screen.dart';
import '../phrases/classroom_phrases_screen.dart';
import '../quiz/quiz_selection_screen.dart';
import '../voice/voice_translation_screen.dart';

/// Professional Home Dashboard for Teachers (Hindi -> Santhali instruction).
class TeacherDashboard extends StatelessWidget {
  final UserProfile profile;
  final ValueChanged<int>? onNavigateToTab;

  const TeacherDashboard({
    super.key,
    required this.profile,
    this.onNavigateToTab,
  });

  void _openModule(
    BuildContext context, {
    required String title,
    required String stage,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModulePlaceholderScreen(
          title: title,
          stage: stage,
          description: description,
          icon: icon,
          iconColor: iconColor,
          bgColor: bgColor,
        ),
      ),
    );
  }

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
            // Teacher Profile & Direction Banner
            DashboardHeader(profile: profile),
            const SizedBox(height: 20),

            // Section Header
            const SectionHeader(
              title: 'Teaching Tools',
              subtitle: 'Classroom vernacular pedagogy modules for primary education',
            ),

            // 11 Teacher Feature Cards
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
                  subtitle: 'Hindi → Santhali text translation',
                  icon: Icons.translate_rounded,
                  iconColor: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                  stageTag: 'Active',
                  onTap: () => onNavigateToTab?.call(AppConstants.tabTranslate),
                ),

                // 2. Voice Translation
                DashboardFeatureCard(
                  title: 'Voice Translation',
                  subtitle: 'Hindi speech to Santhali audio',
                  icon: Icons.mic_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
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
                  subtitle: 'OCR scanner for Hindi textbooks',
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

                // 4. Classroom Phrases
                DashboardFeatureCard(
                  title: 'Classroom Phrases',
                  subtitle: 'Everyday instructions & questions',
                  icon: Icons.record_voice_over_rounded,
                  iconColor: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ClassroomPhrasesScreen(),
                      ),
                    );
                  },
                ),

                // 5. Pronunciation Guide
                DashboardFeatureCard(
                  title: 'Pronunciation Guide',
                  subtitle: 'Phonetics & Ol Chiki script',
                  icon: Icons.volume_up_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                  stageTag: 'Stage 8',
                  onTap: () => _openModule(
                    context,
                    title: 'Pronunciation Guide',
                    stage: 'Stage 8',
                    description:
                        'Accurate phonetics and audio guide to help Hindi-speaking teachers pronounce Santhali words naturally.',
                    icon: Icons.volume_up_rounded,
                    iconColor: AppColors.secondaryBlue,
                    bgColor: AppColors.blueLight,
                  ),
                ),

                // 6. Flashcards
                DashboardFeatureCard(
                  title: 'Flashcards',
                  subtitle: 'Bilingual revision cards',
                  icon: Icons.style_rounded,
                  iconColor: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FlashcardsScreen(),
                      ),
                    );
                  },
                ),

                // 7. Quiz
                DashboardFeatureCard(
                  title: 'Quiz',
                  subtitle: 'Assess student comprehension',
                  icon: Icons.quiz_rounded,
                  iconColor: AppColors.lavenderDark,
                  containerColor: AppColors.creamAlt,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const QuizSelectionScreen(),
                      ),
                    );
                  },
                ),

                // 8. Language Bank
                DashboardFeatureCard(
                  title: 'Language Bank',
                  subtitle: 'Verified categorized words',
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                  stageTag: 'Active',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageBankScreen(),
                      ),
                    );
                  },
                ),

                // 9. Progress
                DashboardFeatureCard(
                  title: 'Progress',
                  subtitle: 'Classroom practice metrics',
                  icon: Icons.insights_rounded,
                  iconColor: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                  stageTag: 'Active',
                  onTap: () => onNavigateToTab?.call(AppConstants.tabProgress),
                ),

                // 10. How to Use
                DashboardFeatureCard(
                  title: 'How to Use',
                  subtitle: 'Teacher guide & workflow',
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                  stageTag: 'Guide',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.howToUse),
                ),

                // 11. Settings
                DashboardFeatureCard(
                  title: 'Settings',
                  subtitle: 'Profile & preferences',
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
