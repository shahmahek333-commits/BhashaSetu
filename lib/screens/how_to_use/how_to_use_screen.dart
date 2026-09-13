import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_card.dart';

/// Comprehensive guide explaining how to navigate and use BhashaSetu.
class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        step: '1',
        title: 'Create your profile',
        desc: 'Enter your name, school, and class to tailor your learning experience.',
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.primaryLavender,
        bgColor: AppColors.lavenderLight,
      ),
      (
        step: '2',
        title: 'Select Teacher or Student',
        desc: 'Teacher mode bridges Hindi to Santhali; Student mode bridges Santhali to Hindi.',
        icon: Icons.swap_horiz_rounded,
        color: AppColors.secondaryBlue,
        bgColor: AppColors.blueLight,
      ),
      (
        step: '3',
        title: 'Enter text or use voice',
        desc: 'Type your message into the translation box or tap the microphone to speak.',
        icon: Icons.mic_rounded,
        color: AppColors.tertiaryGreen,
        bgColor: AppColors.greenLight,
      ),
      (
        step: '4',
        title: 'Tap Translate',
        desc: 'Instantly view vernacular translations tailored for classroom understanding.',
        icon: Icons.translate_rounded,
        color: AppColors.primaryLavender,
        bgColor: AppColors.lavenderLight,
      ),
      (
        step: '5',
        title: 'Listen to the translation',
        desc: 'Tap the audio button to hear correct native pronunciation aloud.',
        icon: Icons.volume_up_rounded,
        color: AppColors.secondaryBlue,
        bgColor: AppColors.blueLight,
      ),
      (
        step: '6',
        title: 'Scan textbook content',
        desc: 'Capture primary textbook paragraphs with the camera or gallery to extract text.',
        icon: Icons.document_scanner_rounded,
        color: AppColors.tertiaryGreen,
        bgColor: AppColors.greenLight,
      ),
      (
        step: '7',
        title: 'Practice flashcards and quizzes',
        desc: 'Reinforce vocabulary with bilingual flashcards and multiple-choice quizzes.',
        icon: Icons.style_rounded,
        color: AppColors.lavenderDark,
        bgColor: AppColors.creamAlt,
      ),
      (
        step: '8',
        title: 'Check progress',
        desc: 'Monitor accuracy, words mastered, and learning streaks over time.',
        icon: Icons.insights_rounded,
        color: AppColors.primaryLavender,
        bgColor: AppColors.lavenderLight,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use BhashaSetu'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            CustomCard(
              backgroundColor: AppColors.lavenderLight,
              borderColor: AppColors.lavenderMedium.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step-by-Step Guide',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.darkCharcoal,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Follow these 8 simple steps to get the most out of BhashaSetu in your primary classroom.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.charcoalMuted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...steps.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CustomCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${item.step}: ${item.title}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkCharcoal,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.desc,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
