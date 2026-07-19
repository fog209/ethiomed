import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class FlashcardReviewResult {
  const FlashcardReviewResult({
    required this.interval,
    required this.dueAt,
  });

  final int interval;
  final DateTime dueAt;
}

class FlashcardReviewService {
  FlashcardReviewService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Future<List<FlashcardEntity>> getDueFlashcards(
    String? deckName, {
    String? track,
  }) async {
    final now = DateTime.now();
    final clauses = <String>[];
    final variables = <Variable<Object>>[];

    if (deckName == null || deckName.isEmpty) {
      clauses.add('(next_due_at IS NULL OR next_due_at <= ?)');
      variables.add(Variable(now));
    } else {
      clauses.add('deck_name = ? AND (next_due_at IS NULL OR next_due_at <= ?)');
      variables.add(Variable(deckName));
      variables.add(Variable(now));
    }

    // Track filter is additive. When null (no preference or 'both'), all rows
    // match — including the currently-empty table and any null-track rows.
    if (track != null && track.isNotEmpty) {
      clauses.add('(track IS NULL OR track = ?)');
      variables.add(Variable(track));
    }

    final whereClause = clauses.join(' AND ');

    final rows = await _db
        .customSelect(
          '''
          SELECT *
          FROM flashcard_table
          WHERE $whereClause
          ORDER BY
            CASE WHEN next_due_at IS NULL THEN 0 ELSE 1 END,
            next_due_at ASC,
            id ASC
          ''',
          variables: variables,
        )
        .get();

    return rows.map(_flashcardFromRow).toList(growable: false);
  }

  Future<FlashcardReviewResult> recordFlashcardReview(int id, int quality) async {
    return await _db.transaction(() async {
      final flashcard = await _getFlashcard(id);
      if (flashcard == null) {
        throw StateError('Flashcard not found.');
      }

      final schedule = _calculateSchedule(
        easeFactor: flashcard.easeFactor,
        interval: flashcard.interval ?? 0,
        repetitions: flashcard.repetitions ?? 0,
        quality: quality,
      );

      await _db.customSelect(
        '''
        UPDATE flashcard_table
        SET
          ease_factor = ?,
          interval = ?,
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
      ).get();

      return FlashcardReviewResult(
        interval: schedule.interval,
        dueAt: schedule.dueAt,
      );
    });
  }

  Future<FlashcardEntity?> _getFlashcard(int id) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM flashcard_table WHERE id = ? LIMIT 1',
          variables: [Variable(id)],
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    return _flashcardFromRow(rows.first);
  }

  FlashcardEntity _flashcardFromRow(QueryRow row) {
    return FlashcardEntity(
      id: row.read<int>('id'),
      remoteId: row.read<int?>('remote_id'),
      deckName: row.read<String>('deck_name'),
      frontText: row.read<String>('front_text'),
      backText: row.read<String>('back_text'),
      sourceArticleId: row.read<String?>('source_article_id'),
      easeFactor: row.read<double?>('ease_factor') ?? 2.5,
      interval: row.read<int?>('interval'),
      repetitions: row.read<int?>('repetitions'),
      nextDueAt: row.read<DateTime?>('next_due_at'),
      lastQuality: row.read<int?>('last_quality'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime?>('updated_at'),
      parentCategory: row.read<String?>('parent_category'),
    );
  }

  _FlashcardSchedule _calculateSchedule({
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

    return _FlashcardSchedule(
      easeFactor: adjustedEaseFactor,
      interval: adjustedInterval,
      repetitions: adjustedRepetitions,
      dueAt: DateTime.now().add(Duration(days: adjustedInterval)),
    );
  }
}

class _FlashcardSchedule {
  const _FlashcardSchedule({
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

final flashcardReviewServiceProvider = Provider<FlashcardReviewService>((ref) {
  return FlashcardReviewService(database: ref.watch(databaseProvider));
});

typedef FlashcardJson = ({String deck, String front, String back});

Future<int> importFlashcardsFromJson(
  AppDatabase db,
  List<FlashcardJson> cards,
) async {
  if (cards.isEmpty) {
    return 0;
  }

  return await db.transaction(() async {
    var count = 0;
    final now = DateTime.now();

    for (final card in cards) {
      await db.customStatement(
        '''
        INSERT INTO flashcard_table (
          deck_name,
          front_text,
          back_text,
          source_article_id,
          ease_factor,
          interval,
          repetitions,
          next_due_at,
          last_quality,
          created_at
        ) VALUES (?, ?, ?, NULL, 2.5, 0, 0, ?, NULL, ?)
        ''',
        [card.deck.trim(), card.front.trim(), card.back.trim(), now, now],
      );
      count++;
    }

    return count;
  });
}