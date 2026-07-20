import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/notification_service.dart';

/// Joined SELECT that re-assembles a quiz question's content (quiz_content)
/// with its user SM-2 state (quiz_progress). Used by every read path here so
/// the split storage stays invisible to callers.
const String _quizJoin = '''
  SELECT
    c.id AS id,
    c.remote_id AS remote_id,
    c.article_id AS article_id,
    c.stem AS stem,
    c.option_a AS option_a,
    c.option_b AS option_b,
    c.option_c AS option_c,
    c.option_d AS option_d,
    c.correct_option AS correct_option,
    c.explanation AS explanation,
    c.category AS category,
    c.difficulty AS difficulty,
    c.tested_field AS tested_field,
    COALESCE(p.wrong_count, 0) AS wrong_count,
    p.last_attempted_at AS last_attempted_at,
    p.sr_interval AS sr_interval,
    p.repetitions AS repetitions,
    p.next_due_at AS next_due_at,
    p.ease_factor AS ease_factor,
    p.last_quality AS last_quality
  FROM quiz_content c
  LEFT JOIN quiz_progress p ON p.content_id = c.id
''';

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
  SpacedRepetitionService({required AppDatabase database, required NotificationService notificationService}) : _db = database, _notificationService = notificationService;

  final AppDatabase _db;
  final NotificationService _notificationService;

  Future<List<QuizQuestionEntity>> getDueCards(String category) async {
    try {
      final now = DateTime.now();
      final rows = await _db
          .customSelect(
            '''
            $_quizJoin
            WHERE c.category = ?
              AND (p.next_due_at IS NULL OR p.next_due_at <= ?)
            ORDER BY
              CASE WHEN p.next_due_at IS NULL THEN 0 ELSE 1 END,
              p.next_due_at ASC,
              c.id ASC
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
          interval: question.srInterval ?? 0,
          repetitions: question.repetitions ?? 0,
          quality: quality,
        );

        // Decrement wrong_count on correct answer (quality >= 3)
        final wrongCountDecrement = quality >= 3 && question.wrongCount > 0 ? 1 : 0;
        final newWrongCount = max(0, question.wrongCount - wrongCountDecrement);

        // Persist SM-2 state to quiz_progress (joined by content id). UPSERT so
        // a freshly-synced question that has never been reviewed still records
        // its first review.
        await _db
            .customSelect(
              '''
          INSERT INTO quiz_progress
            (content_id, ease_factor, sr_interval, repetitions, next_due_at,
             last_quality, wrong_count, last_attempted_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(content_id) DO UPDATE SET
            ease_factor = excluded.ease_factor,
            sr_interval = excluded.sr_interval,
            repetitions = excluded.repetitions,
            next_due_at = excluded.next_due_at,
            last_quality = excluded.last_quality,
            wrong_count = excluded.wrong_count,
            last_attempted_at = excluded.last_attempted_at
          ''',
              variables: [
                Variable(id),
                Variable(schedule.easeFactor),
                Variable(schedule.interval),
                Variable(schedule.repetitions),
                Variable(schedule.dueAt),
                Variable(quality),
                Variable(newWrongCount),
                Variable(DateTime.now()),
              ],
            )
            .get();

        try {
          final dueCount = await _countDueCardsForDate(schedule.dueAt);
          await _notificationService.scheduleDueReminder(
            schedule.dueAt,
            dueCount,
          );
        } catch (error) {
          debugPrint('Unable to schedule due-card reminder: $error');
        }

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

  Future<int> _countDueCardsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final rows = await _db
        .customSelect(
          '''
          SELECT COUNT(*) AS count
          FROM quiz_progress
          WHERE next_due_at IS NULL
             OR (next_due_at >= ? AND next_due_at < ?)
          ''',
          variables: [Variable(startOfDay), Variable(endOfDay)],
        )
        .get();

    if (rows.isEmpty) return 0;
    return rows.single.read<int>('count');
  }

  Future<QuizQuestionEntity?> _getQuestion(int id) async {
    final rows = await _db
        .customSelect(
          '$_quizJoin WHERE c.id = ? LIMIT 1',
          variables: [Variable(id)],
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    return _questionFromRow(rows.first);
  }

  QuizQuestionEntity _questionFromRow(QueryRow row) {
    return QuizQuestionEntity(
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
      srInterval: row.read<int?>('sr_interval'),
      repetitions: row.read<int?>('repetitions'),
      nextDueAt: row.read<DateTime?>('next_due_at'),
      easeFactor: row.read<double?>('ease_factor') ?? 2.5,
      lastQuality: row.read<int?>('last_quality'),
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
  return SpacedRepetitionService(
    database: ref.watch(databaseProvider),
    notificationService: NotificationService(ref.watch(databaseProvider)),
  );
});
