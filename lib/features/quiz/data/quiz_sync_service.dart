import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';

class QuizSyncService {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  QuizSyncService(this._supabase, this._db);

  Future<void> syncQuestions() async {
    try {
      final response = await _supabase.from('questions').select();
      final remoteQuestions = response
          .whereType<Map<String, dynamic>>()
          .map(_questionFromJson)
          .where((question) => question != null)
          .cast<QuizQuestionLocal>()
          .toList(growable: false);

      await _db.transaction(() async {
        for (final question in remoteQuestions) {
          await _db
              .into(_db.quizQuestions)
              .insertOnConflictUpdate(
                QuizQuestionsCompanion.insert(
                  id: Value(question.id),
                  articleId: Value(question.articleId),
                  stem: question.stem,
                  optionA: question.optionA,
                  optionB: question.optionB,
                  optionC: question.optionC,
                  optionD: question.optionD,
                  correctOption: question.correctOption,
                  explanation: Value(question.explanation),
                  category: Value(question.category),
                  difficulty: Value(question.difficulty),
                ),
              );
        }
      });
    } on PostgrestException catch (error) {
      debugPrint('Quiz sync database error: ${error.message}');
      throw AppException(error.message);
    } catch (error) {
      debugPrint('Quiz sync error: $error');
      throw AppException('Unable to download quiz questions.');
    }
  }

  QuizQuestionLocal? _questionFromJson(Map<String, dynamic> json) {
    final stem = _string(json['stem']);
    final optionA = _string(json['option_a']) ?? _string(json['optionA']);
    final optionB = _string(json['option_b']) ?? _string(json['optionB']);
    final optionC = _string(json['option_c']) ?? _string(json['optionC']);
    final optionD = _string(json['option_d']) ?? _string(json['optionD']);
    final correctOption =
        _string(json['correct_option']) ?? _string(json['correctOption']);

    if (stem == null ||
        optionA == null ||
        optionB == null ||
        optionC == null ||
        optionD == null ||
        correctOption == null) {
      return null;
    }

    return QuizQuestionLocal(
      id: _int(json['id']) ?? 0,
      articleId: _string(json['article_id']) ?? _string(json['articleId']),
      stem: stem,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      correctOption: correctOption,
      explanation: _string(json['explanation']),
      category: _string(json['category']),
      difficulty: _string(json['difficulty']),
    );
  }

  String? _string(Object? value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }

  int? _int(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }
}

final quizSyncServiceProvider = Provider<QuizSyncService>((ref) {
  return QuizSyncService(Supabase.instance.client, ref.watch(databaseProvider));
});
