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
}

@DriftDatabase(tables: [Articles, Bookmarks, QuizQuestions, QuizTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
      },
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
