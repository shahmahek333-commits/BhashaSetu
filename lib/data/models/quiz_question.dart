import 'dart:convert';

/// Quiz question types supported in BhasaSetu.
enum QuizType {
  multipleChoice,
  matchTheWord,
  listenAndChoose,
  imageVocabulary;

  String get dbValue {
    switch (this) {
      case QuizType.multipleChoice:
        return 'multiple_choice';
      case QuizType.matchTheWord:
        return 'match_the_word';
      case QuizType.listenAndChoose:
        return 'listen_and_choose';
      case QuizType.imageVocabulary:
        return 'image_vocabulary';
    }
  }

  static QuizType fromString(String? value) {
    switch (value) {
      case 'match_the_word':
        return QuizType.matchTheWord;
      case 'listen_and_choose':
        return QuizType.listenAndChoose;
      case 'image_vocabulary':
        return QuizType.imageVocabulary;
      case 'multiple_choice':
      default:
        return QuizType.multipleChoice;
    }
  }
}

/// Model representing a quiz question stored locally in SQLite.
class QuizQuestion {
  final String id;
  final QuizType questionType;
  final String questionText;
  final String sourceLanguage;
  final String targetLanguage;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String? assetHint; // Icon name or safe asset reference for image quizzes

  const QuizQuestion({
    required this.id,
    required this.questionType,
    required this.questionText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.assetHint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_type': questionType.dbValue,
      'question_text': questionText,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'options_json': json.encode(options),
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'asset_hint': assetHint,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String> parsedOptions = [];
    if (map['options_json'] != null) {
      try {
        final decoded = json.decode(map['options_json'] as String);
        if (decoded is List) {
          parsedOptions = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedOptions = [];
      }
    }

    return QuizQuestion(
      id: map['id'] as String? ?? '',
      questionType: QuizType.fromString(map['question_type'] as String?),
      questionText: map['question_text'] as String? ?? '',
      sourceLanguage: map['source_language'] as String? ?? 'Hindi',
      targetLanguage: map['target_language'] as String? ?? 'Santhali',
      options: parsedOptions,
      correctAnswer: map['correct_answer'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      assetHint: map['asset_hint'] as String?,
    );
  }
}
