import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/language_bank_item.dart';
import '../../data/repositories/language_bank_repository.dart';

/// Language Bank vocabulary dictionary screen.
/// Provides offline categorized words across Santhali (Ol Chiki), Hindi, and English.
class LanguageBankScreen extends StatefulWidget {
  final LanguageBankRepository? repository;
  final String? initialCategory;

  const LanguageBankScreen({
    super.key,
    this.repository,
    this.initialCategory,
  });

  @override
  State<LanguageBankScreen> createState() => _LanguageBankScreenState();
}

class _LanguageBankScreenState extends State<LanguageBankScreen> {
  late final LanguageBankRepository _repo;
  final TextEditingController _searchController = TextEditingController();

  List<LanguageBankItem> _items = [];
  late String _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? LanguageBankRepository();
    _selectedCategory = widget.initialCategory ?? 'All';
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final results = await _repo.searchAndFilter(
      query: _searchController.text,
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _items = results;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _loadItems();
  }

  void _onSearchChanged(String query) {
    _loadItems();
  }

  void _clearSearch() {
    _searchController.clear();
    _loadItems();
  }

  void _copyWord(LanguageBankItem item) {
    final text = '${item.santhaliWord} (${item.santhaliScript}) - ${item.hindiMeaning} / ${item.englishMeaning}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Word copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAudioStatusNotice(LanguageBankItem item) {
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
                          item.audioStatus,
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
                'Phonetic Breakdown:',
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
                  item.pronunciation,
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

  void _showWordDetail(LanguageBankItem item) {
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

                  // Category & Unverified badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lavenderLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.toUpperCase().replaceAll('_', ' '),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryLavender,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.creamAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 12, color: AppColors.statusWarning),
                            const SizedBox(width: 4),
                            Text(
                              'Sample / Unverified',
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

                  // Ol Chiki Primary Display
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.softCream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lavenderLight),
                      ),
                      child: Column(
                        children: [
                          Text(
                            item.santhaliWord,
                            style: const TextStyle(
                              fontFamily: 'NotoSansOlChiki',
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.santhaliScript,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryLavender,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.pronunciation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.charcoalLight,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bilingual Meanings
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hindi (हिंदी)',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.secondaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.hindiMeaning,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkCharcoal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'English',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.tertiaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.englishMeaning,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkCharcoal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Metadata Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bar_chart_rounded,
                                size: 16, color: AppColors.primaryLavender),
                            const SizedBox(width: 6),
                            Text(
                              'Difficulty: ${item.difficulty.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.mic_none_rounded,
                                size: 16, color: AppColors.secondaryBlue),
                            const SizedBox(width: 6),
                            Text(
                              'TTS: Stage 9',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyWord(item),
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy Word'),
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
                            _showAudioStatusNotice(item);
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
        title: const Text('Language Bank'),
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
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondaryBlue.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.secondaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Categorized bilingual vocabulary across 10 educational themes (Demo content - pending native review).',
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
                    hintText: 'Search in Santhali, Hindi, or English...',
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
              itemCount: LanguageBankRepository.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = LanguageBankRepository.categories[index];
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

          // Words Grid / List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryLavender),
                  )
                : _items.isEmpty
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
                              'No vocabulary words found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try another category or clear search terms',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.charcoalLight),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.cardBorder),
                            ),
                            color: AppColors.whiteCard,
                            child: InkWell(
                              onTap: () => _showWordDetail(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Script & Word box
                                    Container(
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.lavenderLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.santhaliWord,
                                            style: const TextStyle(
                                              fontFamily: 'NotoSansOlChiki',
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkCharcoal,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.santhaliScript,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: AppColors.primaryLavender,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Meanings & Category
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.creamAlt,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.category.toUpperCase().replaceAll('_', ' '),
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                        color: AppColors.charcoalLight,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
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
                                                  'Demo',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                        color: AppColors.statusWarning,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.hindiMeaning,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.darkCharcoal,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.englishMeaning,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppColors.charcoalLight,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.pronunciation,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppColors.lavenderDark,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Audio status button
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                                      color: AppColors.secondaryBlue,
                                      tooltip: 'Audio Status',
                                      onPressed: () => _showAudioStatusNotice(item),
                                      visualDensity: VisualDensity.compact,
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
