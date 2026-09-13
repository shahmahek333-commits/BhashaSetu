/// Model representing a persistent translation history record in SQLite.
class TranslationHistoryItem {
  final int? id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String? phoneticGuide;
  final bool isDemo;
  final DateTime createdAt;

  const TranslationHistoryItem({
    this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.phoneticGuide,
    this.isDemo = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'source_text': sourceText,
      'translated_text': translatedText,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'phonetic_guide': phoneticGuide,
      'is_demo': isDemo ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TranslationHistoryItem.fromMap(Map<String, dynamic> map) {
    return TranslationHistoryItem(
      id: map['id'] as int?,
      sourceText: map['source_text'] as String? ?? '',
      translatedText: map['translated_text'] as String? ?? '',
      sourceLanguage: map['source_language'] as String? ?? 'Hindi',
      targetLanguage: map['target_language'] as String? ?? 'Santhali',
      phoneticGuide: map['phonetic_guide'] as String?,
      isDemo: (map['is_demo'] as int? ?? 1) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
