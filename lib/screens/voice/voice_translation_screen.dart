import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/translation_history_item.dart';
import '../../data/repositories/translation_history_repository.dart';
import '../../models/translation_result.dart';
import '../../models/user_profile.dart';
import '../../services/mock_translation_service.dart';
import '../../services/speech_service.dart';
import '../../services/translation_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/common/custom_card.dart';

/// Professional Voice Translation screen for BhashaSetu.
/// Handles speech-to-text recording, role-based translation direction,
/// authentic Hindi TTS playback, and transparent capability notices for Santhali.
class VoiceTranslationScreen extends StatefulWidget {
  final UserProfile? profile;
  final SpeechService? speechService;
  final TtsService? ttsService;
  final TranslationService? translationService;
  final TranslationHistoryRepository? historyRepository;

  const VoiceTranslationScreen({
    super.key,
    this.profile,
    this.speechService,
    this.ttsService,
    this.translationService,
    this.historyRepository,
  });

  @override
  State<VoiceTranslationScreen> createState() => _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends State<VoiceTranslationScreen>
    with SingleTickerProviderStateMixin {
  late final SpeechService _speechService;
  late final TtsService _ttsService;
  late final TranslationService _translationService;
  late final TranslationHistoryRepository _historyRepository;
  late final TextEditingController _inputController;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  UserProfile? _effectiveProfile;
  String _sourceLang = 'Hindi';
  String _targetLang = 'Santhali';

  bool _isListening = false;
  bool _isTranslating = false;
  bool _isPlayingAudio = false;
  String? _errorMessage;
  TranslationResult? _currentResult;

  // Curated classroom phrases for quick speech testing
  static const List<String> _teacherPrompts = [
    'नमस्ते',
    'किताब खोलो',
    'ध्यान से सुनो',
    'बहुत अच्छा',
    'पानी',
    'गृहकार्य पूरा करो',
  ];

  static const List<String> _studentPrompts = [
    'ᱡᱚᱦᱟᱨ',
    'ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ',
    'ᱫᱷᱮᱭᱟᱱ ᱛᱮ ᱟᱧᱡᱚᱢ ᱢᱮ',
    'ᱟᱹᱰᱤ ᱵᱷᱟᱹᱜᱤ',
    'ᱫᱟᱜ',
  ];

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? AppSpeechService();
    _ttsService = widget.ttsService ?? AppTtsService();
    _translationService =
        widget.translationService ?? const MockTranslationService();
    _historyRepository =
        widget.historyRepository ?? TranslationHistoryRepository();
    _inputController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _effectiveProfile = widget.profile;
    _initServices();
  }

  Future<void> _initServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectiveProfile == null) {
      final scopeProfile = ProfileScope.of(context).profile;
      if (scopeProfile != null) {
        _effectiveProfile = scopeProfile;
      }
    }
    _applyLanguageDirection();
  }

  void _applyLanguageDirection() {
    final role = _effectiveProfile?.role ?? UserRole.teacher;
    setState(() {
      if (role == UserRole.teacher) {
        _sourceLang = 'Hindi';
        _targetLang = 'Santhali';
      } else {
        _sourceLang = 'Santhali';
        _targetLang = 'Hindi';
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputController.dispose();
    _speechService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      if (!mounted) return;
      _pulseController.stop();
      _pulseController.reset();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });

      if (!_speechService.isLanguageSupported(_sourceLang)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_speechService.getLanguageNotice(_sourceLang)),
            duration: const Duration(seconds: 4),
            backgroundColor: AppColors.lavenderDark,
          ),
        );
        return;
      }

      _pulseController.repeat(reverse: true);
      setState(() {
        _isListening = true;
      });

      await _speechService.startListening(
        languageCode: _sourceLang,
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _inputController.text = text;
            if (isFinal) {
              _isListening = false;
              _pulseController.stop();
              _pulseController.reset();
            }
          });
          if (isFinal && text.trim().isNotEmpty) {
            _translate();
          }
        },
        onError: (error) {
          if (!mounted) return;
          _pulseController.stop();
          _pulseController.reset();
          setState(() {
            _isListening = false;
            _errorMessage = error;
          });
        },
        onStatusChange: (status) {
          if (!mounted) return;
          if (status == SpeechStatus.done ||
              status == SpeechStatus.error ||
              status == SpeechStatus.idle) {
            _pulseController.stop();
            _pulseController.reset();
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    }
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please speak or enter text to translate.';
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      final result = await _translationService.translate(
        text: text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      // Save to SQLite history
      try {
        await _historyRepository.saveTranslation(
          TranslationHistoryItem(
            sourceText: result.sourceText,
            translatedText: result.translatedText,
            sourceLanguage: result.sourceLang,
            targetLanguage: result.targetLang,
            phoneticGuide: result.phoneticGuide,
            isDemo: result.isDemo,
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _currentResult = result;
        _isTranslating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isTranslating = false;
      });
    }
  }

  Future<void> _handleAudioPlayback() async {
    if (_currentResult == null) return;

    // Check target language support for TTS
    if (_ttsService.isLanguageSupported(_targetLang)) {
      setState(() {
        _isPlayingAudio = true;
      });
      await _ttsService.speak(
        text: _currentResult!.translatedText,
        languageCode: _targetLang,
      );
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      // Honest notice: Santhali TTS is pending Stage 10 BHASHINI integration
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: AppColors.secondaryBlue),
              SizedBox(width: 8),
              Text('Audio Notice', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            _ttsService.getLanguageNotice(_targetLang),
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
    }
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _currentResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = (_effectiveProfile?.role ?? UserRole.teacher) == UserRole.teacher;
    final prompts = isTeacher ? _teacherPrompts : _studentPrompts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Translation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear',
            onPressed: _clear,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Direction & Mode Card
            CustomCard(
              backgroundColor: isTeacher ? AppColors.lavenderLight : AppColors.blueLight,
              borderColor: isTeacher
                  ? AppColors.primaryLavender.withValues(alpha: 0.3)
                  : AppColors.secondaryBlue.withValues(alpha: 0.3),
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
                      Icons.record_voice_over_rounded,
                      color: isTeacher ? AppColors.primaryLavender : AppColors.secondaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isTeacher ? 'Teacher Voice Mode' : 'Student Voice Mode',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkCharcoal,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.whiteCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                isTeacher ? 'Hindi → Santhali' : 'Santhali → Hindi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isTeacher
                                      ? AppColors.lavenderDark
                                      : AppColors.secondaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTeacher
                              ? 'Speak in Hindi to translate into Santhali Ol Chiki for classroom teaching.'
                              : 'Practice Santhali words to translate into Hindi with speech audio.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.charcoalMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Microphone Recording Section
            CustomCard(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  // Pulsing mic button
                  ScaleTransition(
                    scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: GestureDetector(
                      onTap: _toggleListening,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.redAccent
                              : (isTeacher ? AppColors.primaryLavender : AppColors.secondaryBlue),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening
                                      ? Colors.redAccent
                                      : (isTeacher
                                          ? AppColors.primaryLavender
                                          : AppColors.secondaryBlue))
                                  .withValues(alpha: 0.35),
                              blurRadius: _isListening ? 18 : 8,
                              spreadRadius: _isListening ? 4 : 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mic Status indicator
                  Text(
                    _isListening
                        ? 'Listening... Speak now'
                        : 'Tap microphone to speak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isListening ? Colors.redAccent : AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Input Language: $_sourceLang',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.charcoalMuted,
                    ),
                  ),

                  // Santhali unsupported notice if source is Santhali
                  if (!_speechService.isLanguageSupported(_sourceLang)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.creamAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.charcoalMuted,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Santhali speech recognition pending BHASHINI (Stage 10). Type or select sample phrases below.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick classroom prompts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Classroom Phrases',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prompts.map((prompt) {
                    return ActionChip(
                      label: Text(prompt),
                      backgroundColor: AppColors.softCream,
                      side: const BorderSide(color: AppColors.cardBorder),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkCharcoal,
                      ),
                      onPressed: () {
                        _inputController.text = prompt;
                        _translate();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input / Recognized text field
            CustomCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recognized Speech / Text Input',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCharcoal,
                            ),
                      ),
                      if (_inputController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _inputController.clear();
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _inputController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: isTeacher
                          ? 'Say or enter Hindi phrase (e.g. नमस्ते, किताब खोलो)...'
                          : 'Enter or say Santhali phrase (e.g. ᱡᱚᱦᱟᱨ, ᱫᱟᱜ)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isTeacher
                              ? AppColors.primaryLavender
                              : AppColors.secondaryBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.softCream.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Translate Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTranslating ? null : _translate,
                      icon: _isTranslating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.translate_rounded),
                      label: Text(
                        _isTranslating
                            ? 'Translating...'
                            : 'Translate to $_targetLang',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTeacher
                            ? AppColors.primaryLavender
                            : AppColors.secondaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error display
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Translation Result Card
            if (_currentResult != null) ...[
              const SizedBox(height: 20),
              CustomCard(
                backgroundColor: AppColors.greenLight.withValues(alpha: 0.7),
                borderColor: AppColors.greenMedium.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.whiteCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.greenMedium.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.tertiaryGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Translation Result',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.creamAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _currentResult!.badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoalMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Translated text display
                    SelectableText(
                      _currentResult!.translatedText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                            height: 1.3,
                          ),
                    ),

                    // Phonetic guide if available
                    if (_currentResult!.phoneticGuide != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Pronunciation: ${_currentResult!.phoneticGuide}',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.charcoalMuted,
                        ),
                      ),
                    ],
                    const Divider(height: 24),

                    // Action buttons: Audio Playback & Copy
                    Row(
                      children: [
                        // TTS Audio Playback Button
                        ElevatedButton.icon(
                          onPressed: _isPlayingAudio ? null : _handleAudioPlayback,
                          icon: Icon(
                            _isPlayingAudio
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isPlayingAudio ? 'Playing...' : 'Play Audio',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteCard,
                            foregroundColor: AppColors.secondaryBlue,
                            elevation: 0,
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Copy Button
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                  text: _currentResult!.translatedText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied translation to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text(
                            'Copy',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkCharcoal,
                            side: const BorderSide(color: AppColors.cardBorder),
                            backgroundColor: AppColors.whiteCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
