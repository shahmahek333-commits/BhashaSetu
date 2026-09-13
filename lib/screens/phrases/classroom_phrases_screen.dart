import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/classroom_phrase.dart';
import '../../data/repositories/classroom_phrase_repository.dart';

/// Interactive Classroom Phrases screen for teachers and educators.
/// Provides offline categorized phrases across Hindi and Santhali with phonetic guides.
class ClassroomPhrasesScreen extends StatefulWidget {
  final ClassroomPhraseRepository? repository;

  const ClassroomPhrasesScreen({super.key, this.repository});

  @override
  State<ClassroomPhrasesScreen> createState() => _ClassroomPhrasesScreenState();
}

class _ClassroomPhrasesScreenState extends State<ClassroomPhrasesScreen> {
  late final ClassroomPhraseRepository _repo;
  final TextEditingController _searchController = TextEditingController();

  List<ClassroomPhrase> _phrases = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ClassroomPhraseRepository();
    _loadPhrases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPhrases() async {
    setState(() => _isLoading = true);
    final results = await _repo.searchPhrases(
      _searchController.text,
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _phrases = results;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _loadPhrases();
  }

  void _onSearchChanged(String query) {
    _loadPhrases();
  }

  void _clearSearch() {
    _searchController.clear();
    _loadPhrases();
  }

  void _copyPhrase(ClassroomPhrase phrase) {
    final text = '${phrase.phraseHindi}\n${phrase.phraseSanthali} (${phrase.pronunciation})';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Phrase copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAudioStatusNotice(ClassroomPhrase phrase) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.whiteCard,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.secondaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio Pronunciation Status',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkCharcoal,
                              ),
                        ),
                        Text(
                          phrase.audioStatus,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pronunciation Guide:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  phrase.pronunciation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.lavenderDark,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.creamAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.statusWarning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reliable text-to-speech voice synthesis will be integrated in Stage 9. Audio is not simulated.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.darkCharcoal,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLavender,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhraseDetail(ClassroomPhrase phrase) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.whiteCard,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lavenderLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          phrase.category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryLavender,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.science_outlined,
                                size: 12, color: AppColors.statusWarning),
                            const SizedBox(width: 4),
                            Text(
                              'Sample / Demo',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.statusWarning,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hindi (हिंदी)',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.charcoalLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase.phraseHindi,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                  ),
                  const Divider(height: 28),
                  Text(
                    'Santhali ( Ol Chiki ᱥᱟᱱᱛᱟᱲᱤ )',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryLavender,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softCream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phrase.phraseSanthali,
                          style: const TextStyle(
                            fontFamily: 'NotoSansOlChiki',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pronunciation: ${phrase.pronunciation}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.lavenderDark,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Classroom Context & Usage',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.darkCharcoal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(12),
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
                          child: Text(
                            phrase.teacherContext,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.darkCharcoal,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyPhrase(phrase),
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkCharcoal,
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _showAudioStatusNotice(phrase);
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: const Text('Audio Status'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: const Text('Classroom Phrases'),
        backgroundColor: AppColors.softCream,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner & Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: AppColors.softCream,
            child: Column(
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLavender.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        color: AppColors.primaryLavender,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Teacher vernacular instructions and pedagogical dialogue (Demo content - pending native review).',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.darkCharcoal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search phrases in Hindi or Santhali...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.charcoalLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryLavender),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.charcoalLight),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.whiteCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryLavender, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Categories Filter
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ClassroomPhraseRepository.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = ClassroomPhraseRepository.categories[index];
                final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => _onCategorySelected(cat),
                  selectedColor: AppColors.primaryLavender,
                  backgroundColor: AppColors.whiteCard,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkCharcoal,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryLavender : AppColors.cardBorder,
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Phrase List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryLavender),
                  )
                : _phrases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.charcoalLight.withAlpha(150),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No classroom phrases found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try selecting another category or clear search query',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.charcoalLight),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _phrases.length,
                        itemBuilder: (context, index) {
                          final phrase = _phrases[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.cardBorder),
                            ),
                            color: AppColors.whiteCard,
                            child: InkWell(
                              onTap: () => _showPhraseDetail(phrase),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category + Badges
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.lavenderLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            phrase.category.toUpperCase(),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: AppColors.primaryLavender,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.creamAlt,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.cardBorder),
                                          ),
                                          child: Text(
                                            'Demo / Sample',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: AppColors.charcoalLight,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Hindi Sentence
                                    Text(
                                      phrase.phraseHindi,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkCharcoal,
                                          ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Santhali in Ol Chiki
                                    Text(
                                      phrase.phraseSanthali,
                                      style: const TextStyle(
                                        fontFamily: 'NotoSansOlChiki',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lavenderDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Pronunciation
                                    Text(
                                      phrase.pronunciation,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.charcoalLight,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Context & Action row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.lightbulb_outline_rounded,
                                                size: 14,
                                                color: AppColors.secondaryBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  phrase.teacherContext,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: AppColors.charcoalLight,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                                          color: AppColors.secondaryBlue,
                                          tooltip: 'Audio Status',
                                          onPressed: () => _showAudioStatusNotice(phrase),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy_rounded, size: 18),
                                          color: AppColors.charcoalLight,
                                          tooltip: 'Copy Phrase',
                                          onPressed: () => _copyPhrase(phrase),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
