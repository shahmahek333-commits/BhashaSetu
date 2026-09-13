import '../database/app_database.dart';
import '../models/classroom_phrase.dart';

/// Repository managing bilingual classroom instructional phrases.
class ClassroomPhraseRepository {
  final AppDatabase _db;

  ClassroomPhraseRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves all classroom phrases.
  Future<List<ClassroomPhrase>> getAllPhrases() async {
    final rows = await _db.query('classroom_phrases', orderBy: 'id ASC');
    return rows.map((r) => ClassroomPhrase.fromMap(r)).toList();
  }

  /// Filters classroom phrases by category ('instruction', 'question', 'encouragement').
  Future<List<ClassroomPhrase>> getPhrasesByCategory(String category) async {
    final rows = await _db.query(
      'classroom_phrases',
      where: 'category = ?',
      whereArgs: [category],
    );
    return rows.map((r) => ClassroomPhrase.fromMap(r)).toList();
  }

  /// Searches and filters classroom phrases across Hindi, Santhali, and pronunciation.
  Future<List<ClassroomPhrase>> searchPhrases(String query, {String? category}) async {
    final clean = query.trim().toLowerCase();
    List<ClassroomPhrase> list;
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      list = await getPhrasesByCategory(category.toLowerCase());
    } else {
      list = await getAllPhrases();
    }

    if (clean.isEmpty) return list;

    return list.where((p) {
      return p.phraseHindi.toLowerCase().contains(clean) ||
          p.phraseSanthali.contains(clean) ||
          p.pronunciation.toLowerCase().contains(clean) ||
          p.teacherContext.toLowerCase().contains(clean);
    }).toList();
  }

  /// Total classroom phrases count.
  Future<int> getTotalCount() async {
    final rows = await _db.query('classroom_phrases');
    return rows.length;
  }

  /// Standard classroom phrase categories.
  static const List<String> categories = [
    'All',
    'Greetings',
    'Instructions',
    'Questions',
    'Encouragement',
    'Homework',
    'Examination',
  ];
}
