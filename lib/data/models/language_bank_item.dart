/// Model representing a bilingual vocabulary word in the language bank.
class LanguageBankItem {
  final String id;
  final String santhaliWord; // Ol Chiki script
  final String santhaliScript; // Ol Chiki or phonetic transcription
  final String hindiMeaning; // Devanagari Hindi
  final String englishMeaning;
  final String pronunciation;
  final String category;
  final String difficulty;
  final bool isVerified;
  final String audioStatus;

  const LanguageBankItem({
    required this.id,
    required this.santhaliWord,
    required this.santhaliScript,
    required this.hindiMeaning,
    required this.englishMeaning,
    required this.pronunciation,
    required this.category,
    this.difficulty = 'easy',
    this.isVerified = false,
    this.audioStatus = 'Audio coming in Stage 9',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'santhali_word': santhaliWord,
      'santhali_script': santhaliScript,
      'hindi_meaning': hindiMeaning,
      'english_meaning': englishMeaning,
      'pronunciation': pronunciation,
      'category': category,
      'difficulty': difficulty,
      'is_verified': isVerified ? 1 : 0,
    };
  }

  factory LanguageBankItem.fromMap(Map<String, dynamic> map) {
    return LanguageBankItem(
      id: map['id'] as String? ?? '',
      santhaliWord: map['santhali_word'] as String? ?? '',
      santhaliScript: map['santhali_script'] as String? ?? '',
      hindiMeaning: map['hindi_meaning'] as String? ?? '',
      englishMeaning: map['english_meaning'] as String? ?? '',
      pronunciation: map['pronunciation'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      difficulty: map['difficulty'] as String? ?? 'easy',
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      audioStatus: map['audio_status'] as String? ?? 'Audio coming in Stage 9',
    );
  }
}
