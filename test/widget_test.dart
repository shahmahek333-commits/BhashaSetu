import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhasa_setu/core/state/profile_controller.dart';
import 'package:bhasa_setu/core/theme/app_theme.dart';
import 'package:bhasa_setu/data/database/app_database.dart';
import 'package:bhasa_setu/data/models/quiz_question.dart';
import 'package:bhasa_setu/data/models/quiz_result.dart';
import 'package:bhasa_setu/data/models/translation_history_item.dart';
import 'package:bhasa_setu/data/repositories/flashcard_repository.dart';
import 'package:bhasa_setu/data/repositories/quiz_repository.dart';
import 'package:bhasa_setu/data/repositories/translation_history_repository.dart';
import 'package:bhasa_setu/data/repositories/user_repository.dart';
import 'package:bhasa_setu/main.dart';
import 'package:bhasa_setu/models/user_profile.dart';
import 'package:bhasa_setu/screens/flashcards/flashcards_screen.dart';
import 'package:bhasa_setu/screens/quiz/quiz_play_screen.dart';
import 'package:bhasa_setu/screens/translate/translate_screen.dart';
import 'package:bhasa_setu/services/profile_storage_service.dart';

/// In-memory storage service for robust, isolated test execution.
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

  const teacherProfile = UserProfile(
    fullName: 'Sunita Devi',
    role: UserRole.teacher,
    grade: 'Class 3 (Grade 3)',
    schoolName: 'Govt Primary School Dumka',
  );

  const studentProfile = UserProfile(
    fullName: 'Raju Soren',
    role: UserRole.student,
    grade: 'Class 2 (Grade 2)',
    schoolName: 'Tribal Residential School',
  );

  group('Stage 4: Teacher & Student Dashboards Verification', () {
    testWidgets('TEST 1 & 3: Teacher Profile -> Teacher Dashboard appears with Hindi -> Santhali',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t1'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Teacher Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Sunita Devi!'), findsOneWidget);
      expect(find.text('Govt Primary School Dumka • Class 3 (Grade 3)'), findsOneWidget);
      expect(find.text('Teacher Mode: Hindi → Santhali'), findsOneWidget);
      expect(find.text('Classroom Phrases'), findsOneWidget);
      expect(find.text('Pronunciation Guide'), findsOneWidget);
    });

    testWidgets('TEST 2 & 4: Student Profile -> Student Dashboard appears with Santhali -> Hindi',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(studentProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t2'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Student Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Raju Soren!'), findsOneWidget);
      expect(find.text('Tribal Residential School • Class 2 (Grade 2)'), findsOneWidget);
      expect(find.text('Student Mode: Santhali → Hindi'), findsOneWidget);
      expect(find.text('Learn Words'), findsOneWidget);
    });

    testWidgets('TEST 5: Teacher and Student feature cards are distinct',
        (WidgetTester tester) async {
      final teacherStorage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t5_teacher'),
        storageService: teacherStorage,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Classroom Phrases'), findsOneWidget);
      expect(find.text('Pronunciation Guide'), findsOneWidget);
      expect(find.text('Learn Words'), findsNothing);

      final studentStorage = InMemoryProfileStorageService(studentProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t5_student'),
        storageService: studentStorage,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Learn Words'), findsOneWidget);
      expect(find.text('Classroom Phrases'), findsNothing);
      expect(find.text('Pronunciation Guide'), findsNothing);
    });

    testWidgets('TEST 6: Bottom navigation transitions across all 5 destinations',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t6'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final translateTab = find.widgetWithText(NavigationDestination, 'Translate');
      await tester.tap(translateTab);
      await tester.pumpAndSettle();
      expect(find.text('Translation Hub'), findsOneWidget);

      final learnTab = find.widgetWithText(NavigationDestination, 'Learn');
      await tester.tap(learnTab);
      await tester.pumpAndSettle();
      expect(find.text('Learning Hub'), findsOneWidget);

      final progressTab = find.widgetWithText(NavigationDestination, 'Progress');
      await tester.tap(progressTab);
      await tester.pumpAndSettle();
      expect(find.text('Learning Progress'), findsOneWidget);

      final profileTab = find.widgetWithText(NavigationDestination, 'Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
      expect(find.text('User Profile'), findsOneWidget);

      final homeTab = find.widgetWithText(NavigationDestination, 'Home');
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      expect(find.text('Teacher Dashboard'), findsOneWidget);
    });

    testWidgets('TEST 7: Profile page still works and displays saved user details',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t7'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final profileTab = find.widgetWithText(NavigationDestination, 'Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      expect(find.text('Sunita Devi'), findsOneWidget);
      expect(find.text('Govt Primary School Dumka'), findsOneWidget);
      expect(find.text('Class 3 (Grade 3)'), findsOneWidget);
      expect(find.text('Edit Profile Information'), findsOneWidget);
    });

    testWidgets('TEST 8: How to Use remains accessible from Dashboard',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t8'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('How to Use'));
      await tester.pumpAndSettle();

      expect(find.text('How to Use BhashaSetu'), findsOneWidget);
      expect(find.text('Step 1: Create your profile'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Teacher Dashboard'), findsOneWidget);
    });

    testWidgets('TEST 9: Deferred module placeholder navigation works without errors',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t9'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Pronunciation Guide'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pronunciation Guide'));
      await tester.pumpAndSettle();

      expect(find.text('Scheduled for Stage 8'), findsOneWidget);
      expect(find.text('Back to Dashboard'), findsOneWidget);

      await tester.tap(find.text('Back to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Teacher Dashboard'), findsOneWidget);
    });

    testWidgets('TEST 10: Dashboard is responsive across different screen sizes without overflow',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t10_mobile'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st4_t10_desktop'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Stage 5: Demo Translation Verification', () {
    testWidgets('TEST 1 & 8: Teacher profile -> Hindi input -> Demo Translation -> Santhali output',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t1'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      // Open Translate tab
      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Verify Direction: Teacher starts with Hindi -> Santhali
      expect(find.text('Hindi'), findsWidgets);
      expect(find.text('Santhali'), findsWidgets);

      // Enter Hindi text
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'नमस्ते');
      await tester.pumpAndSettle();

      // Tap Translate button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Translate'));
      await tester.pumpAndSettle();

      // Verify Demo Translation badge is clearly displayed
      expect(find.text('Demo Translation'), findsOneWidget);

      // Verify Santhali translated output
      expect(find.text('ᱡᱚᱦᱟᱨ'), findsOneWidget);
      expect(find.text('Phonetics: Johar'), findsOneWidget);

      // Verify Teacher role remains Hindi -> Santhali on Home dashboard
      await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
      await tester.pumpAndSettle();
      expect(find.text('Teacher Mode: Hindi → Santhali'), findsOneWidget);
    });

    testWidgets('TEST 2 & 9: Student profile -> Santhali input -> Demo Translation -> Hindi output',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(studentProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t2'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      // Open Translate
      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Verify Direction: Student starts with Santhali -> Hindi
      expect(find.text('Santhali'), findsWidgets);
      expect(find.text('Hindi'), findsWidgets);

      // Enter Santhali text
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'johar');
      await tester.pumpAndSettle();

      // Tap Translate
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      // Verify Demo Translation badge
      expect(find.text('Demo Translation'), findsOneWidget);

      // Verify Hindi translated output
      expect(find.text('नमस्ते'), findsOneWidget);

      // Verify Student role remains Santhali -> Hindi on Home dashboard
      await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
      await tester.pumpAndSettle();
      expect(find.text('Student Mode: Santhali → Hindi'), findsOneWidget);
    });

    testWidgets('TEST 3: Empty input shows validation message',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t3'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Tap Translate without entering text
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter text to translate.'), findsOneWidget);
    });

    testWidgets('TEST 4: Clear button clears input and result',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t4'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Enter and translate
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'किताब खोलो');
      await tester.pumpAndSettle();

      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      expect(find.text('Demo Translation'), findsOneWidget);

      // Tap Clear
      final clearBtn = find.widgetWithText(OutlinedButton, 'Clear');
      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      // Active result is cleared
      expect(find.text('Demo Translation'), findsNothing);
      // Input text is cleared
      final tf = tester.widget<TextField>(inputFinder);
      expect(tf.controller?.text.isEmpty, isTrue);
    });

    testWidgets('TEST 5: Copy button copies translated text with user confirmation',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t5'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'पानी');
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      expect(find.text('ᱫᱟᱜ'), findsWidgets);

      // Ensure visible and tap Copy button
      final copyBtn = find.byTooltip('Copy Translation');
      await tester.ensureVisible(copyBtn);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();

      expect(find.text('Translation copied to clipboard.'), findsOneWidget);
    });

    testWidgets('TEST 6: Unsupported phrase shows clear demo-unavailable message',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t6'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Enter an unsupported sentence
      await tester.enterText(find.byType(TextField), 'रॉकेट अंतरिक्ष में जा रहा है');
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      // Must NOT invent fake Santhali words
      expect(
        find.text('Demo translation is not available for this phrase yet.'),
        findsOneWidget,
      );
      expect(find.text('Demo Translation'), findsNothing);
    });

    testWidgets('TEST 7: Translation history updates with new translations',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t7'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Translate'));
      await tester.pumpAndSettle();

      // Initially empty history
      expect(find.text('No translation history yet. Enter a phrase above to see it recorded here.'),
          findsOneWidget);

      // Translate phrase
      await tester.enterText(find.byType(TextField), 'ध्यान से सुनो');
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.ensureVisible(translateBtn);
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      // Scroll to history section and verify
      final clearHistoryFinder = find.text('Clear History');
      await tester.ensureVisible(clearHistoryFinder);
      expect(clearHistoryFinder, findsOneWidget);
      expect(find.text('Hindi → Santhali'), findsWidgets);
    });

    testWidgets('TEST 10: Navigation between Dashboard, Translate, Profile works seamlessly',
        (WidgetTester tester) async {
      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st5_t10'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      // 1. Dashboard -> Translate button
      await tester.tap(find.text('Translate').first);
      await tester.pumpAndSettle();
      expect(find.text('Translation Hub'), findsOneWidget);

      // 2. Translate -> Profile tab
      await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
      await tester.pumpAndSettle();
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Sunita Devi'), findsOneWidget);

      // 3. Profile -> Home tab
      await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
      await tester.pumpAndSettle();
      expect(find.text('Teacher Dashboard'), findsOneWidget);
    });
  });

  group('Stage 6 & Stage 7: Local Storage, Flashcards & Quizzes Verification', () {
    test('TEST 1: Create/load profile -> close/restart app -> profile remains saved in local storage', () async {
      final db = InMemoryAppDatabase();
      final userRepo = UserRepository(db: db);
      final profileService = DatabaseProfileStorageService(userRepository: userRepo);

      await profileService.saveProfile(teacherProfile);

      // Simulate app restart by creating a new repository/service instance over the same persistent db
      final userRepoAfterRestart = UserRepository(db: db);
      final profileServiceAfterRestart = DatabaseProfileStorageService(userRepository: userRepoAfterRestart);

      final loadedProfile = await profileServiceAfterRestart.getProfile();
      expect(loadedProfile, isNotNull);
      expect(loadedProfile!.fullName, equals('Sunita Devi'));
      expect(loadedProfile.role, equals(UserRole.teacher));
      expect(loadedProfile.schoolName, equals('Govt Primary School Dumka'));
    });

    test('TEST 2: Create translation -> restart app -> translation history remains', () async {
      final db = InMemoryAppDatabase();
      final historyRepo = TranslationHistoryRepository(db: db);

      await historyRepo.saveTranslation(TranslationHistoryItem(
        sourceText: 'नमस्ते',
        translatedText: 'ᱡᱚᱦᱟᱨ',
        sourceLanguage: 'Hindi',
        targetLanguage: 'Santhali',
        createdAt: DateTime.now(),
      ));

      // Simulate restart
      final historyRepoAfterRestart = TranslationHistoryRepository(db: db);
      final items = await historyRepoAfterRestart.getRecentTranslations();

      expect(items.length, equals(1));
      expect(items.first.sourceText, equals('नमस्ते'));
      expect(items.first.translatedText, equals('ᱡᱚᱦᱟᱨ'));
    });

    testWidgets('TEST 3: Open Flashcards -> display demo cards', (WidgetTester tester) async {
      final db = InMemoryAppDatabase();
      await db.init();
      final flashcardRepo = FlashcardRepository(db: db);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: FlashcardsScreen(repository: flashcardRepo),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bilingual Flashcards'), findsOneWidget);
      expect(find.text('Santhali (Ol Chiki)'), findsOneWidget);
      expect(find.text('ᱡᱚᱦᱟᱨ'), findsOneWidget);
      expect(find.text('I Know'), findsOneWidget);
      expect(find.text('Practice Again'), findsOneWidget);
    });

    testWidgets('TEST 4: Mark "I Know" -> progress is saved', (WidgetTester tester) async {
      final db = InMemoryAppDatabase();
      await db.init();
      final flashcardRepo = FlashcardRepository(db: db);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: FlashcardsScreen(repository: flashcardRepo),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I Know'));
      await tester.pumpAndSettle();

      final summary = await flashcardRepo.getProgressSummary();
      expect(summary.knownCount, equals(1));
      expect(summary.totalPracticeSessions, equals(1));
    });

    testWidgets('TEST 5: Mark "Practice Again" -> progress is saved', (WidgetTester tester) async {
      final db = InMemoryAppDatabase();
      await db.init();
      final flashcardRepo = FlashcardRepository(db: db);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: FlashcardsScreen(repository: flashcardRepo),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Practice Again'));
      await tester.pumpAndSettle();

      final summary = await flashcardRepo.getProgressSummary();
      expect(summary.reviewCount, equals(1));
      expect(summary.totalPracticeSessions, equals(1));
    });

    testWidgets('TEST 6: Complete a Multiple Choice quiz -> score calculated correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final db = InMemoryAppDatabase();
      await db.init();
      final quizRepo = QuizRepository(db: db);
      final profileController = ProfileController(
        storageService: InMemoryProfileStorageService(teacherProfile),
      );
      await profileController.loadProfile();

      await tester.pumpWidget(ProfileScope(
        controller: profileController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: QuizPlayScreen(
            quizType: QuizType.multipleChoice,
            repository: quizRepo,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Multiple Choice Quiz'), findsOneWidget);
      expect(find.text('Question 1 of 4'), findsOneWidget);

      await tester.tap(find.text('ᱡᱚᱦᱟᱨ'));
      await tester.pumpAndSettle();

      expect(find.text('Explanation'), findsOneWidget);

      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      expect(find.text('Question 2 of 4'), findsOneWidget);
      expect(find.text('Score: 1'), findsOneWidget);
    });

    test('TEST 7: Quiz result remains after restart', () async {
      final db = InMemoryAppDatabase();
      final quizRepo = QuizRepository(db: db);

      final result = QuizResult(
        id: 'qr_test_01',
        quizType: 'multiple_choice',
        score: 4,
        totalQuestions: 5,
        correctCount: 4,
        wrongCount: 1,
        accuracyPercent: 80.0,
        userRole: 'teacher',
        completedAt: DateTime.now(),
      );

      await quizRepo.saveQuizResult(result);

      final quizRepoAfterRestart = QuizRepository(db: db);
      final results = await quizRepoAfterRestart.getQuizResults();

      expect(results.length, equals(1));
      expect(results.first.score, equals(4));
      expect(results.first.accuracyPercent, equals(80.0));
      expect(results.first.userRole, equals('teacher'));
    });

    test('TEST 8: Offline/demo mode -> profile, flashcards, quizzes, and history work offline', () async {
      final db = InMemoryAppDatabase();
      await db.init();

      final userRepo = UserRepository(db: db);
      final flashRepo = FlashcardRepository(db: db);
      final quizRepo = QuizRepository(db: db);
      final histRepo = TranslationHistoryRepository(db: db);

      await userRepo.saveUserProfile(studentProfile);
      final profile = await userRepo.getUserProfile();
      expect(profile, isNotNull);

      final cards = await flashRepo.getAllFlashcards();
      expect(cards, isNotEmpty);

      final questions = await quizRepo.getQuestionsByType(QuizType.multipleChoice);
      expect(questions, isNotEmpty);

      await histRepo.saveTranslation(TranslationHistoryItem(
        sourceText: 'ᱫᱟᱜ',
        translatedText: 'पानी',
        sourceLanguage: 'Santhali',
        targetLanguage: 'Hindi',
        createdAt: DateTime.now(),
      ));
      final hist = await histRepo.getRecentTranslations();
      expect(hist, isNotEmpty);
    });

    test('TEST 9: Teacher role -> correct learning/translation direction', () async {
      final db = InMemoryAppDatabase();
      await db.init();
      final quizRepo = QuizRepository(db: db);

      final teacherQuestions = await quizRepo.getQuestionsForRole(UserRole.teacher);
      expect(teacherQuestions.first.sourceLanguage, equals('Hindi'));
      expect(teacherProfile.translationDirectionLabel, equals('Hindi → Santhali'));
    });

    test('TEST 10: Student role -> correct learning/translation direction', () async {
      final db = InMemoryAppDatabase();
      await db.init();
      final quizRepo = QuizRepository(db: db);

      final studentQuestions = await quizRepo.getQuestionsForRole(UserRole.student);
      expect(studentQuestions.first.sourceLanguage, equals('Santhali'));
      expect(studentProfile.translationDirectionLabel, equals('Santhali → Hindi'));
    });

    testWidgets('TEST 11: Existing Stage 5 translation still works and updates persistent history', (WidgetTester tester) async {
      final db = InMemoryAppDatabase();
      await db.init();
      final historyRepo = TranslationHistoryRepository(db: db);

      final profileController = ProfileController(
        storageService: InMemoryProfileStorageService(teacherProfile),
      );
      await profileController.loadProfile();

      await tester.pumpWidget(ProfileScope(
        controller: profileController,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: TranslateScreen(historyRepository: historyRepo),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'किताब खोलो');
      final translateBtn = find.widgetWithText(ElevatedButton, 'Translate');
      await tester.tap(translateBtn);
      await tester.pumpAndSettle();

      expect(find.text('ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱢᱮ'), findsWidgets);
      expect(find.text('Demo Translation'), findsOneWidget);

      final savedHist = await historyRepo.getRecentTranslations();
      expect(savedHist.length, equals(1));
      expect(savedHist.first.sourceText, equals('किताब खोलो'));
    });

    testWidgets('TEST 12: Navigation to Flashcards and Quizzes from Dashboards works', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);

      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st67_t12'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final flashcardsCard = find.text('Flashcards').first;
      await tester.ensureVisible(flashcardsCard);
      await tester.tap(flashcardsCard, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Bilingual Flashcards'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      final quizCard = find.text('Quiz').first;
      await tester.ensureVisible(quizCard);
      await tester.tap(quizCard);
      await tester.pumpAndSettle();

      expect(find.text('Interactive Quizzes'), findsOneWidget);
    });
  });
}
