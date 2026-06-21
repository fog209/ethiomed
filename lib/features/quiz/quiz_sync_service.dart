import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'quiz_repository.dart';

class QuizSyncService {
  QuizSyncService(this._repository);

  final QuizRepository _repository;

  Future<void> syncQuestions(String category) async {
    try {
      await _repository.fetchQuestions(category);
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on SocketException {
      debugPrint('Offline: serving from local cache');
    } on DioException {
      debugPrint('Offline: serving from local cache');
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}

final quizSyncServiceProvider = Provider<QuizSyncService>((ref) {
  return QuizSyncService(ref.watch(quizRepositoryProvider));
});
