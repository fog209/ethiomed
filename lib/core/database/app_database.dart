import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class MigrationErrorStore {
  static String? value;
}

final migrationErrorProvider = StateProvider<String?>((ref) => MigrationErrorStore.value);

void setMigrationError(String value) {
  MigrationErrorStore.value = value;
}

@DataClassName('ArticleLocal')
class Articles extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get subcategory => text().nullable()();
  BoolColumn get isHighYield => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

extension ArticleLocalExtensions on ArticleLocal {
  int get estimatedReadMinutes {
    final content = this.content;
    if (content == null) return 1;
    int totalWords = 0;
    try {
      if (content.startsWith('{')) {
        final contentMap = Map<String, dynamic>.from(
          (this.content as Map<String, dynamic>?) ?? <String, dynamic>{},
        );
        for (final value in contentMap.values) {
          if (value is String) {
            totalWords += value.split(RegExp(r'\s+')).length;
          }
        }
      } else {
        totalWords = content.split(RegExp(r'\s+')).length;
      }
    } catch (_) {
      totalWords = content.split(RegExp(r'\s+')).length;
    }
    return (totalWords / 200).round().clamp(1, 999);
  }
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get articleId => text().references(Articles, #id)();
}

class StudySessions extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get articlesViewedCount =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('QuizQuestionLocal')
class QuizQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get articleId => text().nullable()();
  TextColumn get stem => text()();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  TextColumn get correctOption => text().withLength(min: 1, max: 1)();
  TextColumn get explanation => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get difficulty => text().nullable()();
}

@TableIndex(name: 'idx_quiz_table_category', columns: {#category})
@DataClassName('QuizQuestionEntity')
class QuizTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get articleId => text()();
  TextColumn get stem => text()();
  TextColumn get optionA => text()();
  TextColumn get optionB => text()();
  TextColumn get optionC => text()();
  TextColumn get optionD => text()();
  TextColumn get correctOption => text().withLength(min: 1, max: 1)();
  TextColumn get explanation => text()();
  TextColumn get category => text()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  TextColumn get testedField =>
      text().withDefault(const Constant('clinicalFeatures'))();
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  IntColumn get srInterval => integer().nullable()();
  IntColumn get repetitions => integer().nullable()();
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get lastQuality => integer().nullable()();
}

class ClinicalCases extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get specialty => text()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  IntColumn get estimatedTimeMinutes => integer().withDefault(const Constant(15))();
  TextColumn get learningObjectives => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CaseStages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get caseId => text().references(ClinicalCases, #id)();
  IntColumn get stageNumber => integer()();
  TextColumn get stageType => text().withDefault(const Constant('presentation'))();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CaseOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get stageId => integer().references(CaseStages, #id)();
  TextColumn get optionText => text()();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  TextColumn get feedback => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CaseProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get caseId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get currentStage => integer().withDefault(const Constant(1))();
  IntColumn get correctDecisions => integer().withDefault(const Constant(0))();
  IntColumn get totalDecisions => integer().withDefault(const Constant(0))();
  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();
  BoolColumn get examMode => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Articles,
    Bookmarks,
    StudySessions,
    QuizQuestions,
    QuizTable,
    ClinicalCases,
    CaseStages,
    CaseOptions,
    CaseProgress,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;

  Future<void> _runMigrationStep(
    String name,
    Future<void> Function() step,
  ) async {
    try {
      await step();
    } catch (e) {
      debugPrint('Migration step failed: $name: $e');
      setMigrationError('Migration step failed: $name');
    }
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _runMigrationStep('create bookmarks', () => m.createTable(bookmarks));
        }
        if (from < 3) {
          await _runMigrationStep('create quiz questions', () => m.createTable(quizQuestions));
        }
        if (from < 4) {
          if (from >= 3) {
            await _runMigrationStep('drop old quiz questions', () => m.drop(quizQuestions));
          }
          await _runMigrationStep('create quiz table', () => m.createTable(quizTable));
        }
        if (from < 5) {
          await _runMigrationStep('add quiz srInterval', () => m.addColumn(
            quizTable,
            quizTable.srInterval as GeneratedColumn<Object>,
          ));
          await _runMigrationStep('add quiz repetitions', () => m.addColumn(
            quizTable,
            quizTable.repetitions as GeneratedColumn<Object>,
          ));
          await _runMigrationStep('add quiz nextDueAt', () => m.addColumn(
            quizTable,
            quizTable.nextDueAt as GeneratedColumn<Object>,
          ));
        }
        if (from < 6) {
          await _runMigrationStep('add articles isHighYield', () => m.addColumn(
            articles,
            articles.isHighYield as GeneratedColumn<Object>,
          ));
        }
        if (from < 7) {
          await _runMigrationStep('add articles subcategory', () => m.addColumn(
            articles,
            articles.subcategory as GeneratedColumn<Object>,
          ));
        }
        if (from < 8) {
          await _runMigrationStep('ensure study sessions', _ensureStudySessionsTable);
        }
        if (from < 9) {
          await _runMigrationStep('ensure quiz table sm2 columns', _ensureQuizTableSm2Columns);
        }
        if (from < 10) {
          await _runMigrationStep('create clinical cases', () => m.createTable(clinicalCases));
          await _runMigrationStep('create case stages', () => m.createTable(caseStages));
          await _runMigrationStep('create case options', () => m.createTable(caseOptions));
          await _runMigrationStep('create case progress', () => m.createTable(caseProgress));
        }
      },
    );
  }

  Future<void> recordArticleView() async {
    await _ensureStudySessionsTable();

    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);

    await customSelect(
      '''
      INSERT INTO study_sessions (
        date,
        articles_viewed_count
      ) VALUES (?, 1)
      ON CONFLICT(date) DO UPDATE SET
        articles_viewed_count = articles_viewed_count + 1
      ''',
      variables: [Variable(_dateKey(day))],
    ).get();
  }

  Future<void> recordQuizResult(bool correct) async {
    await _ensureStudySessionsTable();

    final correctIncrement = correct ? 1 : 0;
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final dayKey = _dateKey(day);

    await customSelect(
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
        Variable(dayKey),
        Variable(dayKey),
        Variable(correctIncrement),
        Variable(correctIncrement),
      ],
    ).get();
  }

  Future<int> countCurrentStudyStreak() async {
    await _ensureStudySessionsTable();

    final rows = await customSelect('''
      SELECT date
      FROM study_sessions
      WHERE date IS NOT NULL
        AND date != ''
      ORDER BY date DESC
      ''').get();

    final activeDays = rows
        .map((row) => row.read<String>('date'))
        .where((value) => value.isNotEmpty)
        .toSet();
    var streak = 0;
    var date = DateTime.now();

    while (activeDays.contains(_dateKey(date))) {
      streak += 1;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<int> countTotalArticlesViewed() async {
    await _ensureStudySessionsTable();

    final rows = await customSelect('''
      SELECT COALESCE(SUM(articles_viewed_count), 0) AS total_articles
      FROM study_sessions
      ''').get();

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first.read<int>('total_articles');
  }

  Future<void> _ensureStudySessionsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS study_sessions (
        date TEXT NOT NULL PRIMARY KEY,
        articles_viewed_count INTEGER NOT NULL DEFAULT 0,
        session_date TEXT,
        articles_read INTEGER NOT NULL DEFAULT 0,
        quizzes_completed INTEGER NOT NULL DEFAULT 0,
        quiz_correct INTEGER NOT NULL DEFAULT 0
      )
      ''');

    final columns = await customSelect(
      'PRAGMA table_info(study_sessions)',
    ).get();
    final columnNames = columns.map((row) => row.read<String>('name')).toSet();

    if (!columnNames.contains('date')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN date TEXT NOT NULL DEFAULT ""',
      );
    }
    if (!columnNames.contains('articles_viewed_count')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN articles_viewed_count INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columnNames.contains('session_date')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN session_date TEXT',
      );
    }
    if (!columnNames.contains('articles_read')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN articles_read INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columnNames.contains('quizzes_completed')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN quizzes_completed INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columnNames.contains('quiz_correct')) {
      await customStatement(
        'ALTER TABLE study_sessions ADD COLUMN quiz_correct INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (columnNames.contains('session_date')) {
      await customStatement('''
        UPDATE study_sessions
        SET date = session_date
        WHERE (date IS NULL OR date = '')
          AND session_date IS NOT NULL
        ''');
    }
    if (columnNames.contains('articles_read')) {
      await customStatement('''
        UPDATE study_sessions
        SET articles_viewed_count = CASE
          WHEN articles_read > articles_viewed_count THEN articles_read
          ELSE articles_viewed_count
        END
        ''');
    }

    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_study_sessions_date ON study_sessions(date)',
    );
  }

  Future<int> countArticlesByCategory(String category) async {
    final rows = await customSelect(
      'SELECT COUNT(*) AS count FROM articles WHERE category = ?',
      variables: [Variable(category)],
    ).get();

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first.read<int>('count');
  }

  Future<int> countReadArticlesByCategory(String category) async {
    await _ensureViewHistoryTable();
    final rows = await customSelect(
      '''
      SELECT COUNT(DISTINCT vh.article_id) AS count
      FROM view_history vh
      JOIN articles a ON a.id = vh.article_id
      WHERE a.category = ?
      ''',
      variables: [Variable(category)],
    ).get();

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first.read<int>('count');
  }

  /// Loads per-category read progress in a single round-trip.
  ///
  /// Replaces the previous 1 + 2N pattern (one query to list categories, then
  /// [countArticlesByCategory] + [countReadArticlesByCategory] per category)
  /// with one GROUP BY query. At 19 categories this collapses ~39 round-trips
  /// into 2 (this query plus the [view_history] ensure).
  ///
  /// Semantics match the per-category methods exactly:
  /// - [CategoryProgressResult.total] = COUNT(DISTINCT a.id). The LEFT JOIN to
  ///   view_history fans out rows per article view, so DISTINCT on the article
  ///   id is required to reproduce COUNT(*) over the articles table.
  /// - [CategoryProgressResult.read] = COUNT(DISTINCT vh.article_id). Articles
  ///   with no view record contribute NULL article_ids, which COUNT DISTINCT
  ///   ignores — identical to countReadArticlesByCategory.
  /// - LEFT JOIN preserves categories with zero reads (every category holding
  ///   at least one article still yields a row), matching the old behavior.
  Future<List<CategoryProgressResult>> loadCategoryProgressBatch() async {
    await _ensureViewHistoryTable();
    final rows = await customSelect('''
      SELECT
        a.category AS category,
        COUNT(DISTINCT a.id) AS total,
        COUNT(DISTINCT vh.article_id) AS read_count
      FROM articles a
      LEFT JOIN view_history vh ON vh.article_id = a.id
      WHERE a.category IS NOT NULL AND a.category != ''
      GROUP BY a.category
      ORDER BY a.category ASC
    ''').get();

    return [
      for (final r in rows)
        (
          category: r.read<String>('category'),
          total: r.read<int>('total'),
          read: r.read<int>('read_count'),
        ),
    ];
  }

  Future<void> _ensureViewHistoryTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS view_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id TEXT NOT NULL,
        article_title TEXT,
        category TEXT,
        viewed_at TEXT NOT NULL DEFAULT ''
      )
      ''');

    final columns = await customSelect(
      'PRAGMA table_info(view_history)',
    ).get();
    final columnNames = columns.map((row) => row.read<String>('name')).toSet();

    if (!columnNames.contains('article_title')) {
      await customStatement(
        'ALTER TABLE view_history ADD COLUMN article_title TEXT',
      );
    }
    if (!columnNames.contains('category')) {
      await customStatement(
        'ALTER TABLE view_history ADD COLUMN category TEXT',
      );
    }
    if (!columnNames.contains('viewed_at')) {
      await customStatement(
        'ALTER TABLE view_history ADD COLUMN viewed_at TEXT NOT NULL DEFAULT ""',
      );
    }
  }

  Future<void> _ensureQuizTableSm2Columns() async {
    await customStatement(
      '''
      CREATE TABLE IF NOT EXISTS quiz_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT NOT NULL UNIQUE,
        article_id TEXT NOT NULL,
        stem TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_option TEXT NOT NULL,
        explanation TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'medium',
        tested_field TEXT NOT NULL DEFAULT 'clinicalFeatures',
        wrong_count INTEGER NOT NULL DEFAULT 0,
        last_attempted_at INTEGER,
        sr_interval INTEGER,
        repetitions INTEGER,
        next_due_at INTEGER,
        ease_factor REAL,
        last_quality INTEGER
      )
      ''',
    );

    final columns = await customSelect(
      'PRAGMA table_info(quiz_table)',
    ).get();
    final columnNames = columns.map((row) => row.read<String>('name')).toSet();

    if (!columnNames.contains('ease_factor')) {
      await customStatement(
        'ALTER TABLE quiz_table ADD COLUMN ease_factor REAL',
      );
    }
    if (!columnNames.contains('sr_interval')) {
      await customStatement(
        'ALTER TABLE quiz_table ADD COLUMN sr_interval INTEGER',
      );
    }
    if (!columnNames.contains('repetitions')) {
      await customStatement(
        'ALTER TABLE quiz_table ADD COLUMN repetitions INTEGER',
      );
    }
    if (!columnNames.contains('next_due_at')) {
      await customStatement(
        'ALTER TABLE quiz_table ADD COLUMN next_due_at INTEGER',
      );
    }
    if (!columnNames.contains('last_quality')) {
      await customStatement(
        'ALTER TABLE quiz_table ADD COLUMN last_quality INTEGER',
      );
    }
    if (!columnNames.contains('tested_field')) {
      await customStatement(
        "ALTER TABLE quiz_table ADD COLUMN tested_field TEXT NOT NULL DEFAULT 'clinicalFeatures'",
      );
    }
  }

  String _dateKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.toIso8601String().substring(0, 10);
  }
}

/// Per-category read progress, returned by
/// [AppDatabase.loadCategoryProgressBatch].
typedef CategoryProgressResult = ({String category, int total, int read});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ethiomed.sqlite'));
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  ref.keepAlive();
  return db;
});
