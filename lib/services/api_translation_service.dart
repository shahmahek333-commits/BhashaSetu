import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/translation_result.dart';
import 'translation_service.dart';

/// Translation service implementation connecting Flutter to the BhasaSetu
/// FastAPI backend gateway (`POST /api/translate`).
///
/// Designed to interact with the Government of India BHASHINI pipeline
/// via the backend server, with robust error handling for unconfigured states,
/// network timeouts, and offline scenarios.
class ApiTranslationService implements TranslationService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  final bool autoFallbackToDemo;
  final TranslationService? fallbackService;

  ApiTranslationService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.autoFallbackToDemo = false,
    this.fallbackService,
  })  : baseUrl = baseUrl ?? 'http://127.0.0.1:8000',
        _client = client ?? http.Client();

  @override
  bool get isDemo => false;

  /// Normalizes language display name or code into BHASHINI / Dhruva language code
  static String normalizeLang(String lang) {
    final lower = lang.trim().toLowerCase();
    if (lower.contains('hindi') || lower == 'hi') return 'hi';
    if (lower.contains('santhali') || lower.contains('ol chiki') || lower == 'sat') return 'sat';
    if (lower.contains('english') || lower == 'en') return 'en';
    return lower;
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) {
      throw const TranslationException('Please enter text to translate.');
    }

    final url = Uri.parse('$baseUrl/api/translate');
    final payload = {
      'source_language': normalizeLang(sourceLang),
      'target_language': normalizeLang(targetLang),
      'text': cleaned,
    };

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return TranslationResult(
          sourceText: cleaned,
          translatedText: data['translated_text'] as String? ?? '',
          sourceLang: sourceLang,
          targetLang: targetLang,
          isDemo: false,
          badge: data['provider'] as String? ?? 'BHASHINI',
          timestamp: DateTime.now(),
          phoneticGuide: data['phonetic_guide'] as String?,
        );
      }

      if (response.statusCode == 503) {
        // Backend reported BHASHINI credentials not configured
        if (autoFallbackToDemo && fallbackService != null) {
          return await fallbackService!.translate(
            text: text,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
        }
        try {
          final Map<String, dynamic> errData =
              jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          final detail = errData['detail'];
          final msg = (detail is Map && detail['message'] != null)
              ? detail['message'].toString()
              : 'BHASHINI API is not configured on this server. Please switch to Demo Translation mode.';
          throw TranslationException(msg);
        } catch (e) {
          if (e is TranslationException) rethrow;
          throw const TranslationException(
            'BHASHINI API is not configured on this server. Please switch to Demo Translation mode.',
          );
        }
      }

      if (response.statusCode == 422) {
        throw const TranslationException('Invalid translation request parameters.');
      }

      throw TranslationException(
        'Server returned error (${response.statusCode}): ${response.body}',
      );
    } on TimeoutException {
      if (autoFallbackToDemo && fallbackService != null) {
        return await fallbackService!.translate(
          text: text,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
      }
      throw TranslationException(
        'Translation request timed out after ${timeout.inSeconds} seconds. Check server connectivity.',
      );
    } on TranslationException {
      rethrow;
    } catch (e) {
      if (autoFallbackToDemo && fallbackService != null) {
        return await fallbackService!.translate(
          text: text,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
      }
      throw TranslationException(
        'Unable to connect to translation server at $baseUrl: $e',
      );
    }
  }

  /// Closes underlying HTTP client if created internally
  void dispose() {
    _client.close();
  }
}
