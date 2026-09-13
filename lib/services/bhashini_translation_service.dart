import 'package:http/http.dart' as http;
import '../models/translation_result.dart';
import 'api_translation_service.dart';
import 'translation_service.dart';

/// BHASHINI language translation service adapter.
/// Interfaces with Government of India BHASHINI pipeline via the BhashaSetu
/// FastAPI backend gateway.
class BhashiniTranslationService implements TranslationService {
  final String? backendUrl;
  final String? apiKey;
  final ApiTranslationService _apiService;

  BhashiniTranslationService({
    this.backendUrl,
    this.apiKey,
    http.Client? client,
    Duration timeout = const Duration(seconds: 10),
  }) : _apiService = ApiTranslationService(
          baseUrl: backendUrl,
          client: client,
          timeout: timeout,
        );

  @override
  bool get isDemo => false;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    return _apiService.translate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }
}

