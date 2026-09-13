import '../database/app_database.dart';
import '../models/translation_history_item.dart';

/// Repository managing persistent translation history in SQLite.
class TranslationHistoryRepository {
  final AppDatabase _db;

  TranslationHistoryRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Inserts a new translation record into local storage.
  Future<void> saveTranslation(TranslationHistoryItem item) async {
    await _db.insert('translation_history', item.toMap());
  }

  /// Retrieves recent translations, newest first.
  Future<List<TranslationHistoryItem>> getRecentTranslations({int limit = 20}) async {
    final rows = await _db.query(
      'translation_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((r) => TranslationHistoryItem.fromMap(r)).toList();
  }

  /// Clears all translation history.
  Future<void> clearHistory() async {
    await _db.delete('translation_history');
  }

  /// Returns total count of saved translations for progress tracking.
  Future<int> getTotalCount() async {
    final rows = await _db.query('translation_history');
    return rows.length;
  }
}
