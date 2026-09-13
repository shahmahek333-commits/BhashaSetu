import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_card.dart';

/// Onboarding screen introducing BhasaSetu's purpose and pedagogy tools.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                children: [
                  // App Branding Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.lavenderLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryLavender.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primaryLavender,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'AI-Powered Vernacular Pedagogy Bridge',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.charcoalMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Bridging Hindi-medium educators and Santhali-speaking primary school learners.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.charcoalLight,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feature Cards
                  _buildHighlightCard(
                    context,
                    title: 'Bilingual Role Support',
                    description:
                        'Teacher mode delivers Hindi → Santhali instruction; Student mode supports Santhali → Hindi comprehension.',
                    icon: Icons.swap_horiz_rounded,
                    color: AppColors.primaryLavender,
                    bgColor: AppColors.lavenderLight,
                  ),
                  const SizedBox(height: 12),

                  _buildHighlightCard(
                    context,
                    title: 'Text & Voice Translation',
                    description:
                        'Translate classroom speech and text instantly with audio pronunciation to overcome language barriers.',
                    icon: Icons.mic_rounded,
                    color: AppColors.secondaryBlue,
                    bgColor: AppColors.blueLight,
                  ),
                  const SizedBox(height: 12),

                  _buildHighlightCard(
                    context,
                    title: 'Textbook Content Scanner',
                    description:
                        'Scan and extract text from primary school books with OCR for immediate vernacular translation.',
                    icon: Icons.document_scanner_rounded,
                    color: AppColors.tertiaryGreen,
                    bgColor: AppColors.greenLight,
                  ),
                  const SizedBox(height: 12),

                  _buildHighlightCard(
                    context,
                    title: 'Bilingual Vocabulary & Quizzes',
                    description:
                        'Reinforce mother-tongue education with interactive flashcards, quizzes, and classroom phrases.',
                    icon: Icons.style_rounded,
                    color: AppColors.lavenderDark,
                    bgColor: AppColors.creamAlt,
                  ),
                ],
              ),
            ),

            // Continue / Get Started Action Bar
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: AppColors.whiteCard,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder, width: 1.0),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started — Set Up Profile'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHighlightCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.charcoalMuted,
                        height: 1.35,
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
