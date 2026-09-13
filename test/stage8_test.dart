import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhasa_setu/data/database/app_database.dart';
import 'package:bhasa_setu/data/repositories/classroom_phrase_repository.dart';
import 'package:bhasa_setu/data/repositories/language_bank_repository.dart';
import 'package:bhasa_setu/main.dart';
import 'package:bhasa_setu/models/user_profile.dart';
import 'package:bhasa_setu/screens/language_bank/language_bank_screen.dart';
import 'package:bhasa_setu/screens/phrases/classroom_phrases_screen.dart';
import 'package:bhasa_setu/services/profile_storage_service.dart';
import 'package:bhasa_setu/core/theme/app_theme.dart';

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

  group('Stage 8: Classroom Phrases & Language Bank Verification', () {
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

    testWidgets('TEST 1: Teacher opens Classroom Phrases from Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st8_t1'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final phrasesCard = find.text('Classroom Phrases').first;
      await tester.ensureVisible(phrasesCard);
      await tester.tap(phrasesCard);
      await tester.pumpAndSettle();

      expect(find.text('Classroom Phrases'), findsWidgets);
      expect(find.text('Teacher vernacular instructions and pedagogical dialogue (Demo content - pending native review).'), findsOneWidget);
    });

    testWidgets('TEST 2 & 3: Categories display correctly and category filter works', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ClassroomPhrasesScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Greetings'), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Encouragement'), findsOneWidget);
      expect(find.text('Homework'), findsOneWidget);
      expect(find.text('Examination'), findsOneWidget);

      // Filter by Encouragement
      await tester.tap(find.text('Encouragement'));
      await tester.pumpAndSettle();

      expect(find.text('शाबाश / बहुत अच्छा'), findsOneWidget);
      expect(find.text('किताब खोलो'), findsNothing);
    });

    testWidgets('TEST 4: Search filters phrases by text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ClassroomPhrasesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'किताब');
      await tester.pumpAndSettle();

      expect(find.text('किताब खोलो'), findsOneWidget);
      expect(find.text('ध्यान से सुनो'), findsNothing);
    });

    testWidgets('TEST 5: Phrase details modal displays Ol Chiki and audio notice', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ClassroomPhrasesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('किताब खोलो'));
      await tester.pumpAndSettle();

      expect(find.text('Classroom Context & Usage'), findsOneWidget);
      expect(find.text('Used at the beginning of a lesson'), findsWidgets);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Audio Status'), findsOneWidget);

      await tester.tap(find.text('Audio Status'));
      await tester.pumpAndSettle();

      expect(find.text('Audio Pronunciation Status'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });

    testWidgets('TEST 6: Teacher opens Language Bank from Dashboard', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st8_t6'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final lbCard = find.text('Language Bank').first;
      await tester.ensureVisible(lbCard);
      await tester.tap(lbCard);
      await tester.pumpAndSettle();

      expect(find.text('Language Bank'), findsWidgets);
      expect(find.text('Categorized bilingual vocabulary across 10 educational themes (Demo content - pending native review).'), findsOneWidget);
    });

    testWidgets('TEST 7: Language Bank displays all 10 categories', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      expect(LanguageBankRepository.categories, containsAll([
        'All',
        'Numbers',
        'Colors',
        'Family',
        'Animals',
        'School',
        'Food',
        'Body Parts',
        'Nature',
        'Common Verbs',
        'Classroom Words',
      ]));

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LanguageBankScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Numbers'), findsOneWidget);
      expect(find.text('Colors'), findsOneWidget);
      expect(find.text('Family'), findsOneWidget);

      final horizontalList = find.byType(ListView).first;
      await tester.drag(horizontalList, const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Classroom Words'), findsOneWidget);
    });

    testWidgets('TEST 8: Language Bank search filters vocabulary accurately', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LanguageBankScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Red');
      await tester.pumpAndSettle();

      expect(find.text('Red'), findsWidgets);
      expect(find.text('Water'), findsNothing);
    });

    testWidgets('TEST 9: Word detail modal displays Santhali, Hindi, English and audio status notice', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LanguageBankScreen(),
      ));
      await tester.pumpAndSettle();

      // Tap on Book
      await tester.tap(find.text('Book').first);
      await tester.pumpAndSettle();

      expect(find.text('Hindi (हिंदी)'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Sample / Unverified'), findsOneWidget);
      expect(find.text('Copy Word'), findsOneWidget);

      await tester.tap(find.text('Audio Status'));
      await tester.pumpAndSettle();

      expect(find.text('Audio Pronunciation Status'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });

    testWidgets('TEST 10: Student Dashboard opens Learn Words and Language Bank', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(studentProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st8_t10'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      final learnWordsCard = find.text('Learn Words').first;
      await tester.ensureVisible(learnWordsCard);
      await tester.tap(learnWordsCard);
      await tester.pumpAndSettle();

      expect(find.text('Language Bank'), findsWidgets);
    });

    testWidgets('TEST 11: Repositories access offline data cleanly without network', (WidgetTester tester) async {
      final phraseRepo = ClassroomPhraseRepository();
      final lbRepo = LanguageBankRepository();

      final phrases = await phraseRepo.getAllPhrases();
      expect(phrases.length, greaterThanOrEqualTo(15));

      final words = await lbRepo.getAllItems();
      expect(words.length, greaterThanOrEqualTo(30));

      final numberWords = await lbRepo.getItemsByCategory('numbers');
      expect(numberWords.length, equals(10));
    });

    testWidgets('TEST 12: Learn Hub tab navigates to both Classroom Phrases and Language Bank', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final storage = InMemoryProfileStorageService(teacherProfile);
      await tester.pumpWidget(BhasaSetuApp(
        key: const ValueKey('st8_t12'),
        storageService: storage,
      ));
      await tester.pumpAndSettle();

      // Go to Learn tab
      final learnTab = find.widgetWithText(NavigationDestination, 'Learn');
      await tester.tap(learnTab);
      await tester.pumpAndSettle();

      expect(find.text('Learning Hub'), findsOneWidget);

      final phrasesItem = find.text('Classroom Phrases').first;
      await tester.ensureVisible(phrasesItem);
      await tester.tap(phrasesItem);
      await tester.pumpAndSettle();

      expect(find.text('Teacher vernacular instructions and pedagogical dialogue (Demo content - pending native review).'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      final lbItem = find.text('Language Bank').first;
      await tester.ensureVisible(lbItem);
      await tester.tap(lbItem);
      await tester.pumpAndSettle();

      expect(find.text('Categorized bilingual vocabulary across 10 educational themes (Demo content - pending native review).'), findsOneWidget);
    });
  });
}
