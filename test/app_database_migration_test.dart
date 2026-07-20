import 'dart:io';

import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

// Migration-path coverage for the REAL current local schema version (v26 after
// the content/SM-2 split — NOT the stale v18->v20 range from the original
// task write-up).
//
// Validates Drift's MigrationStrategy.onCreate builds the full v26 schema
// cleanly (the path that runs for every first-time install and for any
// re-creation), asserts the onUpgrade guard chain is complete (every
// version 2..26 has a corresponding `if (from < N)` guard) so no upgrade step
// can be silently skipped, and verifies the v25 -> v26 upgrade actually splits
// the fused quiz/flashcard rows into content + progress tables.
void main() {
  const schemaVersion = 26;

  Future<List<String>> tablesIn(AppDatabase db) async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  Future<bool> viewExists(
    AppDatabase db,
    String view,
  ) async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'view' AND name = '$view'",
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> columnExists(
    AppDatabase db,
    String table,
    String column,
  ) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  test('onCreate builds the full v$schemaVersion schema from scratch', () async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());

    final tables = await tablesIn(db);
    for (final expected in [
      'articles',
      'section_registry',
      'bookmarks',
      'learnt',
      'article_notes',
      'study_sessions',
      'quiz_sessions',
      'quiz_content',
      'quiz_progress',
      'flashcard_content',
      'flashcard_progress',
      'clinical_cases',
      'case_stages',
      'case_options',
      'case_progress',
      'quiz_attempt_details',
    ]) {
      expect(tables, contains(expected),
          reason: 'expected table $expected in fresh v$schemaVersion schema');
    }

    // Compatibility views let legacy read paths keep querying by old names.
    expect(await viewExists(db, 'quiz_table'), isTrue);
    expect(await viewExists(db, 'flashcard_table'), isTrue);

    // Spot-check columns added across the migration chain.
    expect(await columnExists(db, 'articles', 'is_high_yield'), isTrue);
    expect(await columnExists(db, 'articles', 'subcategory'), isTrue);
    expect(await columnExists(db, 'articles', 'parent_category'), isTrue);
    expect(await columnExists(db, 'quiz_content', 'source_type'), isTrue);
    expect(await columnExists(db, 'quiz_content', 'exam_year'), isTrue);
    expect(await columnExists(db, 'flashcard_content', 'track'), isTrue);
    expect(await columnExists(db, 'flashcard_content', 'category'), isTrue);
    expect(await columnExists(db, 'section_registry', 'category_label_overrides'),
        isTrue);
    expect(await columnExists(db, 'study_sessions', 'quiz_seconds'), isTrue);
    expect(await columnExists(db, 'case_progress', 'confidence_level'), isTrue);

    await db.close();
  });

  test('onUpgrade guard chain covers every version 2..$schemaVersion', () async {
    // The migration source is the single source of truth for upgrade steps.
    final source = await const AppDatabaseSource().readAsString();
    final present = <int>{};
    final guard = RegExp(r'if \(from < (\d+)\)');
    for (final m in guard.allMatches(source)) {
      present.add(int.parse(m.group(1)!));
    }
    for (var v = 2; v <= schemaVersion; v++) {
      expect(present, contains(v),
          reason: 'migration chain must define a guard for version $v');
    }
  });

  test('onUpgrade v25 -> v26 splits fused rows into content + progress', () async {
    // Seed a v25-layout DB (quiz_table + flashcard_table with fused content and
    // SM-2 columns) so Drift runs the genuine onUpgrade(25 -> 26) path.
    final file = File('${Directory.systemTemp.path}/wr_sr_split_upgrade.db');
    if (file.existsSync()) file.deleteSync();

    // Use a raw sqlite3 connection (NOT AppDatabase) so Drift's onCreate does
    // not run and pre-create the v26 schema (which would collide with the
    // legacy tables we build by hand here).
    final rawDb = sqlite3.sqlite3.open(file.path);
    rawDb.execute("PRAGMA user_version = 25");
    rawDb.execute('''
      CREATE TABLE quiz_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT UNIQUE,
        article_id TEXT NOT NULL,
        stem TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        explanation TEXT,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        tested_field TEXT NOT NULL DEFAULT 'clinicalFeatures',
        wrong_count INTEGER NOT NULL DEFAULT 0,
        last_attempted_at INTEGER,
        sr_interval INTEGER,
        repetitions INTEGER,
        next_due_at INTEGER,
        ease_factor REAL,
        last_quality INTEGER,
        updated_at INTEGER,
        parent_category TEXT,
        source_type TEXT,
        exam_year INTEGER,
        exam_source TEXT,
        attending_tip TEXT
      )
    ''');
    rawDb.execute('''
      CREATE TABLE flashcard_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER,
        deck_name TEXT NOT NULL,
        front_text TEXT NOT NULL,
        back_text TEXT NOT NULL,
        source_article_id TEXT,
        ease_factor REAL,
        interval INTEGER,
        repetitions INTEGER,
        next_due_at INTEGER,
        last_quality INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        parent_category TEXT,
        track TEXT,
        category TEXT
      )
    ''');
    rawDb.execute('''
      INSERT INTO quiz_table
        (remote_id, article_id, stem, option_a, option_b, option_c, option_d,
         correct_option, explanation, category, sr_interval, repetitions,
         next_due_at, ease_factor, last_quality, wrong_count)
      VALUES
        ('q1', 'a1', 'Stem?', 'A', 'B', 'C', 'D', 'A', 'Because.', 'Cardiology',
         5, 2, 1782000000000, 2.5, 4, 3)
    ''');
    rawDb.execute('''
      INSERT INTO flashcard_table
        (remote_id, deck_name, front_text, back_text, interval, repetitions,
         next_due_at, ease_factor)
      VALUES (1, 'Deck', 'Q', 'A', 5, 2, 1782000000000, 2.5)
    ''');
    rawDb.dispose();

    final db = AppDatabase.withExecutor(NativeDatabase(file));

    // Content carried over (assert BEFORE any other introspection query).
    expect(await countTable(db, 'quiz_content'), 1);
    expect(await countTable(db, 'flashcard_content'), 1);

    // Fused tables gone; split tables present.
    final tables = await tablesIn(db);
    expect(tables, isNot(contains('quiz_table')),
        reason: 'legacy quiz_table must be dropped');
    expect(tables, isNot(contains('flashcard_table')),
        reason: 'legacy flashcard_table must be dropped');
    expect(tables, contains('quiz_content'));
    expect(tables, contains('quiz_progress'));
    expect(tables, contains('flashcard_content'));
    expect(tables, contains('flashcard_progress'));

    // SM-2 state preserved.
    final qp = (await db.select(db.quizProgress).get()).first;
    expect(qp.srInterval, 5);
    expect(qp.repetitions, 2);
    expect(qp.wrongCount, 3);
    final fp = (await db.select(db.flashcardProgress).get()).first;
    expect(fp.interval, 5);
    expect(fp.repetitions, 2);

    // Compatibility views re-expose the fused shape for legacy reads.
    expect(await viewExists(db, 'quiz_table'), isTrue);
    expect(await viewExists(db, 'flashcard_table'), isTrue);
    final fused = await db.customSelect(
      'SELECT sr_interval, wrong_count FROM quiz_table LIMIT 1',
    ).get();
    expect(fused.first.read<int>('sr_interval'), 5);
    expect(fused.first.read<int>('wrong_count'), 3);

    await db.close();
    if (file.existsSync()) file.deleteSync();
  });
}

Future<int> countTable(AppDatabase db, String table) async {
  final rows = await db.customSelect('SELECT COUNT(*) AS c FROM "$table"').get();
  return rows.first.read<int>('c');
}

/// Loads the app_database.dart source for the static guard-coverage check.
class AppDatabaseSource {
  const AppDatabaseSource();

  Future<String> readAsString() async {
    // Resolved relative to the package root via the test working directory.
    final uri = Uri.parse('package:ethiomed/core/database/app_database.dart');
    final path = uri.pathSegments.last;
    final file = await File('lib/core/database/$path').readAsString();
    return file;
  }
}
