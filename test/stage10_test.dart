import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bhasa_setu/services/api_translation_service.dart';
import 'package:bhasa_setu/services/bhashini_translation_service.dart';
import 'package:bhasa_setu/services/mock_translation_service.dart';
import 'package:bhasa_setu/services/translation_service.dart';

void main() {
  group('Stage 10: FastAPI Backend & BHASHINI Integration Architecture Tests', () {
    test('TEST 1: ApiTranslationService sends valid payload and parses 200 OK response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/translate'));
        expect(request.method, equals('POST'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['source_language'], equals('hi'));
        expect(body['target_language'], equals('sat'));
        expect(body['text'], equals('नमस्ते'));

        return http.Response(
          jsonEncode({
            'source_language': 'hi',
            'target_language': 'sat',
            'source_text': 'नमस्ते',
            'translated_text': 'ᱡᱚᱦᱟᱨ',
            'status': 'success',
            'provider': 'BHASHINI-Dhruva',
            'phonetic_guide': 'Johar',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiTranslationService(
        baseUrl: 'http://127.0.0.1:8000',
        client: mockClient,
      );

      final result = await service.translate(
        text: 'नमस्ते',
        sourceLang: 'Hindi',
        targetLang: 'Santhali',
      );

      expect(result.sourceText, equals('नमस्ते'));
      expect(result.translatedText, equals('ᱡᱚᱦᱟᱨ'));
      expect(result.isDemo, isFalse);
      expect(result.badge, equals('BHASHINI-Dhruva'));
      expect(result.phoneticGuide, equals('Johar'));
    });

    test('TEST 2: ApiTranslationService throws TranslationException on empty text input', () async {
      final service = ApiTranslationService();

      expect(
        () => service.translate(text: '   ', sourceLang: 'Hindi', targetLang: 'Santhali'),
        throwsA(isA<TranslationException>().having(
          (e) => e.message,
          'message',
          contains('Please enter text to translate'),
        )),
      );
    });

    test('TEST 3: ApiTranslationService correctly handles 503 unconfigured BHASHINI response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'detail': {
              'message': 'BHASHINI API is not configured on this server. Please set BHASHINI_USER_ID, BHASHINI_API_KEY, and BHASHINI_PIPELINE_ID in environment variables.',
              'error_code': 'BHASHINI_NOT_CONFIGURED',
              'suggested_action': 'Switch to Demo Translation mode in the Flutter app.',
            }
          }),
          503,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiTranslationService(
        baseUrl: 'http://127.0.0.1:8000',
        client: mockClient,
      );

      expect(
        () => service.translate(text: 'किताब खोलो', sourceLang: 'Hindi', targetLang: 'Santhali'),
        throwsA(isA<TranslationException>().having(
          (e) => e.message,
          'message',
          contains('BHASHINI API is not configured on this server'),
        )),
      );
    });

    test('TEST 4: ApiTranslationService falls back to MockTranslationService when configured', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'detail': {
              'message': 'BHASHINI API is not configured on this server.',
              'error_code': 'BHASHINI_NOT_CONFIGURED',
            }
          }),
          503,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiTranslationService(
        baseUrl: 'http://127.0.0.1:8000',
        client: mockClient,
        autoFallbackToDemo: true,
        fallbackService: const MockTranslationService(simulatedDelay: Duration.zero),
      );

      final result = await service.translate(
        text: 'किताब खोलो',
        sourceLang: 'Hindi',
        targetLang: 'Santhali',
      );

      expect(result.sourceText, equals('किताब खोलो'));
      expect(result.translatedText, equals('ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ'));
      expect(result.isDemo, isTrue);
      expect(result.badge, equals('Demo Translation'));
    });

    test('TEST 5: ApiTranslationService handles network failure gracefully', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });

      final service = ApiTranslationService(
        baseUrl: 'http://127.0.0.1:8000',
        client: mockClient,
      );

      expect(
        () => service.translate(text: 'नमस्ते', sourceLang: 'Hindi', targetLang: 'Santhali'),
        throwsA(isA<TranslationException>().having(
          (e) => e.message,
          'message',
          contains('Unable to connect to translation server'),
        )),
      );
    });

    test('TEST 6: BhashiniTranslationService delegates to ApiTranslationService', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'source_language': 'sat',
            'target_language': 'hi',
            'source_text': 'ᱫᱟᱜ',
            'translated_text': 'पानी',
            'status': 'success',
            'provider': 'BHASHINI-Dhruva',
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final bhashini = BhashiniTranslationService(
        backendUrl: 'http://127.0.0.1:8000',
        client: mockClient,
      );

      final result = await bhashini.translate(
        text: 'ᱫᱟᱜ',
        sourceLang: 'Santhali',
        targetLang: 'Hindi',
      );

      expect(result.translatedText, equals('पानी'));
      expect(result.isDemo, isFalse);
    });

    test('TEST 7: MockTranslationService remains available and offline-ready', () async {
      const mock = MockTranslationService(simulatedDelay: Duration.zero);
      expect(mock.isDemo, isTrue);

      final res = await mock.translate(
        text: 'नमस्ते',
        sourceLang: 'Hindi',
        targetLang: 'Santhali',
      );
      expect(res.translatedText, equals('ᱡᱚᱦᱟᱨ'));
      expect(res.isDemo, isTrue);
    });
  });
}
