import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhasa_setu/core/theme/app_theme.dart';
import 'package:bhasa_setu/data/database/app_database.dart';
import 'package:bhasa_setu/data/repositories/translation_history_repository.dart';
import 'package:bhasa_setu/main.dart';
import 'package:bhasa_setu/models/user_profile.dart';
import 'package:bhasa_setu/screens/ocr/scan_textbook_screen.dart';
import 'package:bhasa_setu/screens/voice/voice_translation_screen.dart';
import 'package:bhasa_setu/services/mock_translation_service.dart';
import 'package:bhasa_setu/services/ocr_service.dart';
import 'package:bhasa_setu/services/profile_storage_service.dart';
import 'package:bhasa_setu/services/speech_service.dart';
import 'package:bhasa_setu/services/tts_service.dart';

/// In-memory profile storage for test isolation.
class InMemoryProfileStorageService implements ProfileStorageService {
  UserProfile? storedProfile;

  InMemoryProfileStorageService([this.storedProfile]);

  @override
  Future<UserProfile?> getProfile() async => storedProfile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    storedProfile = profile;
  }

  @override
  Future<void> clearProfile() async {
    storedProfile = null;
  }

  @override
  Future<bool> hasProfile() async =>
      storedProfile != null && storedProfile!.fullName.trim().isNotEmpty;
}

void main() {
  setUp(() {
    AppDatabase.instance = InMemoryAppDatabase();
  });

  group('Stage 9: Voice Translation & Textbook OCR Verification', () {
    const teacherProfile = UserProfile(
      fullName: 'Vikram Sharma',
      role: UserRole.teacher,
      grade: 'Primary Grade 3',
      schoolName: 'Govt Primary School',
      gender: 'Male',
    );

    const studentProfile = UserProfile(
      fullName: 'Sunita Soren',
      role: UserRole.student,
      grade: 'Primary Grade 2',
      schoolName: 'Govt Primary School',
      gender: 'Female',
    );

    // TEST 1: Teacher Dashboard navigates to Voice Translation
    testWidgets('TEST 1: Teacher opens Voice Translation from Dashboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(storageService: storage));
      await tester.pumpAndSettle();

      final voiceCard = find.text('Voice Translation');
      expect(voiceCard, findsOneWidget);

      await tester.tap(voiceCard);
      await tester.pumpAndSettle();

      expect(find.byType(VoiceTranslationScreen), findsOneWidget);
      expect(find.text('Teacher Voice Mode'), findsOneWidget);
      expect(find.text('Hindi → Santhali'), findsWidgets);
    });

    // TEST 2: Student Dashboard navigates to Voice Translation
    testWidgets('TEST 2: Student opens Voice Translation with Santhali -> Hindi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(studentProfile);
      await tester.pumpWidget(BhasaSetuApp(storageService: storage));
      await tester.pumpAndSettle();

      final voiceCard = find.text('Voice Translation');
      expect(voiceCard, findsOneWidget);

      await tester.tap(voiceCard);
      await tester.pumpAndSettle();

      expect(find.byType(VoiceTranslationScreen), findsOneWidget);
      expect(find.text('Student Voice Mode'), findsOneWidget);
      expect(find.text('Santhali → Hindi'), findsWidgets);
    });

    // TEST 3: Teacher Voice Screen mic captures speech and translates
    testWidgets('TEST 3: Teacher speaks Hindi -> translates to Santhali Ol Chiki',
        (WidgetTester tester) async {
      final mockSpeech = MockSpeechService(simulatedText: 'नमस्ते');
      final mockTts = MockTtsService();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: teacherProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
            translationService: mockTrans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify microphone button is present
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      // Tap microphone
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Verify recognized text appeared
      expect(find.text('नमस्ते'), findsWidgets);

      // Verify Ol Chiki translation result rendered
      expect(find.text('Translation Result'), findsOneWidget);
      expect(find.text('ᱡᱚᱦᱟᱨ'), findsOneWidget);
      expect(find.text('Pronunciation: Johar'), findsOneWidget);
    });

    // TEST 4: Student Voice Screen shows honest notice for Santhali STT
    testWidgets('TEST 4: Student voice input shows transparent BHASHINI Stage 10 notice',
        (WidgetTester tester) async {
      final mockSpeech = MockSpeechService();
      final mockTts = MockTtsService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: studentProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Santhali STT limitation notice must be visible
      expect(
        find.textContaining('Santhali speech recognition pending BHASHINI (Stage 10)'),
        findsOneWidget,
      );

      // Tapping mic should show snackbar explanation
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();
      expect(
        find.textContaining('Santhali speech recognition is not supported'),
        findsOneWidget,
      );
    });

    // TEST 5: Quick classroom prompt chips work in Voice Translation
    testWidgets('TEST 5: Quick classroom prompt chips translate instantly',
        (WidgetTester tester) async {
      final mockSpeech = MockSpeechService();
      final mockTts = MockTtsService();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: teacherProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
            translationService: mockTrans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap quick prompt 'किताब खोलो'
      final promptChip = find.widgetWithText(ActionChip, 'किताब खोलो');
      expect(promptChip, findsOneWidget);

      await tester.tap(promptChip);
      await tester.pumpAndSettle();

      // Result should show translated Ol Chiki
      expect(find.text('ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ'), findsOneWidget);
      expect(find.text('Pronunciation: Puthi jhij me'), findsOneWidget);
    });

    // TEST 6: TTS audio playback in Student mode speaks authentic Hindi
    testWidgets('TEST 6: Student mode translates Santhali and plays Hindi TTS audio',
        (WidgetTester tester) async {
      final mockSpeech = MockSpeechService();
      final mockTts = MockTtsService();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: studentProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
            translationService: mockTrans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select student prompt 'ᱡᱚᱦᱟᱨ'
      final chip = find.widgetWithText(ActionChip, 'ᱡᱚᱦᱟᱨ');
      expect(chip, findsOneWidget);

      await tester.tap(chip);
      await tester.pumpAndSettle();

      // Translated text is 'नमस्ते'
      expect(find.text('नमस्ते'), findsWidgets);

      // Tap Play Audio button
      final audioBtn = find.text('Play Audio');
      expect(audioBtn, findsOneWidget);

      await tester.tap(audioBtn);
      await tester.pumpAndSettle();

      // Verify TTS was invoked with Hindi
      expect(mockTts.lastSpokenText, equals('नमस्ते'));
      expect(mockTts.lastSpokenLang, equals('Hindi'));
    });

    // TEST 7: Teacher mode audio playback shows transparent Stage 10 notice for Santhali
    testWidgets('TEST 7: Teacher mode audio button shows transparent Santhali notice',
        (WidgetTester tester) async {
      final mockSpeech = MockSpeechService();
      final mockTts = MockTtsService();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: teacherProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
            translationService: mockTrans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select teacher prompt
      await tester.tap(find.widgetWithText(ActionChip, 'नमस्ते'));
      await tester.pumpAndSettle();

      // Tap Play Audio button
      await tester.tap(find.text('Play Audio'));
      await tester.pumpAndSettle();

      // Transparent dialog must appear explaining Santhali TTS Stage 10 integration
      expect(find.text('Audio Notice'), findsOneWidget);
      expect(
        find.textContaining('Santhali voice synthesis is pending BHASHINI engine integration in Stage 10'),
        findsOneWidget,
      );

      // Dismiss dialog
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();
      expect(find.text('Audio Notice'), findsNothing);
    });

    // TEST 8: Teacher Dashboard navigates to Scan Textbook
    testWidgets('TEST 8: Teacher opens Scan Textbook from Dashboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(storageService: storage));
      await tester.pumpAndSettle();

      final scanCard = find.text('Scan Textbook');
      expect(scanCard, findsOneWidget);

      await tester.tap(scanCard);
      await tester.pumpAndSettle();

      expect(find.byType(ScanTextbookScreen), findsOneWidget);
      expect(find.text('Textbook OCR Mode'), findsOneWidget);
      expect(find.text('Hindi → Santhali'), findsWidgets);
    });

    // TEST 9: Student Dashboard navigates to Scan Textbook
    testWidgets('TEST 9: Student opens Scan Textbook with Santhali -> Hindi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(studentProfile);
      await tester.pumpWidget(BhasaSetuApp(storageService: storage));
      await tester.pumpAndSettle();

      final scanCard = find.text('Scan Textbook');
      expect(scanCard, findsOneWidget);

      await tester.tap(scanCard);
      await tester.pumpAndSettle();

      expect(find.byType(ScanTextbookScreen), findsOneWidget);
      expect(find.text('Student Book Scanner'), findsOneWidget);
      expect(find.text('Santhali → Hindi'), findsWidgets);
    });

    // TEST 10: Scan Textbook displays Camera, Gallery, and Sample buttons
    testWidgets('TEST 10: Scan Textbook displays Camera, Gallery, and Samples',
        (WidgetTester tester) async {
      final mockOcr = MockOcrService();
      final mockTts = MockTtsService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ScanTextbookScreen(
            profile: teacherProfile,
            ocrService: mockOcr,
            ttsService: mockTts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Sample Primary Textbook Passages'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    // TEST 11: Scan Textbook sample selection extracts and translates text
    testWidgets('TEST 11: Selecting sample textbook page extracts text and translates',
        (WidgetTester tester) async {
      final mockOcr = MockOcrService();
      final mockTts = MockTtsService();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ScanTextbookScreen(
            profile: teacherProfile,
            ocrService: mockOcr,
            ttsService: mockTts,
            translationService: mockTrans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first sample chip 'Class 1 Hindi: Classroom Instructions'
      final sampleChip = find.widgetWithText(
        ChoiceChip,
        'Class 1 Hindi: Classroom Instructions',
      );
      expect(sampleChip, findsOneWidget);

      await tester.tap(sampleChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Extracted text should be in the text field
      expect(find.text('किताब खोलो'), findsWidgets);

      // Translation result should be displayed
      expect(find.text('Textbook Translation'), findsOneWidget);
      expect(find.text('ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ'), findsOneWidget);
      expect(find.text('Pronunciation: Puthi jhij me'), findsOneWidget);
    });

    // TEST 12: Scan Textbook displays honest Ol Chiki OCR notice
    testWidgets('TEST 12: Scan Textbook displays Ol Chiki vision notice',
        (WidgetTester tester) async {
      final mockOcr = MockOcrService();
      final mockTts = MockTtsService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ScanTextbookScreen(
            profile: studentProfile,
            ocrService: mockOcr,
            ttsService: mockTts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ol Chiki textbook script OCR is pending native BHASHINI vision pipeline in Stage 10'),
        findsOneWidget,
      );
    });

    // TEST 13: Voice and OCR translations are saved into persistent history
    testWidgets('TEST 13: Translations persist to TranslationHistoryRepository',
        (WidgetTester tester) async {
      final historyRepo = TranslationHistoryRepository();
      final mockTrans = const MockTranslationService(simulatedDelay: Duration.zero);
      final mockSpeech = MockSpeechService(simulatedText: 'पानी');
      final mockTts = MockTtsService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: VoiceTranslationScreen(
            profile: teacherProfile,
            speechService: mockSpeech,
            ttsService: mockTts,
            translationService: mockTrans,
            historyRepository: historyRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger speech
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Verify history count increased
      final recent = await historyRepo.getRecentTranslations();
      expect(recent.isNotEmpty, isTrue);
      expect(recent.first.sourceText, equals('पानी'));
      expect(recent.first.translatedText, equals('ᱫᱟᱜ'));
    });
  });
}
