import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'seed_data.dart';

/// Database adapter interface providing uniform, safe local storage operations
/// across Android (SQLite), Desktop/Unit Tests (SQLite FFI), and Flutter Web (Persistent Store).
abstract class AppDatabase {
  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= _createDefaultInstance();
    return _instance!;
  }

  static set instance(AppDatabase db) {
    _instance = db;
  }

  static AppDatabase _createDefaultInstance() {
    if (kIsWeb) {
      return WebAppDatabase();
    } else {
      return SqliteAppDatabase();
    }
  }

  Future<void> init();

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  });

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  });

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<void> close();
}

/// SQLite implementation of AppDatabase for Android, iOS, and desktop/test environments.
class SqliteAppDatabase implements AppDatabase {
  static const String _databaseName = 'bhasa_setu.db';
  static const int _databaseVersion = 1;

  sqflite.Database? _db;
  final String? customPath;

  SqliteAppDatabase({this.customPath});

  @override
  Future<void> init() async {
    if (_db != null && _db!.isOpen) return;

    // In unit tests or desktop Dart VM, initialize sqflite_ffi
    if (!kIsWeb) {
      try {
        sqfliteFfiInit();
        sqflite.databaseFactory = databaseFactoryFfi;
      } catch (_) {
        // On real Android/iOS devices, native sqflite databaseFactory is used
      }
    }

    final dbPath = customPath ?? p.join(await sqflite.getDatabasesPath(), _databaseName);

    _db = await sqflite.openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await _populateSeedDataSqlite(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Upgrade logic for future schema changes
      },
    );
  }

  Future<void> _createTables(sqflite.DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        grade TEXT NOT NULL,
        school_name TEXT NOT NULL,
        gender TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS language_bank (
        id TEXT PRIMARY KEY,
        santhali_word TEXT NOT NULL,
        santhali_script TEXT NOT NULL,
        hindi_meaning TEXT NOT NULL,
        english_meaning TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        is_verified INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS classroom_phrases (
        id TEXT PRIMARY KEY,
        phrase_hindi TEXT NOT NULL,
        phrase_santhali TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        category TEXT NOT NULL,
        teacher_context TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS flashcards (
        id TEXT PRIMARY KEY,
        language_bank_id TEXT,
        santhali_word TEXT NOT NULL,
        hindi_meaning TEXT NOT NULL,
        english_meaning TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        status TEXT NOT NULL,
        times_practiced INTEGER NOT NULL DEFAULT 0,
        last_practiced_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_questions (
        id TEXT PRIMARY KEY,
        question_type TEXT NOT NULL,
        question_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        options_json TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        explanation TEXT NOT NULL,
        category TEXT NOT NULL,
        asset_hint TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_results (
        id TEXT PRIMARY KEY,
        quiz_type TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_count INTEGER NOT NULL,
        wrong_count INTEGER NOT NULL,
        accuracy_percent REAL NOT NULL,
        user_role TEXT NOT NULL,
        completed_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS translation_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        phonetic_guide TEXT,
        is_demo INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
  }

  Future<void> _populateSeedDataSqlite(sqflite.DatabaseExecutor db) async {
    final batch = db.batch();

    for (final item in SeedData.languageBankItems) {
      batch.insert('language_bank', item.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    }

    for (final phrase in SeedData.classroomPhrases) {
      batch.insert('classroom_phrases', phrase.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    }

    for (final fc in SeedData.flashcards) {
      batch.insert('flashcards', fc.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    }

    for (final q in SeedData.quizQuestions) {
      batch.insert('quiz_questions', q.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    }

    batch.insert(
      'app_settings',
      {
        'key': 'seed_initialized',
        'value': 'true',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    await init();
    return await _db!.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  }) async {
    await init();
    final conflict = conflictAlgorithm == 'replace'
        ? sqflite.ConflictAlgorithm.replace
        : sqflite.ConflictAlgorithm.abort;
    return await _db!.insert(table, values, conflictAlgorithm: conflict);
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    return await _db!.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    return await _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

/// Web-compatible database implementation using persistent structured store (SharedPreferences/in-memory)
/// guaranteeing 100% offline persistence and schema parity for Web-server and Chrome.
class WebAppDatabase implements AppDatabase {
  static const String _prefix = 'bhasa_setu_tbl_';
  final Map<String, List<Map<String, dynamic>>> _inMemory = {};
  bool _initialized = false;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  Future<void> init() async {
    if (_initialized) return;

    final tables = [
      'users',
      'language_bank',
      'classroom_phrases',
      'flashcards',
      'quiz_questions',
      'quiz_results',
      'translation_history',
      'app_settings',
    ];

    for (final table in tables) {
      final jsonStr = await _prefs.getString('$_prefix$table');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final decoded = json.decode(jsonStr) as List<dynamic>;
          _inMemory[table] = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          _inMemory[table] = [];
        }
      } else {
        _inMemory[table] = [];
      }
    }

    // Check seed initialization
    if ((_inMemory['language_bank'] ?? []).isEmpty) {
      _inMemory['language_bank'] =
          SeedData.languageBankItems.map((e) => e.toMap()).toList();
      _inMemory['classroom_phrases'] =
          SeedData.classroomPhrases.map((e) => e.toMap()).toList();
      _inMemory['flashcards'] =
          SeedData.flashcards.map((e) => e.toMap()).toList();
      _inMemory['quiz_questions'] =
          SeedData.quizQuestions.map((e) => e.toMap()).toList();
      _inMemory['app_settings'] = [
        {
          'key': 'seed_initialized',
          'value': 'true',
          'updated_at': DateTime.now().toIso8601String(),
        }
      ];

      for (final table in tables) {
        await _saveTable(table);
      }
    }

    _initialized = true;
  }

  Future<void> _saveTable(String table) async {
    final list = _inMemory[table] ?? [];
    await _prefs.setString('$_prefix$table', json.encode(list));
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    await init();
    var list = List<Map<String, dynamic>>.from(_inMemory[table] ?? []);

    if (where != null) {
      list = _applyFilter(list, where, whereArgs);
    }

    if (orderBy != null) {
      // Basic order support (e.g. 'created_at DESC' or 'id ASC')
      final parts = orderBy.split(' ');
      final col = parts[0];
      final isDesc = parts.length > 1 && parts[1].toUpperCase() == 'DESC';
      list.sort((a, b) {
        final valA = a[col];
        final valB = b[col];
        if (valA == null && valB == null) return 0;
        if (valA == null) return isDesc ? 1 : -1;
        if (valB == null) return isDesc ? -1 : 1;
        final cmp = Comparable.compare(valA as Comparable, valB as Comparable);
        return isDesc ? -cmp : cmp;
      });
    }

    if (limit != null && list.length > limit) {
      list = list.take(limit).toList();
    }

    return list;
  }

  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> list,
    String where,
    List<Object?>? whereArgs,
  ) {
    // Standard simple equality filter: "col = ?" or "key = ?"
    if (where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];
      return list.where((item) => item[col]?.toString() == targetVal?.toString()).toList();
    }
    return list;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  }) async {
    await init();
    final list = _inMemory[table] ?? [];
    final copy = Map<String, dynamic>.from(values);

    // Auto-generate integer ID if needed
    if (copy['id'] == null && (table == 'users' || table == 'translation_history')) {
      final maxId = list.fold<int>(0, (max, item) {
        final id = item['id'];
        if (id is int && id > max) return id;
        return max;
      });
      copy['id'] = maxId + 1;
    }

    final pk = table == 'app_settings' ? 'key' : 'id';
    final existingIndex = list.indexWhere((e) => e[pk] == copy[pk]);

    if (existingIndex != -1) {
      list[existingIndex] = copy;
    } else {
      list.add(copy);
    }

    _inMemory[table] = list;
    await _saveTable(table);
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    final list = _inMemory[table] ?? [];
    int count = 0;

    if (where != null && where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];

      for (int i = 0; i < list.length; i++) {
        if (list[i][col]?.toString() == targetVal?.toString()) {
          final updated = Map<String, dynamic>.from(list[i])..addAll(values);
          list[i] = updated;
          count++;
        }
      }
    } else {
      // Update all if where is null
      for (int i = 0; i < list.length; i++) {
        final updated = Map<String, dynamic>.from(list[i])..addAll(values);
        list[i] = updated;
        count++;
      }
    }

    _inMemory[table] = list;
    await _saveTable(table);
    return count;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    final list = _inMemory[table] ?? [];
    int before = list.length;

    if (where == null) {
      list.clear();
    } else if (where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];
      list.removeWhere((item) => item[col]?.toString() == targetVal?.toString());
    }

    _inMemory[table] = list;
    await _saveTable(table);
    return before - list.length;
  }

  @override
  Future<void> close() async {
    // In-memory data is already synced to SharedPreferences
  }
}

/// In-memory database implementation without any disk I/O, native timers, or platform locks.
/// Ideal for automated widget tests, unit tests, and isolated verification sessions.
class InMemoryAppDatabase implements AppDatabase {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    _tables['users'] = [];
    _tables['language_bank'] =
        SeedData.languageBankItems.map((e) => e.toMap()).toList();
    _tables['classroom_phrases'] =
        SeedData.classroomPhrases.map((e) => e.toMap()).toList();
    _tables['flashcards'] =
        SeedData.flashcards.map((e) => e.toMap()).toList();
    _tables['quiz_questions'] =
        SeedData.quizQuestions.map((e) => e.toMap()).toList();
    _tables['quiz_results'] = [];
    _tables['translation_history'] = [];
    _tables['app_settings'] = [
      {
        'key': 'seed_initialized',
        'value': 'true',
        'updated_at': DateTime.now().toIso8601String(),
      }
    ];

    _initialized = true;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    await init();
    var list = List<Map<String, dynamic>>.from(_tables[table] ?? []);

    if (where != null) {
      list = _applyFilter(list, where, whereArgs);
    }

    if (orderBy != null) {
      final parts = orderBy.split(' ');
      final col = parts[0];
      final isDesc = parts.length > 1 && parts[1].toUpperCase() == 'DESC';
      list.sort((a, b) {
        final valA = a[col];
        final valB = b[col];
        if (valA == null && valB == null) return 0;
        if (valA == null) return isDesc ? 1 : -1;
        if (valB == null) return isDesc ? -1 : 1;
        final cmp = Comparable.compare(valA as Comparable, valB as Comparable);
        return isDesc ? -cmp : cmp;
      });
    }

    if (limit != null && list.length > limit) {
      list = list.take(limit).toList();
    }

    return list;
  }

  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> list,
    String where,
    List<Object?>? whereArgs,
  ) {
    if (where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];
      return list.where((item) => item[col]?.toString() == targetVal?.toString()).toList();
    }
    return list;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? conflictAlgorithm,
  }) async {
    await init();
    final list = _tables[table] ?? [];
    final copy = Map<String, dynamic>.from(values);

    if (copy['id'] == null && (table == 'users' || table == 'translation_history')) {
      final maxId = list.fold<int>(0, (max, item) {
        final id = item['id'];
        if (id is int && id > max) return id;
        return max;
      });
      copy['id'] = maxId + 1;
    }

    final pk = table == 'app_settings' ? 'key' : 'id';
    final existingIndex = list.indexWhere((e) => e[pk] == copy[pk]);

    if (existingIndex != -1) {
      list[existingIndex] = copy;
    } else {
      list.add(copy);
    }

    _tables[table] = list;
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    final list = _tables[table] ?? [];
    int count = 0;

    if (where != null && where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];

      for (int i = 0; i < list.length; i++) {
        if (list[i][col]?.toString() == targetVal?.toString()) {
          final updated = Map<String, dynamic>.from(list[i])..addAll(values);
          list[i] = updated;
          count++;
        }
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        final updated = Map<String, dynamic>.from(list[i])..addAll(values);
        list[i] = updated;
        count++;
      }
    }

    _tables[table] = list;
    return count;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await init();
    final list = _tables[table] ?? [];
    int before = list.length;

    if (where == null) {
      list.clear();
    } else if (where.contains(' = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final col = where.split(' = ?')[0].trim();
      final targetVal = whereArgs[0];
      list.removeWhere((item) => item[col]?.toString() == targetVal?.toString());
    }

    _tables[table] = list;
    return before - list.length;
  }

  @override
  Future<void> close() async {
    _tables.clear();
  }
}
