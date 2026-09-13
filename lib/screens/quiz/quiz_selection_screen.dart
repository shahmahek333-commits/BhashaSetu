import 'package:flutter/material.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/section_header.dart';
import 'quiz_play_screen.dart';

/// Quiz Hub screen for selecting quiz modes and viewing past quiz performance.
class QuizSelectionScreen extends StatefulWidget {
  final QuizRepository? repository;

  const QuizSelectionScreen({super.key, this.repository});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  late final QuizRepository _repository;
  List<QuizResult> _recentResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? QuizRepository();
    _loadRecentResults();
  }

  Future<void> _loadRecentResults() async {
    setState(() => _isLoading = true);
    try {
      final results = await _repository.getQuizResults(limit: 5);
      if (!mounted) return;
      setState(() {
        _recentResults = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _startQuiz(QuizType type) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => QuizPlayScreen(
              quizType: type,
              repository: _repository,
            ),
          ),
        )
        .then((_) => _loadRecentResults());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context).profile;
    final isTeacher = profile?.role != UserRole.student;
    final roleName = isTeacher ? 'Teacher' : 'Student';
    final direction = isTeacher ? 'Hindi → Santhali' : 'Santhali → Hindi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Quizzes'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // 1. Role & Direction Banner
            CustomCard(
              backgroundColor: AppColors.lavenderLight,
              borderColor: AppColors.primaryLavender.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTeacher ? Icons.school_rounded : Icons.child_care_rounded,
                      color: AppColors.lavenderDark,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$roleName Practice Mode',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.lavenderDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Learning direction: $direction',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Section: Quiz Formats
            const SectionHeader(
              title: 'Select Quiz Type',
              subtitle: 'Assess vocabulary, reading, and listening comprehension',
            ),

            // Mode 1: Multiple Choice
            _buildQuizTypeCard(
              title: 'Multiple Choice',
              subtitle: 'Select the correct translation from 4 options',
              icon: Icons.checklist_rounded,
              accentColor: AppColors.primaryLavender,
              bgColor: AppColors.lavenderLight,
              badge: 'Popular',
              onTap: () => _startQuiz(QuizType.multipleChoice),
            ),
            const SizedBox(height: 12),

            // Mode 2: Match the Word
            _buildQuizTypeCard(
              title: 'Match the Word',
              subtitle: 'Pair Santhali Ol Chiki vocabulary with Hindi',
              icon: Icons.compare_arrows_rounded,
              accentColor: AppColors.secondaryBlue,
              bgColor: AppColors.blueLight,
              onTap: () => _startQuiz(QuizType.matchTheWord),
            ),
            const SizedBox(height: 12),

            // Mode 3: Listen & Choose
            _buildQuizTypeCard(
              title: 'Listen & Choose',
              subtitle: 'Recognize phonetic pronunciation (Stage 9 TTS audio preview)',
              icon: Icons.hearing_rounded,
              accentColor: AppColors.tertiaryGreen,
              bgColor: AppColors.greenLight,
              badge: 'Audio Preview',
              onTap: () => _startQuiz(QuizType.listenAndChoose),
            ),
            const SizedBox(height: 12),

            // Mode 4: Image-Based Vocabulary
            _buildQuizTypeCard(
              title: 'Image-Based Vocabulary',
              subtitle: 'Visual flashcards for classroom & nature words',
              icon: Icons.image_rounded,
              accentColor: AppColors.lavenderDark,
              bgColor: AppColors.creamAlt,
              onTap: () => _startQuiz(QuizType.imageVocabulary),
            ),
            const SizedBox(height: 24),

            // 3. Section: Recent Quiz Results
            SectionHeader(
              title: 'Recent Results',
              subtitle: 'Saved locally in SQLite database',
              action: _recentResults.isNotEmpty
                  ? TextButton(
                      onPressed: () async {
                        await _repository.clearQuizResults();
                        _loadRecentResults();
                      },
                      child: const Text('Clear'),
                    )
                  : null,
            ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_recentResults.isEmpty)
              CustomCard(
                backgroundColor: AppColors.creamAlt,
                borderColor: AppColors.cardBorder,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.charcoalLight,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No quiz attempts recorded yet. Play a quiz above to see your scores saved here.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.charcoalMuted,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._recentResults.map((res) {
                final dateStr =
                    '${res.completedAt.day}/${res.completedAt.month}/${res.completedAt.year}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: res.accuracyPercent >= 70
                                ? AppColors.greenLight
                                : AppColors.blueLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            res.accuracyPercent >= 70
                                ? Icons.stars_rounded
                                : Icons.quiz_rounded,
                            color: res.accuracyPercent >= 70
                                ? AppColors.greenDark
                                : AppColors.secondaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatQuizType(res.quizType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              Text(
                                '$dateStr · ${res.userRole.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.charcoalMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${res.score}/${res.totalQuestions}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            Text(
                              '${res.accuracyPercent.round()}% acc',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: res.accuracyPercent >= 70
                                    ? AppColors.greenDark
                                    : AppColors.secondaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    String? badge,
    required VoidCallback onTap,
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.charcoalMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.charcoalLight,
            size: 22,
          ),
        ],
      ),
    );
  }

  String _formatQuizType(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'match_the_word':
        return 'Match the Word';
      case 'listen_and_choose':
        return 'Listen & Choose';
      case 'image_vocabulary':
        return 'Image Vocabulary';
      default:
        return 'Quiz Session';
    }
  }
}
