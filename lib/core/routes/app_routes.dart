import 'package:flutter/material.dart';
import '../../screens/flashcards/flashcards_screen.dart';
import '../../screens/how_to_use/how_to_use_screen.dart';
import '../../screens/main_shell_screen.dart';
import '../../screens/ocr/scan_textbook_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/profile/profile_setup_screen.dart';
import '../../screens/quiz/quiz_selection_screen.dart';
import '../../screens/voice/voice_translation_screen.dart';

/// Central route definitions and generator for BhasaSetu.
abstract final class AppRoutes {
  static const String main = '/';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String howToUse = '/how-to-use';
  static const String flashcards = '/flashcards';
  static const String quizzes = '/quizzes';
  static const String voiceTranslation = '/voice-translation';
  static const String scanTextbook = '/scan-textbook';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShellScreen(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case profileSetup:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfileSetupScreen(),
          settings: settings,
        );
      case howToUse:
        return MaterialPageRoute<void>(
          builder: (_) => const HowToUseScreen(),
          settings: settings,
        );
      case flashcards:
        return MaterialPageRoute<void>(
          builder: (_) => const FlashcardsScreen(),
          settings: settings,
        );
      case quizzes:
        return MaterialPageRoute<void>(
          builder: (_) => const QuizSelectionScreen(),
          settings: settings,
        );
      case voiceTranslation:
        return MaterialPageRoute<void>(
          builder: (_) => const VoiceTranslationScreen(),
          settings: settings,
        );
      case scanTextbook:
        return MaterialPageRoute<void>(
          builder: (_) => const ScanTextbookScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShellScreen(),
          settings: settings,
        );
    }
  }
}
