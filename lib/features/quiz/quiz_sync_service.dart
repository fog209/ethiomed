import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import 'quiz_repository.dart';

class QuizSyncService {
  QuizSyncService(this._repository);

  final QuizRepository _repository;

  Future<void> syncQuestions(String category) async {
    try {
      await _repository.fetchQuestions(category);
    } on PostgrestException catch (error) {
      debugPrint('Quiz sync database error: ${error.message}');
      throw AppException(error.message);
    } on DioException catch (error) {
      debugPrint('Quiz sync network error: ${error.message}');
      throw AppException('Unable to download quiz questions.');
    } catch (error) {
      debugPrint('Quiz sync error: $error');
      throw AppException('Unable to download quiz questions.');
    }
  }
}

final quizSyncServiceProvider = Provider<QuizSyncService>((ref) {
  return QuizSyncService(ref.watch(quizRepositoryProvider));
});
