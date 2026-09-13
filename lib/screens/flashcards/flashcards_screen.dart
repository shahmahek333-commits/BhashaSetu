import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/flashcard_item.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../widgets/common/custom_card.dart';

/// Interactive Flashcards screen for vernacular vocabulary revision.
/// Features Ol Chiki script, Devanagari Hindi, English meanings, and local progress tracking.
class FlashcardsScreen extends StatefulWidget {
  final FlashcardRepository? repository;

  const FlashcardsScreen({super.key, this.repository});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late final FlashcardRepository _repository;

  List<FlashcardItem> _cards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Session progress
  int _sessionKnown = 0;
  int _sessionPracticeAgain = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FlashcardRepository();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCompleted = false;
      _currentIndex = 0;
      _isFlipped = false;
      _sessionKnown = 0;
      _sessionPracticeAgain = 0;
    });

    try {
      final cards = await _repository.getAllFlashcards();
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load flashcards from local database.';
        _isLoading = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _handleMarkOutcome({required bool isKnown}) async {
    if (_cards.isEmpty || _currentIndex >= _cards.length) return;

    final currentCard = _cards[_currentIndex];

    // Persist progress to local SQLite database
    await _repository.recordPracticeOutcome(currentCard.id, isKnown: isKnown);

    if (!mounted) return;

    setState(() {
      if (isKnown) {
        _sessionKnown++;
      } else {
        _sessionPracticeAgain++;
      }

      if (_currentIndex + 1 < _cards.length) {
        _currentIndex++;
        _isFlipped = false;
      } else {
        _isCompleted = true;
      }
    });
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _handleNext() {
    if (_currentIndex + 1 < _cards.length) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilingual Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Restart Flashcards',
            onPressed: _loadFlashcards,
          ),
        ],
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
                onPressed: _loadFlashcards,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style_rounded,
                  size: 48, color: AppColors.primaryLavender),
              const SizedBox(height: 12),
              const Text(
                'No flashcards found in local database.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadFlashcards,
                child: const Text('Load Demo Cards'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isCompleted) {
      return _buildCompletionView();
    }

    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Progress Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${_cards.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavenderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.greenDark),
                    const SizedBox(width: 4),
                    Text(
                      '$_sessionKnown Known',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryLavender),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Interactive Flashcard (Tap to Flip)
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _isFlipped
                  ? _buildCardBack(card, key: const ValueKey('back'))
                  : _buildCardFront(card, key: const ValueKey('front')),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Flip Hint
          Center(
            child: TextButton.icon(
              onPressed: _flipCard,
              icon: Icon(
                _isFlipped ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
                size: 18,
                color: AppColors.primaryLavender,
              ),
              label: Text(
                _isFlipped ? 'Tap to see Santhali front' : 'Tap to reveal Hindi meaning',
                style: const TextStyle(
                  color: AppColors.primaryLavender,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Action Buttons: "Practice Again" & "I Know"
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleMarkOutcome(isKnown: false),
                  icon: const Icon(Icons.replay_rounded, color: AppColors.statusWarning),
                  label: const Text(
                    'Practice Again',
                    style: TextStyle(
                      color: AppColors.statusWarning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.statusWarning, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleMarkOutcome(isKnown: true),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text(
                    'I Know',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tertiaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Card Navigation Controls (Previous / Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentIndex > 0 ? _handlePrevious : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Previous'),
              ),
              TextButton.icon(
                onPressed: _handleNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(FlashcardItem card, {required Key key}) {
    return CustomCard(
      key: key,
      backgroundColor: AppColors.whiteCard,
      borderColor: AppColors.primaryLavender.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(28.0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 240),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lavenderLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Santhali (Ol Chiki)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lavenderDark,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Ol Chiki script text
            Text(
              card.santhaliWord,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.pronunciation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoalMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(FlashcardItem card, {required Key key}) {
    return CustomCard(
      key: key,
      backgroundColor: AppColors.greenLight,
      borderColor: AppColors.greenMedium.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(28.0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 240),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.whiteCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Translation & Meaning',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Hindi meaning
            Text(
              card.hindiMeaning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            ),
            const SizedBox(height: 10),
            // English meaning
            Text(
              card.englishMeaning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Pronunciation: ${card.pronunciation}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.charcoalMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Audio pronunciation indicator
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              color: AppColors.greenDark,
              tooltip: 'Listen pronunciation',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice pronunciation TTS will be available in Stage 9.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView() {
    final total = _cards.length;
    final accuracy = total > 0 ? ((_sessionKnown / total) * 100).round() : 0;

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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.tertiaryGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Session Complete!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You practiced all $total vocabulary flashcards.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.charcoalMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatPill('Mastered', '$_sessionKnown', AppColors.tertiaryGreen),
                  _buildStatPill('Needs Practice', '$_sessionPracticeAgain', AppColors.statusWarning),
                  _buildStatPill('Mastery', '$accuracy%', AppColors.primaryLavender),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _loadFlashcards,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Practice Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: AppColors.primaryLavender,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
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
}
