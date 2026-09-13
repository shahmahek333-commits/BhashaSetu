import '../../models/user_profile.dart';
import '../database/app_database.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';

/// Aggregated performance metrics from completed quizzes.
class QuizMetricsSummary {
  final int totalQuizzesCompleted;
  final double averageScore;
  final double averageAccuracyPercent;
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;

  const QuizMetricsSummary({
    required this.totalQuizzesCompleted,
    required this.averageScore,
    required this.averageAccuracyPercent,
    required this.totalCorrectAnswers,
    required this.totalQuestionsAnswered,
  });
}

/// Repository managing quiz questions and persistent quiz results in SQLite.
class QuizRepository {
  final AppDatabase _db;

  QuizRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  /// Retrieves quiz questions tailored to the given question type.
  Future<List<QuizQuestion>> getQuestionsByType(QuizType type) async {
    final rows = await _db.query(
      'quiz_questions',
      where: 'question_type = ?',
      whereArgs: [type.dbValue],
    );
    return rows.map((r) => QuizQuestion.fromMap(r)).toList();
  }

  /// Retrieves questions aligned with the user's educational role:
  /// - Teacher: Hindi -> Santhali questions
  /// - Student: Santhali -> Hindi questions
  Future<List<QuizQuestion>> getQuestionsForRole(UserRole role, {QuizType? type}) async {
    final allRows = await _db.query(
      'quiz_questions',
      where: type != null ? 'question_type = ?' : null,
      whereArgs: type != null ? [type.dbValue] : null,
    );

    final allQuestions = allRows.map((r) => QuizQuestion.fromMap(r)).toList();

    final targetSourceLang = role == UserRole.teacher ? 'Hindi' : 'Santhali';
    final roleQuestions = allQuestions
        .where((q) => q.sourceLanguage.toLowerCase() == targetSourceLang.toLowerCase())
        .toList();

    return roleQuestions.isNotEmpty ? roleQuestions : allQuestions;
  }

  /// Inserts a new quiz result into local storage.
  Future<void> saveQuizResult(QuizResult result) async {
    await _db.insert('quiz_results', result.toMap());
  }

  /// Retrieves recent quiz results, latest first.
  Future<List<QuizResult>> getQuizResults({int? limit}) async {
    final rows = await _db.query(
      'quiz_results',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return rows.map((r) => QuizResult.fromMap(r)).toList();
  }

  /// Calculates aggregate metrics for the Progress screen.
  Future<QuizMetricsSummary> getQuizMetrics() async {
    final results = await getQuizResults();
    if (results.isEmpty) {
      return const QuizMetricsSummary(
        totalQuizzesCompleted: 0,
        averageScore: 0.0,
        averageAccuracyPercent: 0.0,
        totalCorrectAnswers: 0,
        totalQuestionsAnswered: 0,
      );
    }

    int totalScore = 0;
    double totalAccuracy = 0.0;
    int totalCorrect = 0;
    int totalQuestions = 0;

    for (final res in results) {
      totalScore += res.score;
      totalAccuracy += res.accuracyPercent;
      totalCorrect += res.correctCount;
      totalQuestions += res.totalQuestions;
    }

    return QuizMetricsSummary(
      totalQuizzesCompleted: results.length,
      averageScore: totalScore / results.length,
      averageAccuracyPercent: totalAccuracy / results.length,
      totalCorrectAnswers: totalCorrect,
      totalQuestionsAnswered: totalQuestions,
    );
  }

  /// Deletes all quiz results.
  Future<void> clearQuizResults() async {
    await _db.delete('quiz_results');
  }
}
