import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class WeaknessService {
  WeaknessService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Future<Set<String>> getWeakFields(String articleId) async {
    try {
      await _ensureLastQualityColumn();
      final rows = await _db
          .customSelect(
            '''
            SELECT DISTINCT tested_field
            FROM quiz_table
            WHERE article_id = ?
              AND last_quality IS NOT NULL
              AND last_quality < 3
            ''',
            variables: [Variable(articleId.trim())],
          )
          .get();

      return rows
          .map((row) => row.read<String>('tested_field'))
          .where((field) => field.trim().isNotEmpty)
          .toSet();
    } catch (error) {
      debugPrint('Weakness service error: $error');
      return {};
    }
  }

  Future<void> _ensureLastQualityColumn() async {
    await _db.customStatement(
      'ALTER TABLE quiz_table ADD COLUMN IF NOT EXISTS last_quality INTEGER',
    );
  }
}

final weaknessServiceProvider = Provider<WeaknessService>((ref) {
  return WeaknessService(database: ref.watch(databaseProvider));
});

final weakFieldsProvider = FutureProvider.family<Set<String>, String>((
  ref,
  articleId,
) {
  return ref.watch(weaknessServiceProvider).getWeakFields(articleId);
});
