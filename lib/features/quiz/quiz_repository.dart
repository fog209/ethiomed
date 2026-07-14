import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_exceptions.dart';
import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/providers/sync_state_provider.dart';
import '../../../core/services/postgrest_status_helper.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../features/articles/domain/models/article.dart' as model;

enum QuestionScope { all, newOnly, incorrectOnly }

class QuizRepository {
  static void _noop() {}

  QuizRepository({
    required SupabaseClient supabase,
    required AppDatabase database,
    VoidCallback? onServerUnreachable,
    VoidCallback? onRateLimited,
    VoidCallback? onDiskFull,
    VoidCallback? onSuccessfulSync,
  })  : _supabase = supabase,
        _db = database,
        _onServerUnreachable = onServerUnreachable ?? _noop,
        _onRateLimited = onRateLimited ?? _noop,
        _onDiskFull = onDiskFull ?? _noop,
        _onSuccessfulSync = onSuccessfulSync ?? _noop;

  final SupabaseClient _supabase;
  final AppDatabase _db;
  final VoidCallback _onServerUnreachable;
  final VoidCallback _onRateLimited;
  final VoidCallback _onDiskFull;
  final VoidCallback _onSuccessfulSync;

  Future<List<QuizQuestionEntity>> fetchQuestions(String category) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('category', category.trim());
      final remoteQuestions = response
          .map(_questionFromJson)
          .whereType<QuizQuestionEntity>()
          .toList(growable: false);

      await upsertQuestions(remoteQuestions);
      _onSuccessfulSync();

      return remoteQuestions;
    } on PostgrestException catch (e) {
      final status = postgrestStatus(e);
      if (status == 401) {
        throw const SupabaseSessionExpiredException();
      }
      if (status == 403) {
        debugPrint('RLS rejection on questions: ${e.message}');
        return getLocalQuestions(category);
      }
      if (status == 429) {
        _onRateLimited();
        return getLocalQuestions(category);
      }
      if (status == 503 || status == 504) {
        _onServerUnreachable();
        return getLocalQuestions(category);
      }

      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on SocketException {
      _onServerUnreachable();
      debugPrint('Offline: serving from local cache');
      return getLocalQuestions(category);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 || e.response?.statusCode == 504) {
        _onServerUnreachable();
      } else if (e.response?.statusCode == 429) {
        _onRateLimited();
      }
      debugPrint('Offline: serving from local cache');
      return getLocalQuestions(category);
    } on SqliteException catch (e) {
      if (_isDiskFull(e)) {
        _onDiskFull();
        throw const DiskFullException();
      }
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  bool _isDiskFull(SqliteException e) {
    final message = e.message.toLowerCase();
    return message.contains('disk') ||
        message.contains('full') ||
        message.contains('sqlite_full');
  }

  Future<void> upsertQuestions(List<QuizQuestionEntity> questions) async {
    try {
      await _db.transaction(() async {
        for (final question in questions) {
          final entity = _companionFromEntity(question);
          await _db
              .into(_db.quizTable)
              .insert(
                entity,
                onConflict: DoUpdate(
                  (_) => entity,
                  target: [_db.quizTable.remoteId],
                ),
              );
        }
      });
    } on SqliteException catch (error) {
      if (_isDiskFull(error)) {
        _onDiskFull();
        throw const DiskFullException();
      }
      debugPrint('Quiz repository local write error: $error');
      throw AppException('Unable to save quiz questions locally.');
    } catch (error) {
      debugPrint('Quiz repository local write error: $error');
      throw AppException('Unable to save quiz questions locally.');
    }
  }

  Future<List<QuizQuestionEntity>> getLocalQuestions(String category) async {
    final normalizedCategory = category.trim();

    return (_db.select(
      _db.quizTable,
    )..where((table) => table.category.equals(normalizedCategory))).get();
  }

  Future<List<QuizQuestionEntity>> getLocalQuestionsByIds(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final whereClauses = ids.asMap().entries.map((e) => 'id = ?${e.key}').join(' OR ');
    final query = 'SELECT * FROM quiz_table WHERE $whereClauses';

    return _db.customSelect(
      query,
      variables: [for (final id in ids) Variable(id)],
    ).get().then((rows) => rows.map(_questionFromRowSimple).toList(growable: false));
  }

  Future<List<QuizQuestionEntity>> getMissedQuestions() async {
    final rows = await _db
        .customSelect(
          '''
          SELECT *
          FROM quiz_table
          WHERE wrong_count > 0
          ORDER BY last_attempted_at DESC
          ''',
        )
        .get();

    return rows.map(_questionFromRowSimple).toList(growable: false);
  }

  Future<List<QuizQuestionEntity>> buildCustomQuiz({
    String? specialtyFilter,
    QuestionScope scope = QuestionScope.all,
    int questionCount = 50,
  }) async {
    try {
      final List<Variable> conditions = [];
      String whereClause = '';

      if (specialtyFilter != null && specialtyFilter.isNotEmpty) {
        whereClause += ' AND category = ?';
        conditions.add(Variable(specialtyFilter));
      }

      switch (scope) {
        case QuestionScope.newOnly:
          whereClause += ' AND last_attempted_at IS NULL';
          break;
        case QuestionScope.incorrectOnly:
          whereClause += ' AND wrong_count > 0';
          break;
        case QuestionScope.all:
          break;
      }

      final rows = await _db
          .customSelect(
            '''
            SELECT *
            FROM quiz_table
            WHERE 1=1 $whereClause
            ORDER BY RANDOM()
            LIMIT ?
            ''',
            variables: [...conditions, Variable(questionCount)],
          )
          .get();

      return rows.map(_questionFromRowSimple).toList(growable: false);
    } catch (e) {
      debugPrint('Build custom quiz error: $e');
      return const [];
    }
  }

  Future<void> saveQuizAttempt({
    required int sessionId,
    required int questionId,
    required String? selectedOption,
    required bool isCorrect,
    required int? confidenceLevel,
    required int timeSpentSeconds,
  }) async {
    try {
      await _db.into(_db.quizAttemptDetails).insert(
        QuizAttemptDetailsCompanion.insert(
          sessionId: Value(sessionId),
          questionId: Value(questionId),
          selectedOption: Value(selectedOption),
          isCorrect: Value(isCorrect),
          confidenceLevel: Value(confidenceLevel),
          timeSpentSeconds: Value(timeSpentSeconds),
        ),
      );
    } catch (e) {
      debugPrint('Save quiz attempt error: $e');
    }
  }

  Future<List<QuizQuestionEntity>> getHighPriorityMistakes() async {
    try {
      final rows = await _db
          .customSelect(
            '''
            SELECT q.*
            FROM quiz_table q
            INNER JOIN quiz_attempt_details qad ON q.id = qad.question_id
            WHERE qad.is_correct = 0 AND qad.confidence_level = 3
            ORDER BY qad.answered_at DESC
            ''',
          )
          .get();

      return rows.map(_questionFromRowSimple).toList(growable: false);
    } catch (e) {
      debugPrint('Get high priority mistakes error: $e');
      return const [];
    }
  }

  Future<int> syncQuestionsFromSupabase() async {
    try {
      final response = await _supabase.from('questions').select();
      final questions = response
          .map(_questionFromJson)
          .whereType<QuizQuestionEntity>()
          .toList(growable: false);
      await upsertQuestions(questions);
      return questions.length;
    } catch (e) {
      debugPrint('Sync questions error: $e');
      return 0;
    }
  }

  Future<int> syncQuestionsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('category', category.trim());
      final questions = response
          .map(_questionFromJson)
          .whereType<QuizQuestionEntity>()
          .toList(growable: false);
      await upsertQuestions(questions);
      return questions.length;
    } catch (e) {
      debugPrint('Sync questions by category error: $e');
      return 0;
    }
  }

  Future<int> syncArticlesByCategory(String parentCategory) async {
    try {
      final response = await _supabase
          .from('articles')
          .select('*, is_high_yield')
          .eq('parent_category', parentCategory.trim());
      final articles = response
          .map((json) => model.Article.fromJson(json))
          .toList(growable: false);

      await _db.transaction(() async {
        for (final article in articles) {
          await _db
              .into(_db.articles)
              .insertOnConflictUpdate(
                ArticlesCompanion.insert(
                  id: article.id,
                  title: article.title,
                  category: Value(article.subcategory.isNotEmpty
                      ? article.subcategory
                      : article.parentCategory),
                  parentCategory: Value(article.parentCategory.isNotEmpty
                      ? article.parentCategory
                      : null),
                  subcategory: Value(
                      article.subcategory.isNotEmpty ? article.subcategory : null),
                  content: Value(jsonEncode(article.content ?? const <String, dynamic>{})),
                  imageUrl: Value(article.imageUrl),
                  videoUrl: Value(article.videoUrl),
                  isHighYield: Value(article.isHighYield),
                ),
              );
        }
      });
      return articles.length;
    } catch (e) {
      debugPrint('Sync articles by category error: $e');
      return 0;
    }
  }

  Future<int> syncFlashcards() async {
    try {
      final response = await _supabase.from('flashcards').select();
      final flashcards = response
          .map(_flashcardFromJson)
          .whereType<FlashcardEntity>()
          .toList(growable: false);

      await _db.transaction(() async {
        for (final fc in flashcards) {
          final companion = FlashcardTableCompanion.insert(
            remoteId: Value(fc.remoteId ?? 0),
            deckName: fc.deckName,
            frontText: fc.frontText,
            backText: fc.backText,
            sourceArticleId: Value(fc.sourceArticleId ?? ''),
            easeFactor: Value(fc.easeFactor),
            createdAt: Value(fc.createdAt),
          );
          await _db
              .into(_db.flashcardTable)
              .insert(companion, onConflict: DoUpdate((_) => companion));
        }
      });

      return flashcards.length;
    } on PostgrestException catch (e) {
      // Permission denied / RLS rejection / network — do NOT treat as
      // "0 new cards". Rethrow so the caller can show a real error
      // instead of a misleading "items updated" success message.
      debugPrint('Sync flashcards error (permission/network): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Sync flashcards error: $e');
      return 0;
    }
  }

  FlashcardEntity? _flashcardFromJson(Map<String, Object?> json) {
    final deckName = _string(json['deck_name']) ?? _string(json['deckName']);
    final frontText = _string(json['front_text']) ?? _string(json['frontText']);
    final backText = _string(json['back_text']) ?? _string(json['backText']);

    if (deckName == null || frontText == null || backText == null) {
      return null;
    }

    return FlashcardEntity(
      id: 0,
      remoteId: int.tryParse(json['id'].toString()) ?? 0,
      deckName: deckName,
      frontText: frontText,
      backText: backText,
      sourceArticleId: _string(json['source_article_id']) ??
          _string(json['sourceArticleId']),
      easeFactor: 2.5,
      interval: null,
      repetitions: null,
      nextDueAt: null,
      lastQuality: null,
      createdAt: DateTime.now(),
      updatedAt: null,
      parentCategory: null,
    );
  }

  QuizQuestionEntity _questionFromRowSimple(QueryRow row) {
    return QuizQuestionEntity(
      id: row.read<int>('id'),
      remoteId: row.read<String>('remote_id'),
      articleId: row.read<String>('article_id'),
      stem: row.read<String>('stem'),
      optionA: row.read<String>('option_a'),
      optionB: row.read<String>('option_b'),
      optionC: row.read<String>('option_c'),
      optionD: row.read<String>('option_d'),
      correctOption: row.read<String>('correct_option'),
      explanation: row.read<String?>('explanation') ?? '',
      category: row.read<String?>('category') ?? '',
      difficulty: row.read<String?>('difficulty') ?? 'medium',
      testedField: row.read<String?>('tested_field') ?? 'clinicalFeatures',
      wrongCount: row.read<int?>('wrong_count') ?? 0,
      lastAttemptedAt: row.read<DateTime?>('last_attempted_at'),
      easeFactor: row.read<double?>('ease_factor') ?? 2.5,
      sourceType: row.read<String?>('source_type') ?? 'original',
      examYear: row.read<int?>('exam_year'),
      examSource: row.read<String?>('exam_source'),
    );
  }

  QuizTableCompanion _companionFromEntity(QuizQuestionEntity question) {
    return QuizTableCompanion.insert(
      id: const Value.absent(),
      remoteId: question.remoteId,
      articleId: question.articleId,
      stem: question.stem,
      optionA: question.optionA,
      optionB: question.optionB,
      optionC: question.optionC,
      optionD: question.optionD,
      correctOption: question.correctOption,
      explanation: question.explanation,
      category: question.category,
      difficulty: Value(question.difficulty),
      testedField: Value(question.testedField),
      sourceType: Value(question.sourceType),
      examYear: Value(question.examYear),
      examSource: Value(question.examSource),
    );
  }

  QuizQuestionEntity? _questionFromJson(Map<String, Object?> json) {
    final remoteId = _string(json['id']);
    final stem = _string(json['stem']);
    final optionA = _string(json['option_a']) ?? _string(json['optionA']);
    final optionB = _string(json['option_b']) ?? _string(json['optionB']);
    final optionC = _string(json['option_c']) ?? _string(json['optionC']);
    final optionD = _string(json['option_d']) ?? _string(json['optionD']);
    final correctOption = _normalizeCorrectOption(
      _string(json['correct_option']) ?? _string(json['correctOption']),
    );

    if (remoteId == null ||
        stem == null ||
        optionA == null ||
        optionB == null ||
        optionC == null ||
        optionD == null ||
        correctOption == null) {
      return null;
    }

    return QuizQuestionEntity(
      id: 0,
      remoteId: remoteId,
      articleId:
          _string(json['article_id']) ?? _string(json['articleId']) ?? '',
      stem: stem,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      correctOption: correctOption,
      explanation: _string(json['explanation']) ?? '',
      category: _string(json['category']) ?? '',
      difficulty: _string(json['difficulty']) ?? 'medium',
      testedField:
          _string(json['tested_field']) ??
          _string(json['testedField']) ??
          'clinicalFeatures',
      wrongCount: 0,
      lastAttemptedAt: null,
      easeFactor: 2.5,
      sourceType: _string(json['source_type']) ?? 'original',
      examYear: int.tryParse(json['exam_year']?.toString() ?? ''),
      examSource: _string(json['exam_source']),
    );
  }

  String? _normalizeCorrectOption(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toUpperCase();
    if (!<String>['A', 'B', 'C', 'D'].contains(normalized)) {
      return null;
    }

    return normalized;
  }

  String? _string(Object? value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(
    supabase: Supabase.instance.client,
    database: ref.watch(databaseProvider),
    onServerUnreachable: () {
      ref.read(connectivityProvider.notifier).markOffline();
      ref.read(syncStateProvider.notifier).setServerUnreachable();
    },
    onRateLimited: () => ref.read(syncStateProvider.notifier).setRateLimited(),
    onDiskFull: () => ref.read(syncStateProvider.notifier).setDiskFull(),
    onSuccessfulSync: () =>
        ref.read(syncStateProvider.notifier).setSuccessfulSync(),
  );
});

final missedQuestionsProvider = FutureProvider<List<QuizQuestionEntity>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getMissedQuestions();
});

final highPriorityMistakesProvider = FutureProvider<List<QuizQuestionEntity>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getHighPriorityMistakes();
});