import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../features/progress/streak_notifier.dart';

final readinessScoreProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);

  final articleCountResult = await db.customSelect(
    'SELECT COUNT(*) AS count FROM articles',
  ).get();
  final totalArticles =
      articleCountResult.isNotEmpty ? articleCountResult.first.read<int>('count') : 0;

  final readArticlesResult = await db.customSelect(
    'SELECT COUNT(DISTINCT article_id) AS count FROM view_history',
  ).get();
  final readArticles = readArticlesResult.isNotEmpty
      ? readArticlesResult.first.read<int>('count')
      : 0;

  final questionCountResult = await db.customSelect(
    'SELECT COUNT(*) AS count FROM quiz_table',
  ).get();
  final totalQuestions =
      questionCountResult.isNotEmpty ? questionCountResult.first.read<int>('count') : 0;

  final attemptedQuestionsResult = await db.customSelect(
    'SELECT COUNT(*) AS count FROM quiz_table WHERE last_attempted_at IS NOT NULL',
  ).get();
  final attemptedQuestions = attemptedQuestionsResult.isNotEmpty
      ? attemptedQuestionsResult.first.read<int>('count')
      : 0;

  final accuracyResult = await db.customSelect(
    'SELECT AVG(CAST(is_correct AS REAL)) AS accuracy FROM quiz_attempt_details',
  ).get();
  final accuracy = accuracyResult.isNotEmpty
      ? (accuracyResult.first.read<double?>('accuracy') ?? 0.0)
      : 0.0;

  final streakAsync = ref.watch(streakNotifierProvider);
  final streak = streakAsync.valueOrNull?.currentStreak ?? 0;

  final coverageScore = (totalArticles > 0 ? readArticles / totalArticles : 0) *
      0.4 +
      (totalQuestions > 0 ? attemptedQuestions / totalQuestions : 0) * 0.3;

  final accuracyScore = accuracy * 0.2;

  final streakScore = (streak / 30).clamp(0.0, 1.0) * 0.1;

  return (coverageScore + accuracyScore + streakScore) * 100;
});