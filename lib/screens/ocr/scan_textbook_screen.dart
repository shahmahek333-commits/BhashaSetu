import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/translation_history_item.dart';
import '../../data/repositories/translation_history_repository.dart';
import '../../models/translation_result.dart';
import '../../models/user_profile.dart';
import '../../services/mock_translation_service.dart';
import '../../services/ocr_service.dart';
import '../../services/translation_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/common/custom_card.dart';

/// Professional Textbook OCR Scanner screen for BhashaSetu.
/// Enables camera capture, gallery selection, and textbook sample extraction,
/// followed by Devanagari text recognition, user editing, and vernacular translation.
class ScanTextbookScreen extends StatefulWidget {
  final UserProfile? profile;
  final OcrService? ocrService;
  final TranslationService? translationService;
  final TtsService? ttsService;
  final TranslationHistoryRepository? historyRepository;

  const ScanTextbookScreen({
    super.key,
    this.profile,
    this.ocrService,
    this.translationService,
    this.ttsService,
    this.historyRepository,
  });

  @override
  State<ScanTextbookScreen> createState() => _ScanTextbookScreenState();
}

class _ScanTextbookScreenState extends State<ScanTextbookScreen> {
  late final OcrService _ocrService;
  late final TranslationService _translationService;
  late final TtsService _ttsService;
  late final TranslationHistoryRepository _historyRepository;
  late final TextEditingController _extractedTextController;

  UserProfile? _effectiveProfile;
  String _sourceLang = 'Hindi';
  String _targetLang = 'Santhali';

  XFile? _selectedImage;
  TextbookSample? _selectedSample;
  bool _isProcessingOcr = false;
  bool _isTranslating = false;
  bool _isPlayingAudio = false;
  String? _ocrStatusNotice;
  String? _errorMessage;
  TranslationResult? _currentResult;

  @override
  void initState() {
    super.initState();
    _ocrService = widget.ocrService ?? AppOcrService();
    _translationService =
        widget.translationService ?? const MockTranslationService();
    _ttsService = widget.ttsService ?? AppTtsService();
    _historyRepository =
        widget.historyRepository ?? TranslationHistoryRepository();
    _extractedTextController = TextEditingController();
    _effectiveProfile = widget.profile;
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
    _extractedTextController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
      _ocrStatusNotice = null;
    });

    final image = await _ocrService.pickImage(source);
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _selectedSample = null;
      _isProcessingOcr = true;
    });

    try {
      final result = await _ocrService.extractText(
        image,
        sourceLanguage: _sourceLang,
      );

      if (!mounted) return;
      setState(() {
        _extractedTextController.text = result.rawText;
        _ocrStatusNotice = result.statusNotice;
        _isProcessingOcr = false;
      });

      if (result.rawText.trim().isNotEmpty) {
        _translate();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to extract text: $e';
        _isProcessingOcr = false;
      });
    }
  }

  void _selectSample(TextbookSample sample) async {
    setState(() {
      _selectedSample = sample;
      _selectedImage = null;
      _errorMessage = null;
      _isProcessingOcr = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _extractedTextController.text = sample.excerptHindi;
      _ocrStatusNotice =
          'Text extracted from sample: "${sample.title}" (${sample.grade})';
      _isProcessingOcr = false;
    });

    _translate();
  }

  Future<void> _translate() async {
    final text = _extractedTextController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please capture an image or select a textbook sample.';
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

      // Save to translation history
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
      _selectedImage = null;
      _selectedSample = null;
      _extractedTextController.clear();
      _currentResult = null;
      _ocrStatusNotice = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher =
        (_effectiveProfile?.role ?? UserRole.teacher) == UserRole.teacher;
    final samples = _ocrService.getSampleExcerpts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Textbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear Scanner',
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
              backgroundColor:
                  isTeacher ? AppColors.greenLight : AppColors.blueLight,
              borderColor: isTeacher
                  ? AppColors.tertiaryGreen.withValues(alpha: 0.3)
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
                      Icons.document_scanner_rounded,
                      color: isTeacher
                          ? AppColors.tertiaryGreen
                          : AppColors.secondaryBlue,
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
                              isTeacher
                                  ? 'Textbook OCR Mode'
                                  : 'Student Book Scanner',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkCharcoal,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.whiteCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                isTeacher
                                    ? 'Hindi → Santhali'
                                    : 'Santhali → Hindi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isTeacher
                                      ? AppColors.greenDark
                                      : AppColors.secondaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTeacher
                              ? 'Scan printed Hindi textbook passages to convert into Santhali Ol Chiki for primary teaching.'
                              : 'Scan classroom learning materials to view Hindi translations with audio.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
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

            // Honest Ol Chiki script notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.secondaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Script Capability Note',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _ocrService.getScriptNotice(_sourceLang),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.charcoalMuted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Capture Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLavender,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 20),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkCharcoal,
                      backgroundColor: AppColors.whiteCard,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sample Textbook Pages (for instant testing & web demo)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 16, color: AppColors.charcoalMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Sample Primary Textbook Passages',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: samples.map((sample) {
                    final isSelected = _selectedSample?.id == sample.id;
                    return ChoiceChip(
                      label: Text(sample.title),
                      selected: isSelected,
                      selectedColor: AppColors.lavenderLight,
                      backgroundColor: AppColors.softCream,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryLavender
                            : AppColors.cardBorder,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.lavenderDark
                            : AppColors.darkCharcoal,
                      ),
                      onSelected: (_) => _selectSample(sample),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image Preview or Sample Card
            if (_selectedImage != null || _selectedSample != null) ...[
              CustomCard(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 18,
                          color: AppColors.secondaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedSample != null
                                ? 'Sample: ${_selectedSample!.title}'
                                : 'Selected Image: ${_selectedImage!.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkCharcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _clear,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.creamAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedSample != null
                                ? Icons.menu_book_rounded
                                : Icons.insert_photo_rounded,
                            size: 40,
                            color: AppColors.charcoalMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedSample != null
                                ? _selectedSample!.description
                                : 'Ready for OCR processing',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
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
            ],

            // Extracted Text Card
            CustomCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Extracted Textbook Text (Editable)',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkCharcoal,
                                ),
                      ),
                      if (_isProcessingOcr)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryLavender,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _extractedTextController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Extracted textbook text will appear here. You can edit or type phrases directly...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isTeacher
                              ? AppColors.tertiaryGreen
                              : AppColors.secondaryBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.softCream.withValues(alpha: 0.5),
                    ),
                  ),
                  if (_ocrStatusNotice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _ocrStatusNotice!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.charcoalMuted,
                      ),
                    ),
                  ],
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
                            : 'Translate Extracted Text to $_targetLang',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTeacher
                            ? AppColors.tertiaryGreen
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
                              color:
                                  AppColors.greenMedium.withValues(alpha: 0.5),
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
                                'Textbook Translation',
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                                height: 1.3,
                              ),
                    ),

                    if (_currentResult!.phoneticGuide != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Pronunciation: ${_currentResult!.phoneticGuide}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.charcoalMuted,
                        ),
                      ),
                    ],
                    const Divider(height: 24),

                    // Audio & Copy Buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isPlayingAudio ? null : _handleAudioPlayback,
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
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                  text: _currentResult!.translatedText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Copied translation to clipboard!'),
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
