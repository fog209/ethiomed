import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'streak_notifier.dart';

class HeatmapCell {
  const HeatmapCell(this.count);
  final int count;

  bool get isLoaded => count != -1;
}

typedef CategoryProgressRow = ({String category, int read, int total});

typedef QuizAccuracyByCategoryRow = ({String category, int correct, int total});

class ProgressData {
  const ProgressData({
    required this.streak,
    required this.heatmapByDate,
    required this.categoryProgress,
    required this.quizAccuracyByCategory,
  });

  final StudyStreakStats streak;
  final Map<String, int> heatmapByDate;
  final List<CategoryProgressRow> categoryProgress;
  final List<QuizAccuracyByCategoryRow> quizAccuracyByCategory;
}

final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, ProgressData>(ProgressNotifier.new);

class ProgressNotifier extends AsyncNotifier<ProgressData> {
  late final AppDatabase _db;
  bool _dbInitialized = false;

  @override
  Future<ProgressData> build() async {
    if (!_dbInitialized) {
      _db = ref.watch(databaseProvider);
      _dbInitialized = true;
    }

    // Load streak stats (current streak, total articles, quiz accuracy percent)
    StudyStreakStats streak;
    try {
      streak = await ref.watch(streakNotifierProvider.future);
    } catch (error) {
      debugPrint('ProgressNotifier: streak load failed: $error');
      streak = const (currentStreak: 0, totalArticles: 0, accuracy: 0.0);
    }

    // Pre-load heatmap map once.
    Map<String, int> heatmapByDate;
    try {
      heatmapByDate = await _loadHeatmap();
    } catch (error) {
      debugPrint('ProgressNotifier: heatmap load failed: $error');
      heatmapByDate = const <String, int>{};
    }

    // Category progress + quiz accuracy - each can fail independently
    List<CategoryProgressRow> categoryProgress;
    try {
      categoryProgress = await _loadCategoryProgress();
    } catch (error) {
      debugPrint('ProgressNotifier: category progress load failed: $error');
      categoryProgress = const <CategoryProgressRow>[];
    }

    List<QuizAccuracyByCategoryRow> quizAccuracyByCategory;
    try {
      quizAccuracyByCategory = await _loadQuizAccuracyByCategory();
    } catch (error) {
      debugPrint('ProgressNotifier: quiz accuracy load failed: $error');
      quizAccuracyByCategory = const <QuizAccuracyByCategoryRow>[];
    }

    return ProgressData(
      streak: streak,
      heatmapByDate: heatmapByDate,
      categoryProgress: categoryProgress,
      quizAccuracyByCategory: quizAccuracyByCategory,
    );
  }

  Future<Map<String, int>> _loadHeatmap() async {
    // study_sessions.date schema in app_database.dart is TEXT formatted YYYY-MM-DD
    // _ensureStudySessionsTable also creates articles_read/quizzes_completed/quiz_correct.
    final rows = await _db.customSelect('''
      SELECT date, COALESCE(articles_read, 0) AS articles_read
      FROM study_sessions
      WHERE date IS NOT NULL AND date != ''
    ''').get();

    final map = <String, int>{};
    for (final row in rows) {
      final date = row.read<String>('date');
      if (date.isEmpty) continue;
      map[date] = row.read<int>('articles_read');
    }
    return map;
  }

  Future<List<CategoryProgressRow>> _loadCategoryProgress() async {
    // Single GROUP BY query replaces the previous 1 + 2N pattern (list
    // categories, then countArticlesByCategory + countReadArticlesByCategory
    // per category). At 25 categories that was ~51 round-trips; now 2 (the
    // batch query plus the view_history ensure inside it).
    final rows = await _db.loadCategoryProgressBatch();
    return [
      for (final r in rows)
        (category: r.category, read: r.read, total: r.total),
    ];
  }

  Future<List<QuizAccuracyByCategoryRow>> _loadQuizAccuracyByCategory() async {
    // Requirement: correct = rows where lastQuality >= 3.
    //
    // The Drift QuizTable in app_database.dart doesn't include last_quality/ease_factor/etc,
    // but the app's SpacedRepetitionService updates `last_quality` column in quiz_table.
    // Use customSelect so we rely on actual DB column names.
    final rows = await _db.customSelect('''
      SELECT
        COALESCE(category, '') AS category,
        SUM(CASE WHEN COALESCE(last_quality, 0) >= 3 THEN 1 ELSE 0 END) AS correct,
        COUNT(*) AS total
      FROM quiz_table
      WHERE category IS NOT NULL AND category != ''
      GROUP BY category
      ORDER BY category ASC
    ''').get();

    final result = <QuizAccuracyByCategoryRow>[];
    for (final r in rows) {
      final category = r.read<String>('category');
      if (category.isEmpty) continue;

      result.add((
        category: category,
        correct: r.read<int>('correct'),
        total: r.read<int>('total'),
      ));
    }
    return result;
  }
}
