/// Model representing a bilingual classroom instruction or conversation phrase.
class ClassroomPhrase {
  final String id;
  final String phraseHindi;
  final String phraseSanthali; // Ol Chiki script
  final String pronunciation;
  final String category; // 'greetings', 'instruction', 'question', 'encouragement', 'homework', 'examination'
  final String teacherContext;
  final bool isVerified;
  final String audioStatus;

  const ClassroomPhrase({
    required this.id,
    required this.phraseHindi,
    required this.phraseSanthali,
    required this.pronunciation,
    required this.category,
    required this.teacherContext,
    this.isVerified = false,
    this.audioStatus = 'Audio coming in Stage 9',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phrase_hindi': phraseHindi,
      'phrase_santhali': phraseSanthali,
      'pronunciation': pronunciation,
      'category': category,
      'teacher_context': teacherContext,
    };
  }

  factory ClassroomPhrase.fromMap(Map<String, dynamic> map) {
    return ClassroomPhrase(
      id: map['id'] as String? ?? '',
      phraseHindi: map['phrase_hindi'] as String? ?? '',
      phraseSanthali: map['phrase_santhali'] as String? ?? '',
      pronunciation: map['pronunciation'] as String? ?? '',
      category: map['category'] as String? ?? 'instruction',
      teacherContext: map['teacher_context'] as String? ?? '',
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      audioStatus: map['audio_status'] as String? ?? 'Audio coming in Stage 9',
    );
  }
}
