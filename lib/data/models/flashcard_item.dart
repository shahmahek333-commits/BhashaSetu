/// Model representing an interactive bilingual flashcard.
class FlashcardItem {
  final String id;
  final String? languageBankId;
  final String santhaliWord; // Ol Chiki script
  final String hindiMeaning;
  final String englishMeaning;
  final String pronunciation;
  final String status; // 'new', 'known', 'review'
  final int timesPracticed;
  final DateTime? lastPracticedAt;

  const FlashcardItem({
    required this.id,
    this.languageBankId,
    required this.santhaliWord,
    required this.hindiMeaning,
    required this.englishMeaning,
    required this.pronunciation,
    this.status = 'new',
    this.timesPracticed = 0,
    this.lastPracticedAt,
  });

  FlashcardItem copyWith({
    String? id,
    String? languageBankId,
    String? santhaliWord,
    String? hindiMeaning,
    String? englishMeaning,
    String? pronunciation,
    String? status,
    int? timesPracticed,
    DateTime? lastPracticedAt,
  }) {
    return FlashcardItem(
      id: id ?? this.id,
      languageBankId: languageBankId ?? this.languageBankId,
      santhaliWord: santhaliWord ?? this.santhaliWord,
      hindiMeaning: hindiMeaning ?? this.hindiMeaning,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      pronunciation: pronunciation ?? this.pronunciation,
      status: status ?? this.status,
      timesPracticed: timesPracticed ?? this.timesPracticed,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language_bank_id': languageBankId,
      'santhali_word': santhaliWord,
      'hindi_meaning': hindiMeaning,
      'english_meaning': englishMeaning,
      'pronunciation': pronunciation,
      'status': status,
      'times_practiced': timesPracticed,
      'last_practiced_at': lastPracticedAt?.toIso8601String(),
    };
  }

  factory FlashcardItem.fromMap(Map<String, dynamic> map) {
    return FlashcardItem(
      id: map['id'] as String? ?? '',
      languageBankId: map['language_bank_id'] as String?,
      santhaliWord: map['santhali_word'] as String? ?? '',
      hindiMeaning: map['hindi_meaning'] as String? ?? '',
      englishMeaning: map['english_meaning'] as String? ?? '',
      pronunciation: map['pronunciation'] as String? ?? '',
      status: map['status'] as String? ?? 'new',
      timesPracticed: map['times_practiced'] as int? ?? 0,
      lastPracticedAt: map['last_practiced_at'] != null
          ? DateTime.tryParse(map['last_practiced_at'] as String)
          : null,
    );
  }
}
