import '../database/app_database.dart';
import '../models/language_bank_item.dart';

/// Repository managing offline vernacular vocabulary dictionary.
class LanguageBankRepository {
  final AppDatabase _db;

  LanguageBankRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves all language bank words.
  Future<List<LanguageBankItem>> getAllItems() async {
    final rows = await _db.query('language_bank', orderBy: 'id ASC');
    return rows.map((r) => LanguageBankItem.fromMap(r)).toList();
  }

  /// Filters items by category (e.g. 'classroom', 'greetings', 'numbers', 'nature').
  Future<List<LanguageBankItem>> getItemsByCategory(String category) async {
    final rows = await _db.query(
      'language_bank',
      where: 'category = ?',
      whereArgs: [category],
    );
    return rows.map((r) => LanguageBankItem.fromMap(r)).toList();
  }

  /// Searches vocabulary across Santhali, Hindi, and English.
  Future<List<LanguageBankItem>> searchItems(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return getAllItems();

    final all = await getAllItems();
    return all.where((item) {
      return item.santhaliWord.contains(clean) ||
          item.santhaliScript.toLowerCase().contains(clean) ||
          item.hindiMeaning.contains(clean) ||
          item.englishMeaning.toLowerCase().contains(clean);
    }).toList();
  }

  /// Searches vocabulary and filters by category across Santhali, Hindi, and English.
  Future<List<LanguageBankItem>> searchAndFilter({String? query, String? category}) async {
    final cleanQuery = query?.trim().toLowerCase() ?? '';
    final cleanCategory = (category != null && category.toLowerCase() != 'all')
        ? category.toLowerCase().replaceAll(' ', '_')
        : null;

    List<LanguageBankItem> items;
    if (cleanCategory != null) {
      items = await getItemsByCategory(cleanCategory);
    } else {
      items = await getAllItems();
    }

    if (cleanQuery.isEmpty) return items;

    return items.where((item) {
      return item.santhaliWord.contains(cleanQuery) ||
          item.santhaliScript.toLowerCase().contains(cleanQuery) ||
          item.hindiMeaning.contains(cleanQuery) ||
          item.englishMeaning.toLowerCase().contains(cleanQuery) ||
          item.pronunciation.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  /// Total vocabulary entries count.
  Future<int> getTotalCount() async {
    final rows = await _db.query('language_bank');
    return rows.length;
  }

  /// All 10 supported Language Bank categories.
  static const List<String> categories = [
    'All',
    'Numbers',
    'Colors',
    'Family',
    'Animals',
    'School',
    'Food',
    'Body Parts',
    'Nature',
    'Common Verbs',
    'Classroom Words',
  ];
}
