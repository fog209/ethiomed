import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

class SpacedRepetitionReviewResult {
  const SpacedRepetitionReviewResult({
    required this.interval,
    required this.dueAt,
  });

  final int interval;
  final DateTime dueAt;
}

class _ReviewSchedule {
  const _ReviewSchedule({
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.dueAt,
  });

  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime dueAt;
}

class SpacedRepetitionService {
  SpacedRepetitionService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Future<List<QuizQuestionEntity>> getDueCards(String category) async {
    try {
      final now = DateTime.now();
      final rows = await _db
          .customSelect(
            '''
            SELECT *
            FROM quiz_table
            WHERE category = ?
              AND (next_due_at IS NULL OR next_due_at <= ?)
            ORDER BY
              CASE WHEN next_due_at IS NULL THEN 0 ELSE 1 END,
              next_due_at ASC,
              id ASC
            ''',
            variables: [Variable(category.trim()), Variable(now)],
          )
          .get();

      return rows.map(_questionFromRow).toList(growable: false);
    } catch (error) {
      debugPrint('Spaced repetition due cards error: $error');
      throw AppException('Unable to load due quiz cards.');
    }
  }

  Future<SpacedRepetitionReviewResult> recordReview(int id, int quality) async {
    try {
      return await _db.transaction(() async {
        final question = await _getQuestion(id);
        if (question == null) {
          throw AppException('Quiz question not found.');
        }

        final schedule = _calculateSchedule(
          easeFactor: question.easeFactor,
          interval: question.interval,
          repetitions: question.repetitions,
          quality: quality,
        );

        await _db
            .customSelect(
              '''
          UPDATE quiz_table
          SET
            ease_factor = ?,
            sr_interval = ?,
            repetitions = ?,
            next_due_at = ?,
            last_quality = ?
          WHERE id = ?
          ''',
              variables: [
                Variable(schedule.easeFactor),
                Variable(schedule.interval),
                Variable(schedule.repetitions),
                Variable(schedule.dueAt),
                Variable(quality),
                Variable(id),
              ],
            )
            .get();

        return SpacedRepetitionReviewResult(
          interval: schedule.interval,
          dueAt: schedule.dueAt,
        );
      });
    } catch (error) {
      debugPrint('Spaced repetition review error: $error');
      throw AppException('Unable to record spaced repetition review.');
    }
  }

  Future<_QuizQuestionSchedule?> _getQuestion(int id) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM quiz_table WHERE id = ? LIMIT 1',
          variables: [Variable(id)],
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    return _questionFromRow(rows.first);
  }

  _QuizQuestionSchedule _questionFromRow(QueryRow row) {
    return _QuizQuestionSchedule(
      id: row.read<int>('id'),
      remoteId: row.read<String>('remote_id'),
      articleId: row.read<String>('article_id'),
      stem: row.read<String>('stem'),
      optionA: row.read<String>('option_a'),
      optionB: row.read<String>('option_b'),
      optionC: row.read<String>('option_c'),
      optionD: row.read<String>('option_d'),
      correctOption: row.read<String>('correct_option'),
      explanation: row.read<String?>('explanation') ?? '',
      category: row.read<String?>('category') ?? '',
      difficulty: row.read<String?>('difficulty') ?? 'medium',
      testedField: row.read<String?>('tested_field') ?? 'clinicalFeatures',
      wrongCount: row.read<int?>('wrong_count') ?? 0,
      lastAttemptedAt: row.read<DateTime?>('last_attempted_at'),
      easeFactor: row.read<double?>('ease_factor') ?? 2.5,
      interval: row.read<int?>('sr_interval') ?? 0,
      repetitions: row.read<int?>('repetitions') ?? 0,
      lastQuality: row.read<int?>('last_quality') ?? 0,
    );
  }

  _ReviewSchedule _calculateSchedule({
    required double easeFactor,
    required int interval,
    required int repetitions,
    required int quality,
  }) {
    final safeQuality = quality.clamp(0, 5);
    final adjustedEaseFactor = max(
      1.3,
      easeFactor + 0.1 - (5 - safeQuality) * (0.08 + (5 - safeQuality) * 0.02),
    );
    final adjustedRepetitions = safeQuality < 3 ? 0 : repetitions + 1;
    int adjustedInterval;

    if (safeQuality < 3) {
      adjustedInterval = 1;
    } else if (adjustedRepetitions == 1) {
      adjustedInterval = 1;
    } else if (adjustedRepetitions == 2) {
      adjustedInterval = 6;
    } else {
      adjustedInterval = max(1, (interval * adjustedEaseFactor).round());
    }

    return _ReviewSchedule(
      easeFactor: adjustedEaseFactor,
      interval: adjustedInterval,
      repetitions: adjustedRepetitions,
      dueAt: DateTime.now().add(Duration(days: adjustedInterval)),
    );
  }
}

final spacedRepetitionServiceProvider = Provider<SpacedRepetitionService>((
  ref,
) {
  return SpacedRepetitionService(database: ref.watch(databaseProvider));
});

class _QuizQuestionSchedule extends QuizQuestionEntity {
  const _QuizQuestionSchedule({
    required super.id,
    required super.remoteId,
    required super.articleId,
    required super.stem,
    required super.optionA,
    required super.optionB,
    required super.optionC,
    required super.optionD,
    required super.correctOption,
    required super.explanation,
    required super.category,
    required super.difficulty,
    required super.testedField,
    required super.wrongCount,
    super.lastAttemptedAt,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.lastQuality,
  });

  final double easeFactor;
  final int interval;
  final int repetitions;
  final int lastQuality;
}
