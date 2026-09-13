import 'package:flutter/material.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/custom_card.dart';

/// Active quiz runner screen handling multiple choice, match the word,
/// listening exercises, and image vocabulary.
class QuizPlayScreen extends StatefulWidget {
  final QuizType quizType;
  final QuizRepository? repository;

  const QuizPlayScreen({
    super.key,
    required this.quizType,
    this.repository,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late final QuizRepository _repository;

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Question interaction state
  String? _selectedOption;
  bool _hasAnswered = false;

  // Running session metrics
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? QuizRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_questions.isEmpty && _isLoading) {
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCompleted = false;
      _currentIndex = 0;
      _selectedOption = null;
      _hasAnswered = false;
      _correctCount = 0;
      _wrongCount = 0;
    });

    try {
      final profile = ProfileScope.of(context).profile;
      final role = profile?.role ?? UserRole.teacher;

      final questions = await _repository.getQuestionsForRole(role, type: widget.quizType);
      if (!mounted) return;

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load questions from local database.';
        _isLoading = false;
      });
    }
  }

  void _selectOption(String option) {
    if (_hasAnswered) return;

    final currentQ = _questions[_currentIndex];
    final isCorrect = option == currentQ.correctAnswer;

    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });
  }

  Future<void> _handleNextQuestion() async {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
      });
    } else {
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final total = _questions.length;
    final accuracy = total > 0 ? (_correctCount / total) * 100.0 : 0.0;
    final profile = ProfileScope.of(context).profile;
    final roleName = profile?.role.name ?? 'teacher';

    final result = QuizResult(
      id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      quizType: widget.quizType.dbValue,
      score: _correctCount,
      totalQuestions: total,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      accuracyPercent: accuracy,
      userRole: roleName,
      completedAt: DateTime.now(),
    );

    // Save quiz result locally in SQLite
    await _repository.saveQuizResult(result);

    if (!mounted) return;
    setState(() {
      _isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForType(widget.quizType)),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLavender,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.statusError),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadQuestions,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_rounded,
                  size: 48, color: AppColors.secondaryBlue),
              const SizedBox(height: 12),
              const Text(
                'No questions available for this quiz category yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCompleted) {
      return _buildResultsView();
    }

    final currentQ = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Progress & Score Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.greenDark),
                    const SizedBox(width: 4),
                    Text(
                      'Score: $_correctCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.cardBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secondaryBlue),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Question Display Card
          CustomCard(
            backgroundColor: AppColors.whiteCard,
            borderColor: AppColors.secondaryBlue.withValues(alpha: 0.3),
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${currentQ.sourceLanguage} → ${currentQ.targetLanguage}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                    ),
                    if (widget.quizType == QuizType.listenAndChoose)
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            color: AppColors.secondaryBlue),
                        tooltip: 'Listen Audio',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Voice pronunciation TTS will be available in Stage 9.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.quizType == QuizType.imageVocabulary &&
                    currentQ.assetHint != null) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.creamAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconForAssetHint(currentQ.assetHint!),
                        size: 54,
                        color: AppColors.lavenderDark,
                      ),
                    ),
                  ),
                ],
                Text(
                  currentQ.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Option Selection Cards (4 Options)
          ...currentQ.options.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrect = option == currentQ.correctAnswer;

            Color cardBg = AppColors.whiteCard;
            Color borderColor = AppColors.cardBorder;
            Color textColor = AppColors.darkCharcoal;
            Widget? trailingIcon;

            if (_hasAnswered) {
              if (isCorrect) {
                cardBg = AppColors.greenLight;
                borderColor = AppColors.greenDark;
                textColor = AppColors.greenDark;
                trailingIcon = const Icon(Icons.check_circle_rounded,
                    color: AppColors.greenDark, size: 20);
              } else if (isSelected) {
                cardBg = AppColors.statusError.withValues(alpha: 0.12);
                borderColor = AppColors.statusError;
                textColor = AppColors.statusError;
                trailingIcon = const Icon(Icons.cancel_rounded,
                    color: AppColors.statusError, size: 20);
              }
            } else if (isSelected) {
              cardBg = AppColors.blueLight;
              borderColor = AppColors.secondaryBlue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomCard(
                backgroundColor: cardBg,
                borderColor: borderColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                onTap: () => _selectOption(option),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected || (_hasAnswered && isCorrect)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    ?trailingIcon,
                  ],
                ),
              ),
            );
          }),

          // 4. Explanation Card (Shown after answering)
          if (_hasAnswered && currentQ.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            CustomCard(
              backgroundColor: AppColors.creamAlt,
              borderColor: AppColors.cardBorder,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.statusWarning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explanation',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.statusWarning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentQ.explanation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // 5. Next / Finish Button
          if (_hasAnswered)
            FilledButton.icon(
              onPressed: _handleNextQuestion,
              icon: Icon(
                _currentIndex + 1 < _questions.length
                    ? Icons.arrow_forward_rounded
                    : Icons.check_circle_rounded,
              ),
              label: Text(
                _currentIndex + 1 < _questions.length
                    ? 'Next Question'
                    : 'Finish Quiz',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final total = _questions.length;
    final accuracy = total > 0 ? ((_correctCount / total) * 100).round() : 0;
    final isGreat = accuracy >= 70;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: CustomCard(
          backgroundColor: AppColors.whiteCard,
          borderColor: AppColors.cardBorder,
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isGreat ? AppColors.greenLight : AppColors.blueLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGreat ? Icons.military_tech_rounded : Icons.thumb_up_rounded,
                  color: isGreat ? AppColors.greenDark : AppColors.secondaryBlue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isGreat ? 'Great Job!' : 'Quiz Completed!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Result saved in offline database.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.charcoalMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultStat('Score', '$_correctCount / $total',
                      AppColors.secondaryBlue),
                  _buildResultStat('Accuracy', '$accuracy%',
                      isGreat ? AppColors.greenDark : AppColors.statusWarning),
                  _buildResultStat('Mistakes', '$_wrongCount', AppColors.statusError),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _loadQuestions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.charcoalMuted,
          ),
        ),
      ],
    );
  }

  String _titleForType(QuizType type) {
    switch (type) {
      case QuizType.multipleChoice:
        return 'Multiple Choice Quiz';
      case QuizType.matchTheWord:
        return 'Match the Word Quiz';
      case QuizType.listenAndChoose:
        return 'Listen & Choose Quiz';
      case QuizType.imageVocabulary:
        return 'Image Vocabulary Quiz';
    }
  }

  IconData _iconForAssetHint(String hint) {
    switch (hint) {
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'park_rounded':
        return Icons.park_rounded;
      default:
        return Icons.image_rounded;
    }
  }
}
