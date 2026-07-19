import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

/// Explicit allowlist of **server-sourced content** tables that the
/// "Clear cache / Force re-sync" panic button is permitted to wipe and
/// re-pull from Supabase.
///
/// This is a deliberate, closed list — NOT a wildcard "delete everything".
/// It must NEVER include user-generated or progress data.
///
/// Scoped after a checkpoint review: only tables that are 100% server-sourced
/// reference content with ZERO user/progress columns are eligible:
///   - `articles` — synced from Supabase `articles`, no user state.
///   - `section_registry` — synced from Supabase `section_registry`, no user state.
///
/// Intentionally EXCLUDED (would cause real data loss / violate the
/// "never touch SM-2 / notes / saved" rule):
///   - `quiz_table` / `flashcard_table` — these rows fuse server content AND
///     the user's SM-2 scheduling state (sr_interval, repetitions, next_due_at,
///     ease_factor, interval, last_quality) in the same columns. A content-only
///     resync is NOT possible without a schema split (separate content vs
///     SR-state tables). Backlog item — do NOT attempt in this batch.
///   - `article_notes` (Notes), `bookmarks` (Saved), `learnt` — local
///     user-generated data.
///   - `study_sessions`, `quiz_sessions`, `quiz_attempt_details`, `view_history`
///     — progress/analytics.
///   - `clinical_cases` + children — reference content but with NO remote
///     re-sync source, so wiping would be permanent loss with no refill path.
const List<String> kContentResetAllowlist = <String>[
  'articles',
  'section_registry',
];

/// Aggregate of what the reset touched, for reporting/telemetry.
class ContentResetResult {
  const ContentResetResult({
    required this.clearedTables,
    required this.errors,
  });

  final List<String> clearedTables;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

final contentResetServiceProvider = Provider((ref) {
  return ContentResetService(ref.watch(databaseProvider));
});

class ContentResetService {
  ContentResetService(this._db);

  final AppDatabase _db;

  /// Empties every table in [kContentResetAllowlist] (in a single
  /// transaction) and nothing else. Returns the list of tables actually
  /// cleared plus any per-table errors.
  Future<ContentResetResult> resetContentCache() async {
    final cleared = <String>[];
    final errors = <String>[];

    await _db.transaction(() async {
      for (final table in kContentResetAllowlist) {
        try {
          await _db.customStatement('DELETE FROM "$table"');
          cleared.add(table);
        } catch (e) {
          errors.add('$table: $e');
        }
      }
    });

    return ContentResetResult(clearedTables: cleared, errors: errors);
  }

  /// The tables this operation is allowed to touch. Exposed so the UI and
  /// tests can render/assert the allowlist without reaching into the private
  /// constant directly.
  List<String> get allowedTables => List<String>.unmodifiable(kContentResetAllowlist);
}
