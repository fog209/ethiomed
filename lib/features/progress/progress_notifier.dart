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
    final streak = await ref.watch(streakNotifierProvider.future);

    // Pre-load heatmap map once.
    final heatmapByDate = await _loadHeatmap();

    // Category progress + quiz accuracy
    final categoryProgress = await _loadCategoryProgress();
    final quizAccuracyByCategory = await _loadQuizAccuracyByCategory();

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
    // Categories are stored in articles.category, nullable.
    // We'll return per distinct non-null category.
    final categories = await _db.customSelect('''
      SELECT COALESCE(category, '') AS category
      FROM articles
      WHERE category IS NOT NULL AND category != ''
      GROUP BY category
      ORDER BY category ASC
    ''').get();

    final List<CategoryProgressRow> rows = [];
    for (final c in categories) {
      final category = c.read<String>('category');
      if (category.isEmpty) continue;

      final total = await _db.countArticlesByCategory(category);
      final read = await _db.countReadArticlesByCategory(category);

      rows.add((category: category, read: read, total: total));
    }
    return rows;
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
