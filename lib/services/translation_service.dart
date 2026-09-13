import '../models/translation_result.dart';

/// Abstract service contract for text translation.
/// Decouples the presentation layer from the underlying translation engine (Mock or BHASHINI).
abstract class TranslationService {
  /// Translates [text] from [sourceLang] to [targetLang].
  /// Throws [TranslationException] on failure or unsupported content.
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  });

  /// Identifies whether this service provider operates in demo/mock mode.
  bool get isDemo;
}

/// Domain exception thrown when translation encounters an error or unsupported input.
class TranslationException implements Exception {
  final String message;
  const TranslationException(this.message);

  @override
  String toString() => message;
}
