import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/translation_history_item.dart';
import '../../data/repositories/translation_history_repository.dart';
import '../../models/translation_result.dart';
import '../../models/user_profile.dart';
import '../../services/mock_translation_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/section_header.dart';

/// Full interactive Translation Hub supporting demo translations between Hindi and Santhali.
class TranslateScreen extends StatefulWidget {
  final TranslationService? translationService;
  final TranslationHistoryRepository? historyRepository;

  const TranslateScreen({
    super.key,
    this.translationService,
    this.historyRepository,
  });

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  late final TranslationService _translationService;
  late final TranslationHistoryRepository _historyRepository;
  late final TextEditingController _inputController;

  String? _sourceLang;
  String? _targetLang;

  bool _isLoading = false;
  String? _errorMessage;
  TranslationResult? _currentResult;

  // In-memory lightweight translation history for Stage 5
  final List<TranslationResult> _history = [];

  // Demo suggestions for classroom pedagogy
  static const List<String> _hindiSuggestions = [
    'नमस्ते',
    'किताब खोलो',
    'ध्यान से सुनो',
    'बहुत अच्छा',
    'पानी',
  ];

  static const List<String> _santhaliSuggestions = [
    'ᱡᱚᱦᱟᱨ',
    'ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ',
    'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
    'ᱟᱹᱰᱤ ᱵᱷᱟᱹᱜᱤ',
    'ᱫᱟᱜ',
  ];

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService ?? const MockTranslationService();
    _historyRepository = widget.historyRepository ?? TranslationHistoryRepository();
    _inputController = TextEditingController();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final items = await _historyRepository.getRecentTranslations();
      if (!mounted) return;
      setState(() {
        _history.clear();
        _history.addAll(items.map((e) => TranslationResult(
              sourceText: e.sourceText,
              translatedText: e.translatedText,
              sourceLang: e.sourceLanguage,
              targetLang: e.targetLanguage,
              isDemo: e.isDemo,
              timestamp: e.createdAt,
              phoneticGuide: e.phoneticGuide,
            )));
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Default language direction is determined by the saved user role
    if (_sourceLang == null || _targetLang == null) {
      _applyRoleLanguageDefaults();
    }
  }

  void _applyRoleLanguageDefaults() {
    final profile = ProfileScope.of(context).profile;
    if (profile?.role == UserRole.student) {
      _sourceLang = 'Santhali';
      _targetLang = 'Hindi';
    } else {
      _sourceLang = 'Hindi';
      _targetLang = 'Santhali';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// Temporarily swaps translation direction in the current session
  /// without modifying the user's permanent profile role.
  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _errorMessage = null;
    });
  }

  Future<void> _handleTranslate() async {
    final text = _inputController.text.trim();

    // 1. Empty input validation
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter text to translate.';
        _currentResult = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _translationService.translate(
        text: text,
        sourceLang: _sourceLang ?? 'Hindi',
        targetLang: _targetLang ?? 'Santhali',
      );

      if (!mounted) return;

      setState(() {
        _currentResult = result;
        _isLoading = false;
        // Prepend to display history
        _history.insert(0, result);
      });

      // Persist to local database
      _historyRepository.saveTranslation(
        TranslationHistoryItem(
          sourceText: result.sourceText,
          translatedText: result.translatedText,
          sourceLanguage: result.sourceLang,
          targetLanguage: result.targetLang,
          phoneticGuide: result.phoneticGuide,
          isDemo: result.isDemo,
          createdAt: result.timestamp,
        ),
      );
    } on TranslationException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _currentResult = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected translation error occurred.';
        _currentResult = null;
        _isLoading = false;
      });
    }
  }

  void _handleClear() {
    setState(() {
      _inputController.clear();
      _currentResult = null;
      _errorMessage = null;
    });
  }

  void _handleCopy() {
    if (_currentResult == null) return;
    Clipboard.setData(ClipboardData(text: _currentResult!.translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation copied to clipboard.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryLavender,
      ),
    );
  }

  void _handleAudio() {
    // Honest handling: Audio TTS implementation is scheduled for Stage 9
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio support will be added in the voice/audio stage.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.secondaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSourceHindi = (_sourceLang ?? 'Hindi').toLowerCase().contains('hindi');
    final suggestions = isSourceHindi ? _hindiSuggestions : _santhaliSuggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Direction to Role Default',
            onPressed: () {
              setState(() {
                _applyRoleLanguageDefaults();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // 1. Language Direction Selector Bar
            CustomCard(
              backgroundColor: AppColors.lavenderLight,
              borderColor: AppColors.lavenderMedium.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLanguageBadge(
                    _sourceLang ?? 'Hindi',
                    AppColors.lavenderDark,
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'Swap Language Direction (Temporary)',
                    color: AppColors.primaryLavender,
                    iconSize: 26,
                    onPressed: _isLoading ? null : _swapLanguages,
                  ),
                  _buildLanguageBadge(
                    _targetLang ?? 'Santhali',
                    AppColors.secondaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Source Input Area
            SectionHeader(
              title: 'Source Text ($_sourceLang)',
              subtitle: 'Enter classroom words or sentences',
            ),
            CustomCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _inputController,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.darkCharcoal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type $sourceLangName text here...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: _inputController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: _handleClear,
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Quick Suggestion Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: suggestions.map((chipText) {
                      return ActionChip(
                        label: Text(chipText),
                        backgroundColor: AppColors.softCream,
                        side: const BorderSide(color: AppColors.cardBorder),
                        labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                        onPressed: () {
                          _inputController.text = chipText;
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Action Row: Clear & Translate Buttons
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleClear,
                        icon: const Icon(Icons.clear_all_rounded, size: 18),
                        label: const Text('Clear'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleTranslate,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.translate_rounded, size: 18),
                          label: Text(_isLoading ? 'Translating...' : 'Translate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Error Banner (if validation or lookup fails)
            if (_errorMessage != null) ...[
              CustomCard(
                backgroundColor: AppColors.statusError.withValues(alpha: 0.1),
                borderColor: AppColors.statusError.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.statusError,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.statusError,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 4. Translation Output Area
            if (_currentResult != null) ...[
              SectionHeader(
                title: 'Translation ($_targetLang)',
                subtitle: 'Verified demo classroom vernacular output',
              ),
              CustomCard(
                backgroundColor: AppColors.whiteCard,
                borderColor: AppColors.cardBorder,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: Explicitly indicates Demo Translation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lavenderLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryLavender.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_outlined,
                                size: 14,
                                color: AppColors.primaryLavender,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentResult!.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lavenderDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              tooltip: 'Listen to Pronunciation',
                              color: AppColors.secondaryBlue,
                              onPressed: _handleAudio,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              tooltip: 'Copy Translation',
                              color: AppColors.primaryLavender,
                              onPressed: _handleCopy,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Translated Result Text
                    Text(
                      _currentResult!.translatedText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                    ),

                    if (_currentResult!.phoneticGuide != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Phonetics: ${_currentResult!.phoneticGuide!}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.charcoalMuted,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 5. Persistent Translation History Section
            SectionHeader(
              title: 'Recent Translations',
              subtitle: 'Persistent offline translation history',
              action: _history.isNotEmpty
                  ? TextButton(
                      onPressed: () async {
                        await _historyRepository.clearHistory();
                        if (!mounted) return;
                        setState(() {
                          _history.clear();
                        });
                      },
                      child: const Text('Clear History'),
                    )
                  : null,
            ),
            if (_history.isEmpty)
              CustomCard(
                backgroundColor: AppColors.creamAlt,
                borderColor: AppColors.cardBorder,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: AppColors.charcoalLight,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No translation history yet. Enter a phrase above to see it recorded here.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.charcoalMuted,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_history.length, (index) {
                final item = _history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CustomCard(
                    padding: const EdgeInsets.all(14.0),
                    onTap: () {
                      setState(() {
                        _inputController.text = item.sourceText;
                        _currentResult = item;
                        _sourceLang = item.sourceLang;
                        _targetLang = item.targetLang;
                        _errorMessage = null;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lavenderLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            color: AppColors.primaryLavender,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.sourceText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.translatedText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lavenderDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.sourceLang} → ${item.targetLang}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.charcoalLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: 'Copy',
                          color: AppColors.charcoalMuted,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: item.translatedText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied from history to clipboard.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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

  String get sourceLangName => _sourceLang ?? 'Hindi';

  static Widget _buildLanguageBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
