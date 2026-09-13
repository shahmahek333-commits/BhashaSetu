/// Model representing the result of a completed quiz session stored in SQLite.
class QuizResult {
  final String id;
  final String quizType;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final double accuracyPercent;
  final String userRole;
  final DateTime completedAt;

  const QuizResult({
    required this.id,
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracyPercent,
    required this.userRole,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_type': quizType,
      'score': score,
      'total_questions': totalQuestions,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'accuracy_percent': accuracyPercent,
      'user_role': userRole,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as String? ?? '',
      quizType: map['quiz_type'] as String? ?? 'multiple_choice',
      score: map['score'] as int? ?? 0,
      totalQuestions: map['total_questions'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      wrongCount: map['wrong_count'] as int? ?? 0,
      accuracyPercent: (map['accuracy_percent'] is num)
          ? (map['accuracy_percent'] as num).toDouble()
          : 0.0,
      userRole: map['user_role'] as String? ?? 'teacher',
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
