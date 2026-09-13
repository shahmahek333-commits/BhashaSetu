import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/section_header.dart';
import '../flashcards/flashcards_screen.dart';
import '../language_bank/language_bank_screen.dart';
import '../phrases/classroom_phrases_screen.dart';
import '../quiz/quiz_selection_screen.dart';

/// Learn screen for BhasaSetu.
/// Houses educational pedagogy tools: Flashcards, Quizzes, Classroom Phrases, and Language Bank.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Overview Banner
            CustomCard(
              backgroundColor: AppColors.greenLight,
              borderColor: AppColors.greenMedium.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.tertiaryGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedagogy & Practice',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.greenDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bilingual learning modules structured for primary school curriculum.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.darkCharcoal,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(
              title: 'Learning Modules',
              subtitle: 'Select an activity to strengthen bilingual vocabulary',
            ),

            _buildModuleItem(
              context,
              title: 'Flashcards',
              subtitle: 'Bilingual cards with pronunciation and self-assessment',
              icon: Icons.style_rounded,
              accentColor: AppColors.primaryLavender,
              bgColor: AppColors.lavenderLight,
              stageTag: 'Active',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FlashcardsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildModuleItem(
              context,
              title: 'Interactive Quizzes',
              subtitle: 'Multiple choice, word match, and audio listening exercises',
              icon: Icons.quiz_rounded,
              accentColor: AppColors.secondaryBlue,
              bgColor: AppColors.blueLight,
              stageTag: 'Active',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const QuizSelectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildModuleItem(
              context,
              title: 'Classroom Phrases',
              subtitle: 'Everyday teacher instructions, questions, and encouragement',
              icon: Icons.forum_rounded,
              accentColor: AppColors.tertiaryGreen,
              bgColor: AppColors.greenLight,
              stageTag: 'Active',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ClassroomPhrasesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildModuleItem(
              context,
              title: 'Language Bank',
              subtitle: 'Verified categorized vocabulary across numbers, animals, & verbs',
              icon: Icons.local_library_rounded,
              accentColor: AppColors.lavenderDark,
              bgColor: AppColors.creamAlt,
              stageTag: 'Active',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LanguageBankScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildModuleItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required String stageTag,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.softCream,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        stageTag,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.charcoalMuted,
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
