import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstract contract for Text-To-Speech audio services.
abstract class TtsService {
  /// Whether the TTS engine is currently speaking audio.
  bool get isSpeaking;

  /// Checks if a language has native TTS synthesis support.
  /// Hindi ('hi' / 'hi-IN') is supported.
  /// Santhali ('sat') is not supported by standard engines and will be connected via BHASHINI in Stage 10.
  bool isLanguageSupported(String language);

  /// Status notice regarding audio support.
  String getLanguageNotice(String language);

  /// Initializes the TTS engine.
  Future<bool> initialize();

  /// Speaks the provided [text] in [languageCode].
  /// Returns `true` if playback started, `false` if unsupported or failed.
  Future<bool> speak({
    required String text,
    required String languageCode,
  });

  /// Stops current speech playback.
  Future<void> stop();

  /// Releases resources.
  void dispose();
}

/// Standard implementation of [TtsService] using package:flutter_tts.
class AppTtsService implements TtsService {
  final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isInitialized = false;

  AppTtsService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool isLanguageSupported(String language) {
    final lower = language.toLowerCase();
    return lower.contains('hindi') || lower.startsWith('hi');
  }

  @override
  String getLanguageNotice(String language) {
    if (isLanguageSupported(language)) {
      return 'Hindi speech synthesis ready.';
    } else {
      return 'Santhali voice synthesis is pending BHASHINI engine integration in Stage 10. '
          'Hindi speech playback is available.';
    }
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        debugPrint('TtsService error: $msg');
        _isSpeaking = false;
      });

      // Default settings
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('TtsService initialization error: $e');
      return false;
    }
  }

  @override
  Future<bool> speak({
    required String text,
    required String languageCode,
  }) async {
    if (!isLanguageSupported(languageCode)) {
      debugPrint('Language $languageCode is not supported for native TTS');
      return false;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      final lang = languageCode.toLowerCase().contains('hindi') ? 'hi-IN' : languageCode;
      await _flutterTts.setLanguage(lang);
      _isSpeaking = true;
      final result = await _flutterTts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TtsService speak error: $e');
      _isSpeaking = false;
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TtsService stop error: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
  }
}

/// Mock TTS service for unit and widget tests.
class MockTtsService implements TtsService {
  bool _isSpeaking = false;
  String? lastSpokenText;
  String? lastSpokenLang;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool isLanguageSupported(String language) {
    final lower = language.toLowerCase();
    return lower.contains('hindi') || lower.startsWith('hi');
  }

  @override
  String getLanguageNotice(String language) {
    if (isLanguageSupported(language)) {
      return 'Hindi speech synthesis ready.';
    } else {
      return 'Santhali voice synthesis is pending BHASHINI engine integration in Stage 10. '
          'Hindi speech playback is available.';
    }
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> speak({
    required String text,
    required String languageCode,
  }) async {
    if (!isLanguageSupported(languageCode)) {
      return false;
    }
    lastSpokenText = text;
    lastSpokenLang = languageCode;
    _isSpeaking = true;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _isSpeaking = false;
    return true;
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
  }

  @override
  void dispose() {
    _isSpeaking = false;
  }
}
