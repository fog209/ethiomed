import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';

typedef WeeklyStats = ({
  int articlesRead,
  int quizzesAnswered,
  int quizzesCorrect,
  int studySessions,
  int streak,
  String strongestCategory,
  String weakestCategory,
});

final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final db = ref.watch(databaseProvider);

  final now = DateTime.now();
  final weekAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
  final weekAgoKey = weekAgo.toIso8601String().substring(0, 10);

  final stats = await db.customSelect(
    '''
    SELECT
      COALESCE(SUM(articles_viewed_count), 0) AS articles_read,
      COALESCE(SUM(quizzes_completed), 0) AS quizzes_answered,
      COALESCE(SUM(quiz_correct), 0) AS quizzes_correct,
      COUNT(DISTINCT date) AS study_sessions
    FROM study_sessions
    WHERE date >= ?
    ''',
    variables: [Variable(weekAgoKey)],
  ).get();

  int articlesRead = 0;
  int quizzesAnswered = 0;
  int quizzesCorrect = 0;
  int studySessions = 0;

  if (stats.isNotEmpty) {
    articlesRead = stats.first.read<int>('articles_read');
    quizzesAnswered = stats.first.read<int>('quizzes_answered');
    quizzesCorrect = stats.first.read<int>('quizzes_correct');
    studySessions = stats.first.read<int>('study_sessions');
  }

  final streak = await db.countCurrentStudyStreak();

  final strongestCategory = await _getCategoryWithMostQuizzes(db, weekAgoKey);
  final weakestCategory = await _getCategoryWithFewestQuizzes(db, weekAgoKey);

  return (
    articlesRead: articlesRead,
    quizzesAnswered: quizzesAnswered,
    quizzesCorrect: quizzesCorrect,
    studySessions: studySessions,
    streak: streak,
    strongestCategory: strongestCategory,
    weakestCategory: weakestCategory,
  );
});

Future<String> _getCategoryWithMostQuizzes(AppDatabase db, String weekAgoKey) async {
  final allCategories = AppConfig.clinicalCategories
      .map((c) => c['name'] as String)
      .toList()
    ..addAll(AppConfig.preclinicalCategories.map((c) => c['name'] as String));

  String bestCategory = '';
  int maxCompleted = 0;

  for (final cat in allCategories) {
    final catStats = await db.customSelect(
      '''
      SELECT
        COALESCE(SUM(quizzes_completed), 0) AS completed
      FROM study_sessions s
      JOIN quiz_table q ON q.category = ?
      WHERE s.date >= ?
      ''',
      variables: [Variable(cat), Variable(weekAgoKey)],
    ).get();

    if (catStats.isNotEmpty) {
      final completed = catStats.first.read<int>('completed');
      if (completed > maxCompleted) {
        maxCompleted = completed;
        bestCategory = cat;
      }
    }
  }

  return bestCategory;
}

Future<String> _getCategoryWithFewestQuizzes(AppDatabase db, String weekAgoKey) async {
  final allCategories = AppConfig.clinicalCategories
      .map((c) => c['name'] as String)
      .toList()
    ..addAll(AppConfig.preclinicalCategories.map((c) => c['name'] as String));

  String worstCategory = allCategories.isNotEmpty ? allCategories.first : '';
  int minCompleted = 999999;

  for (final cat in allCategories) {
    final catStats = await db.customSelect(
      '''
      SELECT
        COALESCE(SUM(quizzes_completed), 0) AS completed
      FROM study_sessions s
      JOIN quiz_table q ON q.category = ?
      WHERE s.date >= ?
      ''',
      variables: [Variable(cat), Variable(weekAgoKey)],
    ).get();

    if (catStats.isNotEmpty) {
      final completed = catStats.first.read<int>('completed');
      if (completed < minCompleted && completed > 0) {
        minCompleted = completed;
        worstCategory = cat;
      }
    }
  }

  return worstCategory;
}