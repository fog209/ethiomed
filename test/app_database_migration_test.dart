import 'dart:io';

import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

// Migration-path coverage for the REAL current local schema version (v22 on
// master — NOT the stale v18->v20 range from the original task write-up).
//
// Validates Drift's MigrationStrategy.onCreate builds the full v22 schema
// cleanly (the path that runs for every first-time install and for any
// re-creation), and asserts the onUpgrade guard chain is complete (every
// version 2..22 has a corresponding `if (from < N)` guard) so no upgrade step
// can be silently skipped.
void main() {
  const schemaVersion = 22;

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
      'quiz_questions',
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
