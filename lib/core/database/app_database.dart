import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

part 'app_database.g.dart';

class MigrationErrorStore {
  static String? value;
}

final migrationErrorProvider = StateProvider<String?>(
  (ref) => MigrationErrorStore.value,
);

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
  TextColumn get parentCategory => text().nullable()();
  TextColumn get categoryPath => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of the Supabase `section_registry` table. Provides icon/label/
/// display-order metadata for article content section keys so a brand-new
/// section type can be rendered without an app update. Synced in full on app
/// launch via [ContentUpdateService.syncSectionRegistry].
@DataClassName('SectionRegistryEntry')
class SectionRegistry extends Table {
  TextColumn get key => text()();
  TextColumn get label => text()();
  TextColumn get iconName => text().nullable()();
  IntColumn get displayOrder => integer().withDefault(const Constant(999))();
  TextColumn get appliesTo => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Per-category label overrides, stored as a JSON object string
  /// (e.g. `{"Anatomy":"Contents & Relationships"}`), keyed by the exact
  /// category strings in [AppConfig]. Null when no overrides exist.
  TextColumn get categoryLabelOverrides => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
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

/// Mirrors [Bookmarks] (articleId PK reference, no schema duplication).
/// Tracks articles the user has marked as "Learnt".
class Learnt extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get articleId => text().references(Articles, #id)();
}

class ArticleNotes extends Table {
  TextColumn get articleId => text()();
  TextColumn get noteText => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column> get primaryKey => {articleId};
}

class StudySessions extends Table {
   DateTimeColumn get date => dateTime()();
   IntColumn get articlesViewedCount =>
       integer().withDefault(const Constant(0))();
   IntColumn get quizSeconds => integer().nullable()();

   @override
   Set<Column> get primaryKey => {date};
 }

 class QuizSessions extends Table {
   IntColumn get id => integer().autoIncrement()();
   DateTimeColumn get startTime => dateTime()();
   DateTimeColumn get endTime => dateTime().nullable()();
   TextColumn get mode => text().withDefault(const Constant('tutor'))();
   IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
   IntColumn get correctAnswers => integer().nullable()();
   TextColumn get specialtyFilter => text().nullable()();

@override
    Set<Column> get primaryKey => {id};
  }

  class QuizAttemptDetails extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get sessionId => integer().nullable()();
    IntColumn get questionId => integer().nullable()();
    TextColumn get selectedOption => text().withLength(min: 1, max: 1).nullable()();
    BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
    IntColumn get confidenceLevel => integer().nullable()();
    IntColumn get timeSpentSeconds => integer().withDefault(const Constant(0))();
    DateTimeColumn get answeredAt => dateTime().clientDefault(DateTime.now)();
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

/// Mirror of Supabase `updated_at` used for incremental sync.
  DateTimeColumn get updatedAt => dateTime().nullable()();

/// Parent category for taxonomy synchronization.
  TextColumn get parentCategory => text().nullable()();

/// Source type: 'original' or 'past_exam'. Nullable; treat NULL as 'original'.
   TextColumn get sourceType => text().nullable()();

/// Exam year, e.g., 2022, 2023.
  IntColumn get examYear => integer().nullable()();

  /// Exam source description, e.g., "EHPLE October".
  TextColumn get examSource => text().nullable()();

  /// Optional "Attending Tip" — a free-text clinical pearl shown after the
  /// explanation. Mirrors the article dynamic-sections pattern: a single
  /// optional text column synced from the Supabase `questions.attending_tip`.
  TextColumn get attendingTip => text().nullable()();
}

@TableIndex(name: 'idx_flashcard_deck', columns: {#deckName})
@TableIndex(name: 'idx_flashcard_due', columns: {#nextDueAt})
@DataClassName('FlashcardEntity')
class FlashcardTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().unique().nullable()();
  TextColumn get deckName => text()();
  TextColumn get frontText => text()();
  TextColumn get backText => text()();
  TextColumn get sourceArticleId => text().nullable()();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().nullable()();
  IntColumn get repetitions => integer().nullable()();
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  IntColumn get lastQuality => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  /// Mirror of Supabase `updated_at` used for incremental sync.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Parent category for taxonomy synchronization.
  TextColumn get parentCategory => text().nullable()();

  /// High-level track classification: 'clinical' | 'preclinical'.
  /// Nullable until content is categorized.
  TextColumn get track => text().nullable()();

  /// Top-level category matching an AppConfig category string
  /// (e.g. 'Internal Medicine', 'Pharmacology'). Nullable until content
  /// is categorized.
  TextColumn get category => text().nullable()();
}

class ClinicalCases extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get specialty => text()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  IntColumn get estimatedTimeMinutes =>
      integer().withDefault(const Constant(15))();
  TextColumn get learningObjectives => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CaseStages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get caseId => text().references(ClinicalCases, #id)();
  IntColumn get stageNumber => integer()();
  TextColumn get stageType =>
      text().withDefault(const Constant('presentation'))();
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
  IntColumn get confidenceLevel => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

  @DriftDatabase(
    tables: [
      Articles,
      SectionRegistry,
      Bookmarks,
      Learnt,
      ArticleNotes,
      StudySessions,
     QuizSessions,
     QuizTable,
     FlashcardTable,
     ClinicalCases,
     CaseStages,
     CaseOptions,
     CaseProgress,
     QuizAttemptDetails,
   ],
 )
  class AppDatabase extends _$AppDatabase {
   AppDatabase() : super(_openConnection());

  /// Test-only constructor: opens the database against a caller-supplied
  /// executor (e.g. an in-memory [NativeDatabase]). Keeps the production
  /// no-arg constructor unchanged.
  AppDatabase.withExecutor(super.executor);

    @override
    int get schemaVersion => 25;

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

  /// Derives the nested taxonomy (parent, optional sub, JSON path) from a flat
  /// category string, for use when backfilling local rows. Defensive against a
  /// value that was already stored as a JSON array. Uses the single canonical
  /// [AppConfig.categoryToParent] map.
  ({String parent, String? sub, String path}) _deriveTaxonomy(
    String? flatCategory,
  ) {
    final raw = (flatCategory ?? '').trim();
    if (raw.isEmpty) {
      return (parent: 'General', sub: null, path: jsonEncode(['General']));
    }
    if (raw.startsWith('[')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List && decoded.isNotEmpty) {
          final list = decoded.map((e) => e.toString()).toList();
          return (
            parent: list.first,
            sub: list.length > 1 ? list[1] : null,
            path: jsonEncode(list),
          );
        }
      } catch (_) {
        // Fall through to plain-string handling below.
      }
    }
    final parent = AppConfig.categoryToParent[raw];
    if (parent != null) {
      return (parent: parent, sub: raw, path: jsonEncode([parent, raw]));
    }
    // Unknown value: treat as a top-level parent category with no subspecialty.
    return (parent: raw, sub: null, path: jsonEncode([raw]));
  }

  /// Migrates existing flat categories to their parent categories.
  /// Uses the single canonical [AppConfig.categoryToParent] map.
  Future<void> migrateCategoryToParentCategory() async {
    for (final entry in AppConfig.categoryToParent.entries) {
      final category = entry.key;
      final parentCategory = entry.value;
      await customSelect(
        'UPDATE articles SET parent_category = ? WHERE category = ?',
        variables: [Variable(parentCategory), Variable(category)],
      ).get();
    }
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _runMigrationStep(
            'create bookmarks',
            () => m.createTable(bookmarks),
          );
        }
        if (from < 3) {
          await _runMigrationStep(
            'create quiz questions (legacy, removed)',
            () async {
              await customStatement('''
                CREATE TABLE IF NOT EXISTS quiz_questions (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  article_id TEXT,
                  stem TEXT NOT NULL,
                  option_a TEXT NOT NULL,
                  option_b TEXT NOT NULL,
                  option_c TEXT NOT NULL,
                  option_d TEXT NOT NULL,
                  correct_option TEXT NOT NULL,
                  explanation TEXT,
                  category TEXT,
                  difficulty TEXT
                )
              ''');
            },
          );
        }
        if (from < 4) {
          if (from >= 3) {
            await _runMigrationStep(
              'drop old quiz questions',
              () async {
                await customStatement('DROP TABLE IF EXISTS quiz_questions');
              },
            );
          }
          await _runMigrationStep(
            'create quiz table',
            () => m.createTable(quizTable),
          );
        }
        if (from < 5) {
          await _runMigrationStep(
            'add quiz srInterval',
            () => m.addColumn(
              quizTable,
              quizTable.srInterval as GeneratedColumn<Object>,
            ),
          );
          await _runMigrationStep(
            'add quiz repetitions',
            () => m.addColumn(
              quizTable,
              quizTable.repetitions as GeneratedColumn<Object>,
            ),
          );
          await _runMigrationStep(
            'add quiz nextDueAt',
            () => m.addColumn(
              quizTable,
              quizTable.nextDueAt as GeneratedColumn<Object>,
            ),
          );
        }
        if (from < 6) {
          await _runMigrationStep(
            'add articles isHighYield',
            () => m.addColumn(
              articles,
              articles.isHighYield as GeneratedColumn<Object>,
            ),
          );
        }
        if (from < 7) {
          await _runMigrationStep(
            'add articles subcategory',
            () => m.addColumn(
              articles,
              articles.subcategory as GeneratedColumn<Object>,
            ),
          );
        }
        if (from < 8) {
          await _runMigrationStep(
            'ensure study sessions',
            _ensureStudySessionsTable,
          );
        }
        if (from < 9) {
          await _runMigrationStep(
            'ensure quiz table sm2 columns',
            _ensureQuizTableSm2Columns,
          );
        }
        if (from < 10) {
          await _runMigrationStep(
            'create clinical cases',
            () => m.createTable(clinicalCases),
          );
          await _runMigrationStep(
            'create case stages',
            () => m.createTable(caseStages),
          );
          await _runMigrationStep(
            'create case options',
            () => m.createTable(caseOptions),
          );
          await _runMigrationStep(
            'create case progress',
            () => m.createTable(caseProgress),
          );
        }
        if (from < 11) {
          await _runMigrationStep(
            'create flashcard table',
            () => m.createTable(flashcardTable),
          );
        }
        if (from < 12) {
          await _runMigrationStep('add updated_at columns', () async {
            await _addUpdatedAtColumnIfMissing(quizTable);
            await _addUpdatedAtColumnIfMissing(flashcardTable);
          });
        }

if (from < 13) {
          await _runMigrationStep(
            'add flashcard remote_id + updated_at + parent_category',
            () async {
              // remote_id (INTEGER)
              final flashcardTableName = flashcardTable.actualTableName;
              final columns = await customSelect(
                'PRAGMA table_info($flashcardTableName)',
              ).get();
              final columnNames = columns
                  .map((row) => row.read<String>('name'))
                  .toSet();

              if (!columnNames.contains('remote_id')) {
                await customStatement(
                  'ALTER TABLE $flashcardTableName ADD COLUMN remote_id INTEGER',
                );
              }

              // updated_at (may exist already, but safe to ensure)
              await _addUpdatedAtColumnIfMissing(flashcardTable);

              // parent_category
              if (!columnNames.contains('parent_category')) {
                await customStatement(
                  'ALTER TABLE $flashcardTableName ADD COLUMN parent_category TEXT',
                );
              }
            },
          );

          // Ensure quiz updated_at and parent_category exist for cursor sync.
          await _runMigrationStep('ensure quiz sync columns', () async {
            await _addUpdatedAtColumnIfMissing(quizTable);
            final quizTableName = quizTable.actualTableName;
            final columns = await customSelect(
              'PRAGMA table_info($quizTableName)',
            ).get();
            final columnNames = columns.map((row) => row.read<String>('name')).toSet();
            if (!columnNames.contains('parent_category')) {
              await customStatement(
                'ALTER TABLE $quizTableName ADD COLUMN parent_category TEXT',
              );
            }
          });

          // Ensure articles parent_category exists.
          await _runMigrationStep('add articles parent_category', () async {
            final articlesTableName = articles.actualTableName;
            final columns = await customSelect(
              'PRAGMA table_info($articlesTableName)',
            ).get();
            final columnNames = columns.map((row) => row.read<String>('name')).toSet();
if (!columnNames.contains('parent_category')) {
               await customStatement(
                 'ALTER TABLE $articlesTableName ADD COLUMN parent_category TEXT',
               );
             }
           });
         }
if (from < 14) {
            await _runMigrationStep(
              'create quiz sessions table',
              () => m.createTable(quizSessions),
            );
          }
if (from < 15) {
             await _runMigrationStep('add quiz_seconds to study_sessions', () async {
               final columns = await customSelect(
                 'PRAGMA table_info(study_sessions)',
               ).get();
               final columnNames = columns.map((row) => row.read<String>('name')).toSet();
               if (!columnNames.contains('quiz_seconds')) {
                 await customStatement(
                   'ALTER TABLE study_sessions ADD COLUMN quiz_seconds INTEGER',
                 );
               }
             });
           }
           if (from < 16) {
             await _runMigrationStep('add past exam columns to quiz_table', () async {
               final columns = await customSelect(
                 'PRAGMA table_info(quiz_table)',
               ).get();
               final columnNames = columns.map((row) => row.read<String>('name')).toSet();

if (!columnNames.contains('source_type')) {
                  await customStatement(
                    'ALTER TABLE quiz_table ADD COLUMN source_type TEXT DEFAULT \'original\'',
                  );
                }
               if (!columnNames.contains('exam_year')) {
                 await customStatement(
                   'ALTER TABLE quiz_table ADD COLUMN exam_year INTEGER',
                 );
               }
if (!columnNames.contains('exam_source')) {
                  await customStatement(
                    'ALTER TABLE quiz_table ADD COLUMN exam_source TEXT',
                  );
                }
              });
            }
            if (from < 17) {
              await _runMigrationStep('create quiz attempt details table', () async {
                await customStatement('''
                  CREATE TABLE IF NOT EXISTS quiz_attempt_details (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id INTEGER NOT NULL REFERENCES quiz_sessions(id),
                    question_id INTEGER NOT NULL REFERENCES quiz_table(id),
                    selected_option TEXT,
                    is_correct INTEGER NOT NULL DEFAULT 0,
                    confidence_level INTEGER,
                    time_spent_seconds INTEGER NOT NULL DEFAULT 0,
                    answered_at TEXT NOT NULL DEFAULT ''
                  )
                ''');
              });
            }
            if (from < 18) {
              await _runMigrationStep('create article notes table', () => m.createTable(articleNotes));
            }
            if (from < 20) {
              await _runMigrationStep(
                'create learnt table',
                () => m.createTable(learnt),
              );
            }
            if (from < 21) {
              await _runMigrationStep(
                'add section_registry category_label_overrides',
                () async {
                  final columns = await customSelect(
                    'PRAGMA table_info(section_registry)',
                  ).get();
                  final columnNames =
                      columns.map((row) => row.read<String>('name')).toSet();
                  if (!columnNames.contains('category_label_overrides')) {
                    await customStatement(
                      'ALTER TABLE section_registry '
                      'ADD COLUMN category_label_overrides TEXT',
                    );
                  }
                },
              );
            }
            if (from < 24) {
              await _runMigrationStep(
                'add quiz attending_tip column',
                () async {
                  final columns = await customSelect(
                    'PRAGMA table_info(quiz_table)',
                  ).get();
                  final columnNames =
                      columns.map((row) => row.read<String>('name')).toSet();
                  if (!columnNames.contains('attending_tip')) {
                    await customStatement(
                      'ALTER TABLE quiz_table ADD COLUMN attending_tip TEXT',
                    );
                  }
                },
              );
            }
            if (from < 25) {
              await _runMigrationStep(
                'add case_progress confidence_level column',
                () async {
                  final columns = await customSelect(
                    'PRAGMA table_info(case_progress)',
                  ).get();
                  final columnNames =
                      columns.map((row) => row.read<String>('name')).toSet();
                  if (!columnNames.contains('confidence_level')) {
                    await customStatement(
                      'ALTER TABLE case_progress '
                      'ADD COLUMN confidence_level INTEGER',
                    );
                  }
                },
              );
            }
            if (from < 23) {
              await _runMigrationStep(
                'drop dead quiz_questions table',
                () async {
                  await customStatement('DROP TABLE IF EXISTS quiz_questions');
                },
              );
            }
            if (from < 22) {
              await _runMigrationStep(
                'add flashcards track and category columns',
                () async {
                  final columns = await customSelect(
                    'PRAGMA table_info(flashcard_table)',
                  ).get();
                  final columnNames =
                      columns.map((row) => row.read<String>('name')).toSet();
                  if (!columnNames.contains('track')) {
                    await customStatement(
                      'ALTER TABLE flashcard_table ADD COLUMN track TEXT',
                    );
                  }
                  if (!columnNames.contains('category')) {
                    await customStatement(
                      'ALTER TABLE flashcard_table ADD COLUMN category TEXT',
                    );
                  }
                },
              );
            }
            if (from < 19) {
              await _runMigrationStep('backfill article taxonomy columns', () async {
                final tableName = articles.actualTableName;
                final rows = await customSelect(
                  'SELECT id, category FROM $tableName WHERE category_path IS NULL',
                ).get();
                for (final row in rows) {
                  final id = row.read<String>('id');
                  final flat = row.read<String?>('category');
                  final taxonomy = _deriveTaxonomy(flat);
                  await customSelect(
                    'UPDATE $tableName '
                    'SET parent_category = ?, subcategory = ?, category_path = ? '
                    'WHERE id = ?',
                    variables: [
                      Variable(taxonomy.parent),
                      Variable(taxonomy.sub),
                      Variable(taxonomy.path),
                      Variable(id),
                    ],
                  ).get();
                }
              });
              // Re-affirm parent mapping for known legacy flat categories.
              await _runMigrationStep(
                'migrate legacy flat categories to parent',
                () => migrateCategoryToParentCategory(),
              );
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

  Future<void> recordQuizSession({
    required int questionsAttempted,
    required int correctAnswers,
    required Duration duration,
  }) async {
    await _ensureStudySessionsTable();

    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final dayKey = _dateKey(day);
    final seconds = duration.inSeconds;

    await customSelect(
      '''
      INSERT INTO study_sessions (
        date,
        session_date,
        quizzes_completed,
        quiz_correct,
        quiz_seconds
      ) VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(date) DO UPDATE SET
        quizzes_completed = quizzes_completed + ?,
        quiz_correct = quiz_correct + ?,
        quiz_seconds = COALESCE(quiz_seconds, 0) + ?
      ''',
      variables: [
        Variable(dayKey),
        Variable(dayKey),
        Variable(questionsAttempted),
        Variable(correctAnswers),
        Variable(seconds),
        Variable(questionsAttempted),
        Variable(correctAnswers),
        Variable(seconds),
      ],
    ).get();
  }

  Future<int> getTotalStudySeconds() async {
    await _ensureStudySessionsTable();
    final rows = await customSelect(
      'SELECT COALESCE(SUM(quiz_seconds), 0) AS total FROM study_sessions',
    ).get();

    return rows.isNotEmpty ? rows.first.read<int>('total') : 0;
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
     if (!columnNames.contains('quiz_seconds')) {
       await customStatement(
         'ALTER TABLE study_sessions ADD COLUMN quiz_seconds INTEGER',
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

  /// Returns distinct non-null subcategories under [parentCategory], sorted
  /// alphabetically. Used by SubcategoryScreen to build its list dynamically.
  /// Returns the private note saved for [articleId], or null if none.
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

  Future<ArticleNote?> getNoteForArticle(String articleId) async {
    return (select(articleNotes)
          ..where((t) => t.articleId.equals(articleId)))
        .getSingleOrNull();
  }

  /// Saves (upserts) a private note for [articleId]. An empty note deletes it.
  Future<void> saveArticleNote(String articleId, String noteText) async {
    if (noteText.trim().isEmpty) {
      await deleteArticleNote(articleId);
      return;
    }
    await into(articleNotes).insertOnConflictUpdate(
      ArticleNotesCompanion.insert(
        articleId: articleId,
        noteText: Value(noteText),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Removes the private note for [articleId].
  Future<void> deleteArticleNote(String articleId) async {
    await (delete(articleNotes)
          ..where((t) => t.articleId.equals(articleId)))
        .go();
  }

  Future<List<String>> fetchSubcategories(String parentCategory) async {
    final rows = await customSelect(
      '''
      SELECT DISTINCT subcategory
      FROM articles
      WHERE parent_category = ?
        AND subcategory IS NOT NULL
        AND subcategory != ''
      ORDER BY subcategory ASC
      ''',
      variables: [Variable(parentCategory)],
    ).get();
    return rows.map((r) => r.read<String>('subcategory')).toList();
  }

  /// Returns articles whose title matches [query] under [parentCategory],
  /// searching across both subcategory and flat-category articles.
  Future<List<ArticleLocal>> searchWithinParent(
    String parentCategory,
    String query, {
    int limit = 50,
  }) async {
    final pattern = '%${query.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final rows = await customSelect(
      '''
      SELECT *
      FROM articles
      WHERE parent_category = ?
        AND title LIKE ? ESCAPE '\\'
      ORDER BY title ASC
      LIMIT ?
      ''',
      variables: [
        Variable(parentCategory),
        Variable(pattern),
        Variable(limit),
      ],
    ).get();
    return rows.map((r) => ArticleLocal(
          id: r.read<String>('id'),
          title: r.read<String>('title'),
          category: r.readNullable<String>('category'),
          content: r.readNullable<String>('content'),
          imageUrl: r.readNullable<String>('image_url'),
          videoUrl: r.readNullable<String>('video_url'),
          subcategory: r.readNullable<String>('subcategory'),
          isHighYield: r.read<bool>('is_high_yield'),
          parentCategory: r.readNullable<String>('parent_category'),
        )).toList();
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
  /// Uses one GROUP BY query (plus the [view_history] ensure) instead of the
  /// previous 1 + 2N per-category round-trip pattern.
  ///
  /// Semantics:
  /// - [CategoryProgressResult.total] = COUNT(DISTINCT a.id). The LEFT JOIN to
  ///   view_history fans out rows per article view, so DISTINCT on the article
  ///   id is required to reproduce COUNT(*) over the articles table.
  /// - [CategoryProgressResult.read] = COUNT(DISTINCT vh.article_id). Articles
  ///   with no view record contribute NULL article_ids, which COUNT DISTINCT
  ///   ignores.
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

    final columns = await customSelect('PRAGMA table_info(view_history)').get();
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

    // Index for read-progress / per-article view aggregations.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_view_history_article_id ON view_history(article_id)',
    );
  }

  Future<void> _ensureQuizTableSm2Columns() async {
    await customStatement('''
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
        last_quality INTEGER,
        updated_at INTEGER
      )
      ''');

    // Index for due-card queries (SM-2 scheduling scans by next_due_at).
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_quiz_next_due_at ON quiz_table(next_due_at)',
    );

    final columns = await customSelect('PRAGMA table_info(quiz_table)').get();
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

  Future<void> _addUpdatedAtColumnIfMissing(dynamic table) async {
    // Use PRAGMA to detect column existence to keep migration step safe.
    final tableName = table.actualTableName;
    final columns = await customSelect('PRAGMA table_info($tableName)').get();
    final columnNames = columns.map((row) => row.read<String>('name')).toSet();

    if (!columnNames.contains('updated_at')) {
      await customStatement(
        'ALTER TABLE $tableName ADD COLUMN updated_at INTEGER',
      );
    }
  }

  String _dateKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.toIso8601String().substring(0, 10);
  }

  /// Returns the [limit] most recently opened articles (distinct by article
  /// id, most-recent first) from the [view_history] table. Used by the
  /// Home tab's "Recently Read" section. Joins [articles] so a full
  /// [ArticleLocal] can be reconstructed for navigation.
  Future<List<RecentlyReadArticle>> fetchRecentlyRead(int limit) async {
    await _ensureViewHistoryTable();
    final rows = await customSelect(
      '''
      SELECT a.id AS id, a.title AS title, a.category AS category,
             a.subcategory AS subcategory, a.content AS content,
             a.image_url AS image_url, a.video_url AS video_url,
             a.parent_category AS parent_category,
             a.is_high_yield AS is_high_yield, MAX(vh.viewed_at) AS viewed_at
      FROM view_history vh
      JOIN articles a ON a.id = vh.article_id
      GROUP BY vh.article_id
      ORDER BY viewed_at DESC
      LIMIT ?
      ''',
      variables: [Variable<int>(limit)],
    ).get();

    return [
      for (final r in rows)
        RecentlyReadArticle(
          id: r.read<String>('id'),
          title: r.read<String>('title'),
          category: r.readNullable<String>('category'),
          subcategory: r.readNullable<String>('subcategory'),
          content: r.readNullable<String>('content'),
          imageUrl: r.readNullable<String>('image_url'),
          videoUrl: r.readNullable<String>('video_url'),
          parentCategory: r.readNullable<String>('parent_category'),
          isHighYield: r.read<bool>('is_high_yield'),
        ),
    ];
  }
}

/// A single recently-opened article entry, derived from the
/// [view_history] table (most-recent first). Carries just enough
/// fields to render a tile and reconstruct an [ArticleLocal] for
/// navigation to the article detail screen.
class RecentlyReadArticle {
  const RecentlyReadArticle({
    required this.id,
    required this.title,
    this.category,
    this.subcategory,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.parentCategory,
    this.isHighYield = false,
  });

  final String id;
  final String title;
  final String? category;
  final String? subcategory;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final String? parentCategory;
  final bool isHighYield;
}

/// Per-category read progress, returned by
/// [AppDatabase.loadCategoryProgressBatch].
typedef CategoryProgressResult = ({String category, int total, int read});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ethiomed.sqlite'));
    return NativeDatabase(
      file,
      setup: (database) {
        // WAL journal mode lets background sync writes and foreground reads
        // proceed concurrently without "database is locked" errors. Runs once
        // per connection open and does not touch migration/schema callbacks.
        database.execute('PRAGMA journal_mode=WAL;');
      },
    );
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  ref.keepAlive();
  return db;
});
