import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/section_header.dart';

/// Progress screen for BhashaSetu.
/// Previews the metrics dashboard for learning streak, quiz accuracy, and vocabulary.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Streak Card
            CustomCard(
              backgroundColor: AppColors.lavenderLight,
              borderColor: AppColors.lavenderMedium.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primaryLavender,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning Streak',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.lavenderDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Keep up daily bilingual practice with your primary students.',
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
              title: 'Activity Summary',
              subtitle: 'Tracked across local practice sessions',
            ),

            // Grid of Metrics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildMetricCard(
                  context,
                  title: 'Quizzes Taken',
                  value: '0',
                  icon: Icons.assignment_turned_in_rounded,
                  color: AppColors.primaryLavender,
                  containerColor: AppColors.lavenderLight,
                ),
                _buildMetricCard(
                  context,
                  title: 'Average Score',
                  value: '--%',
                  icon: Icons.grade_rounded,
                  color: AppColors.secondaryBlue,
                  containerColor: AppColors.blueLight,
                ),
                _buildMetricCard(
                  context,
                  title: 'Words Learned',
                  value: '0',
                  icon: Icons.book_rounded,
                  color: AppColors.tertiaryGreen,
                  containerColor: AppColors.greenLight,
                ),
                _buildMetricCard(
                  context,
                  title: 'Flashcards',
                  value: '0',
                  icon: Icons.flip_to_front_rounded,
                  color: AppColors.lavenderDark,
                  containerColor: AppColors.creamAlt,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Architecture Note
            CustomCard(
              backgroundColor: AppColors.creamAlt,
              borderColor: AppColors.cardBorder,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.storage_rounded,
                    color: AppColors.charcoalMuted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Live metric calculations will be attached to local SQLite storage in Stage 6.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.charcoalMuted,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color containerColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.darkCharcoal,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.charcoalMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
