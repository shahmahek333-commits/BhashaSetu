import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Lifecycle states of the speech-to-text engine.
enum SpeechStatus {
  idle,
  initializing,
  ready,
  listening,
  processing,
  done,
  error,
  unsupported,
}

/// Abstract contract for speech recognition services.
/// Decouples UI widgets from underlying platform plugins and allows testing.
abstract class SpeechService {
  /// Current status of the speech engine.
  SpeechStatus get status;

  /// Whether the microphone is actively capturing audio.
  bool get isListening;

  /// Whether the engine has been successfully initialized.
  bool get isAvailable;

  /// Checks if a language is natively supported for speech recognition.
  /// Hindi ('hi' / 'hi-IN') is supported on Android/Web.
  /// Santhali ('sat' / 'sat-IN') is not supported by standard engines and requires BHASHINI.
  bool isLanguageSupported(String language);

  /// Informative message explaining language engine availability.
  String getLanguageNotice(String language);

  /// Initializes the speech recognition engine.
  Future<bool> initialize();

  /// Starts listening for speech in the specified [languageCode].
  Future<void> startListening({
    required String languageCode,
    required void Function(String words, bool isFinal) onResult,
    required void Function(String error) onError,
    void Function(SpeechStatus status)? onStatusChange,
  });

  /// Stops capturing speech.
  Future<void> stopListening();

  /// Cancels the current capture session.
  Future<void> cancelListening();

  /// Releases resources.
  void dispose();
}

/// Standard implementation of [SpeechService] using package:speech_to_text.
class AppSpeechService implements SpeechService {
  final stt.SpeechToText _speech;
  SpeechStatus _status = SpeechStatus.idle;
  bool _isAvailable = false;

  AppSpeechService({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  @override
  SpeechStatus get status => _status;

  @override
  bool get isListening => _speech.isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool isLanguageSupported(String language) {
    final lower = language.toLowerCase();
    // Hindi is supported by Android Google Speech and Web Speech API
    if (lower.contains('hindi') || lower.startsWith('hi')) {
      return true;
    }
    // Santhali is NOT supported by standard Google Speech or Chrome engines
    return false;
  }

  @override
  String getLanguageNotice(String language) {
    if (isLanguageSupported(language)) {
      return 'Voice recognition active (hi-IN). Speak clearly into your microphone.';
    } else {
      return 'Santhali speech recognition is not supported by standard mobile/browser engines. '
          'Native Ol Chiki voice recognition will be integrated via BHASHINI in Stage 10. '
          'You can type or select sample phrases below.';
    }
  }

  @override
  Future<bool> initialize() async {
    if (_isAvailable) return true;
    _status = SpeechStatus.initializing;
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('SpeechService error: ${val.errorMsg}');
          _status = SpeechStatus.error;
        },
        onStatus: (val) {
          debugPrint('SpeechService status: $val');
          if (val == 'listening') {
            _status = SpeechStatus.listening;
          } else if (val == 'notListening' || val == 'done') {
            _status = SpeechStatus.done;
          }
        },
      );
      _status = _isAvailable ? SpeechStatus.ready : SpeechStatus.unsupported;
      return _isAvailable;
    } catch (e) {
      debugPrint('SpeechService initialization exception: $e');
      _status = SpeechStatus.error;
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required void Function(String words, bool isFinal) onResult,
    required void Function(String error) onError,
    void Function(SpeechStatus status)? onStatusChange,
  }) async {
    if (!isLanguageSupported(languageCode)) {
      _status = SpeechStatus.unsupported;
      onStatusChange?.call(_status);
      onError(getLanguageNotice(languageCode));
      return;
    }

    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        _status = SpeechStatus.error;
        onStatusChange?.call(_status);
        onError('Microphone or speech recognition service is unavailable.');
        return;
      }
    }

    try {
      _status = SpeechStatus.listening;
      onStatusChange?.call(_status);

      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          onResult(words, result.finalResult);
          if (result.finalResult) {
            _status = SpeechStatus.done;
            onStatusChange?.call(_status);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
        ),
        // ignore: deprecated_member_use
        localeId: languageCode.toLowerCase().contains('hindi') ? 'hi_IN' : languageCode,
        // ignore: deprecated_member_use
        listenFor: const Duration(seconds: 20),
        // ignore: deprecated_member_use
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('SpeechService startListening error: $e');
      _status = SpeechStatus.error;
      onStatusChange?.call(_status);
      onError('Failed to capture speech: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      _status = SpeechStatus.done;
    }
  }

  @override
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
      _status = SpeechStatus.idle;
    }
  }

  @override
  void dispose() {
    _speech.stop();
  }
}

/// Lightweight mock speech service for automated unit & widget tests.
class MockSpeechService implements SpeechService {
  SpeechStatus _status = SpeechStatus.ready;
  bool _isListening = false;
  final bool simulateAvailable;
  final String simulatedText;

  MockSpeechService({
    this.simulateAvailable = true,
    this.simulatedText = 'नमस्ते',
  });

  @override
  SpeechStatus get status => _status;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => simulateAvailable;

  @override
  bool isLanguageSupported(String language) {
    final lower = language.toLowerCase();
    return lower.contains('hindi') || lower.startsWith('hi');
  }

  @override
  String getLanguageNotice(String language) {
    if (isLanguageSupported(language)) {
      return 'Voice recognition active (hi-IN). Speak clearly into your microphone.';
    } else {
      return 'Santhali speech recognition is not supported by standard mobile/browser engines. '
          'Native Ol Chiki voice recognition will be integrated via BHASHINI in Stage 10. '
          'You can type or select sample phrases below.';
    }
  }

  @override
  Future<bool> initialize() async {
    _status = simulateAvailable ? SpeechStatus.ready : SpeechStatus.unsupported;
    return simulateAvailable;
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required void Function(String words, bool isFinal) onResult,
    required void Function(String error) onError,
    void Function(SpeechStatus status)? onStatusChange,
  }) async {
    if (!isLanguageSupported(languageCode)) {
      _status = SpeechStatus.unsupported;
      onStatusChange?.call(_status);
      onError(getLanguageNotice(languageCode));
      return;
    }

    _isListening = true;
    _status = SpeechStatus.listening;
    onStatusChange?.call(_status);

    // Simulate recognition
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_isListening) {
      onResult(simulatedText, true);
      _status = SpeechStatus.done;
      _isListening = false;
      onStatusChange?.call(_status);
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _status = SpeechStatus.done;
  }

  @override
  Future<void> cancelListening() async {
    _isListening = false;
    _status = SpeechStatus.idle;
  }

  @override
  void dispose() {
    _isListening = false;
  }
}
