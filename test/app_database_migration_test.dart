import 'dart:io';

import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

// Migration-path coverage for the REAL current local schema version (v25 on
// master after the Batch 2 + Batch 3 + Batch 6 merges — NOT the stale v18->v20
// range from the original task write-up).
//
// Validates Drift's MigrationStrategy.onCreate builds the full v25 schema
// cleanly (the path that runs for every first-time install and for any
// re-creation), asserts the onUpgrade guard chain is complete (every
// version 2..25 has a corresponding `if (from < N)` guard) so no upgrade step
// can be silently skipped, and verifies the v24 -> v25 upgrade actually adds
// the `case_progress.confidence_level` column while preserving existing rows.
void main() {
  const schemaVersion = 25;

  Future<List<String>> tablesIn(AppDatabase db) async {
    final rows = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get();
    return rows.map((r) => r.read<String>('name')).toList();
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
      'quiz_table',
      'flashcard_table',
      'clinical_cases',
      'case_stages',
      'case_options',
      'case_progress',
      'quiz_attempt_details',
    ]) {
      expect(tables, contains(expected),
          reason: 'expected table $expected in fresh v$schemaVersion schema');
    }

    // Spot-check columns added across the migration chain.
    expect(await columnExists(db, 'articles', 'is_high_yield'), isTrue);
    expect(await columnExists(db, 'articles', 'subcategory'), isTrue);
    expect(await columnExists(db, 'articles', 'parent_category'), isTrue);
    expect(await columnExists(db, 'quiz_table', 'source_type'), isTrue);
    expect(await columnExists(db, 'quiz_table', 'exam_year'), isTrue);
    expect(await columnExists(db, 'flashcard_table', 'track'), isTrue);
    expect(await columnExists(db, 'flashcard_table', 'category'), isTrue);
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

  test('onUpgrade v24 -> v25 adds case_progress.confidence_level, '
      'preserving existing rows', () async {
    // Seed a v24-layout case_progress row via a raw SQLite connection whose
    // user_version is pinned to 24, then open the real v25 database so Drift
    // runs the genuine onUpgrade(24 -> 25) path.
    final file = File('${Directory.systemTemp.path}/wr_case_progress_upgrade.db');
    if (file.existsSync()) file.deleteSync();

    final seed = NativeDatabase(file);
    final seedDb = AppDatabase.withExecutor(seed);
    // Pin a v24 baseline and create the v24 case_progress layout by hand so
    // this does not depend on the v25 createTable definition.
    await seedDb.customStatement('PRAGMA user_version = 24');
    await seedDb.customStatement('''
      CREATE TABLE IF NOT EXISTS case_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        case_id TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        current_stage INTEGER NOT NULL DEFAULT 1,
        correct_decisions INTEGER NOT NULL DEFAULT 0,
        total_decisions INTEGER NOT NULL DEFAULT 0,
        hints_used INTEGER NOT NULL DEFAULT 0,
        exam_mode INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await seedDb.customStatement('''
      INSERT INTO case_progress
        (case_id, started_at, current_stage, correct_decisions,
         total_decisions, hints_used, exam_mode)
      VALUES ('case-x', 1752883200000, 2, 3, 4, 1, 0)
    ''');
    await seedDb.close();

    // Re-open with the real v25 database; onUpgrade(24 -> 25) must run.
    final db = AppDatabase.withExecutor(NativeDatabase(file));

    expect(await columnExists(db, 'case_progress', 'confidence_level'), isTrue,
        reason: 'v24->v25 upgrade must add confidence_level to case_progress');

    final rows = await db.customSelect(
      'SELECT case_id, confidence_level FROM case_progress',
    ).get();
    expect(rows, hasLength(1),
        reason: 'existing case_progress row must survive the upgrade');
    expect(rows.first.read<String>('case_id'), 'case-x');
    expect(rows.first.read<int?>('confidence_level'), isNull,
        reason: 'new column should default to NULL for existing rows');

    await db.close();
    if (file.existsSync()) file.deleteSync();
  });
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
