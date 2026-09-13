/// Data model representing the result of a translation operation in BhasaSetu.
class TranslationResult {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final bool isDemo;
  final String badge;
  final DateTime timestamp;
  final String? phoneticGuide;

  const TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    this.isDemo = true,
    this.badge = 'Demo Translation',
    required this.timestamp,
    this.phoneticGuide,
  });

  Map<String, dynamic> toMap() {
    return {
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'isDemo': isDemo,
      'badge': badge,
      'timestamp': timestamp.toIso8601String(),
      'phoneticGuide': phoneticGuide,
    };
  }

  factory TranslationResult.fromMap(Map<String, dynamic> map) {
    return TranslationResult(
      sourceText: map['sourceText'] as String? ?? '',
      translatedText: map['translatedText'] as String? ?? '',
      sourceLang: map['sourceLang'] as String? ?? 'Hindi',
      targetLang: map['targetLang'] as String? ?? 'Santhali',
      isDemo: map['isDemo'] as bool? ?? true,
      badge: map['badge'] as String? ?? 'Demo Translation',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      phoneticGuide: map['phoneticGuide'] as String?,
    );
  }
}
