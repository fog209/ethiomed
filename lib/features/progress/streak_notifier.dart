import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

typedef StudyStreakStats = ({
  int currentStreak,
  int totalArticles,
  double accuracy,
});

final streakNotifierProvider =
    AsyncNotifierProvider<StreakNotifier, StudyStreakStats>(StreakNotifier.new);

class StreakNotifier extends AsyncNotifier<StudyStreakStats> {
  late final AppDatabase _db;

  @override
  Future<StudyStreakStats> build() async {
    _db = ref.watch(databaseProvider);
    try {
      return await _loadStats();
    } catch (error) {
      debugPrint('Unable to load study streak stats: $error');
      return const (currentStreak: 0, totalArticles: 0, accuracy: 0.0);
    }
  }

  Future<void> recordArticleRead() async {
    try {
      await _db.recordArticleView();
      state = const AsyncLoading<StudyStreakStats>();
      state = AsyncData(await _loadStats());
    } catch (error) {
      debugPrint('Unable to record article read: $error');
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> recordQuizResult(bool correct) async {
    try {
      final correctIncrement = correct ? 1 : 0;
      await _db
          .customSelect(
            '''
        INSERT INTO study_sessions (
          date,
          session_date,
          articles_read,
          quizzes_completed,
          quiz_correct
        ) VALUES (?, ?, 0, 1, ?)
        ON CONFLICT(date) DO UPDATE SET
          quizzes_completed = quizzes_completed + 1,
          quiz_correct = quiz_correct + ?
        ''',
            variables: [
              Variable(_todayKey()),
              Variable(_todayKey()),
              Variable(correctIncrement),
              Variable(correctIncrement),
            ],
          )
          .get();
      state = const AsyncLoading<StudyStreakStats>();
      state = AsyncData(await _loadStats());
    } catch (error) {
      debugPrint('Unable to record quiz result: $error');
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  Future<StudyStreakStats> _loadStats() async {
    final currentStreak = await _loadCurrentStreak();
    final totalArticles = await _loadTotalArticles();
    final accuracy = await _loadAccuracy();

    return (
      currentStreak: currentStreak,
      totalArticles: totalArticles,
      accuracy: accuracy,
    );
  }

  Future<int> _loadCurrentStreak() async {
    return _db.countCurrentStudyStreak();
  }

  Future<int> _loadTotalArticles() async {
    return _db.countTotalArticlesViewed();
  }

  Future<double> _loadAccuracy() async {
    final rows = await _db.customSelect('''
          SELECT
            COALESCE(SUM(quiz_correct), 0) AS correct_answers,
            COALESCE(SUM(quizzes_completed), 0) AS total_questions
          FROM study_sessions
          ''').get();

    if (rows.isEmpty) {
      return 0.0;
    }

    final correctAnswers = rows.first.read<int>('correct_answers');
    final totalQuestions = rows.first.read<int>('total_questions');
    if (totalQuestions == 0) {
      return 0.0;
    }

    return correctAnswers * 100.0 / totalQuestions;
  }

  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.toIso8601String().substring(0, 10);
  }
}
