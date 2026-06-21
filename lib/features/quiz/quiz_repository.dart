import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

class QuizRepository {
  QuizRepository({
    required SupabaseClient supabase,
    required AppDatabase database,
  }) : _supabase = supabase,
       _db = database;

  final SupabaseClient _supabase;
  final AppDatabase _db;

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

      return remoteQuestions;
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on SocketException {
      debugPrint('Offline: serving from local cache');
      return getLocalQuestions(category);
    } on DioException {
      debugPrint('Offline: serving from local cache');
      return getLocalQuestions(category);
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
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
  );
});
