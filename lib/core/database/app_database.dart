import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

@DataClassName('ArticleLocal')
class Articles extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  BoolColumn get isHighYield => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get articleId => text().references(Articles, #id)();
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

@DriftDatabase(tables: [Articles, Bookmarks, QuizQuestions, QuizTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(bookmarks);
        }
        if (from < 3) {
          await m.createTable(quizQuestions);
        }
        if (from < 4) {
          if (from >= 3) {
            await m.drop(quizQuestions);
          }
          await m.createTable(quizTable);
        }
        if (from < 6) {
          await m.addColumn(
            articles,
            articles.isHighYield as GeneratedColumn<Object>,
          );
        }
        if (from < 5) {
          await m.addColumn(
            quizTable,
            quizTable.srInterval as GeneratedColumn<Object>,
          );
          await m.addColumn(
            quizTable,
            quizTable.repetitions as GeneratedColumn<Object>,
          );
          await m.addColumn(
            quizTable,
            quizTable.nextDueAt as GeneratedColumn<Object>,
          );
        }
      },
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
        opened_at TEXT NOT NULL DEFAULT ''
      )
    ''');
    await customStatement(
      'ALTER TABLE view_history ADD COLUMN IF NOT EXISTS article_id TEXT',
    );
    await customStatement(
      'ALTER TABLE view_history ADD COLUMN IF NOT EXISTS opened_at TEXT NOT NULL DEFAULT ""',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ethiomed.sqlite'));
    return NativeDatabase(file);
  });
}

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
