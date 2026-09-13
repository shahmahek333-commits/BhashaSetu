import '../database/app_database.dart';
import '../models/flashcard_item.dart';

/// Summary of flashcard learning progress for local analytics.
class FlashcardProgressSummary {
  final int totalCards;
  final int knownCount;
  final int reviewCount;
  final int unstudiedCount;
  final int totalPracticeSessions;

  const FlashcardProgressSummary({
    required this.totalCards,
    required this.knownCount,
    required this.reviewCount,
    required this.unstudiedCount,
    required this.totalPracticeSessions,
  });

  double get masteryPercentage =>
      totalCards > 0 ? (knownCount / totalCards) * 100.0 : 0.0;
}

/// Repository managing flashcards and self-assessment progress in local database.
class FlashcardRepository {
  final AppDatabase _db;

  FlashcardRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves all flashcards ordered by id.
  Future<List<FlashcardItem>> getAllFlashcards() async {
    final rows = await _db.query('flashcards', orderBy: 'id ASC');
    return rows.map((r) => FlashcardItem.fromMap(r)).toList();
  }

  /// Updates practice outcome when user marks "I Know" or "Practice Again".
  Future<void> recordPracticeOutcome(String id, {required bool isKnown}) async {
    final rows = await _db.query('flashcards', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;

    final current = FlashcardItem.fromMap(rows.first);
    final newStatus = isKnown ? 'known' : 'review';
    final newPracticedCount = current.timesPracticed + 1;
    final now = DateTime.now().toIso8601String();

    await _db.update(
      'flashcards',
      {
        'status': newStatus,
        'times_practiced': newPracticedCount,
        'last_practiced_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Aggregates progress metrics for the current user.
  Future<FlashcardProgressSummary> getProgressSummary() async {
    final cards = await getAllFlashcards();
    int known = 0;
    int review = 0;
    int unstudied = 0;
    int totalPractice = 0;

    for (final card in cards) {
      totalPractice += card.timesPracticed;
      if (card.status == 'known') {
        known++;
      } else if (card.status == 'review') {
        review++;
      } else {
        unstudied++;
      }
    }

    return FlashcardProgressSummary(
      totalCards: cards.length,
      knownCount: known,
      reviewCount: review,
      unstudiedCount: unstudied,
      totalPracticeSessions: totalPractice,
    );
  }

  /// Resets all flashcard statuses to 'new' for fresh revision.
  Future<void> resetAllProgress() async {
    await _db.update('flashcards', {
      'status': 'new',
      'times_practiced': 0,
      'last_practiced_at': null,
    });
  }
}
