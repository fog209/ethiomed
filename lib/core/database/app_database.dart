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
}

@DriftDatabase(
  tables: [Articles, Bookmarks, StudySessions, QuizQuestions, QuizTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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
      variables: [Variable(day)],
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
    await customStatement(
      'ALTER TABLE view_history ADD COLUMN article_title TEXT',
    );
    await customStatement(
      'ALTER TABLE view_history ADD COLUMN category TEXT',
    );
    await customStatement(
      'ALTER TABLE view_history ADD COLUMN viewed_at TEXT NOT NULL DEFAULT ""',
    );
  }
}

String _dateKey(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.toIso8601String().substring(0, 10);
}

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
