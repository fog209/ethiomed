import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'quiz_option.dart';
import 'quiz_repository.dart';
import 'quiz_sync_service.dart';

typedef QuizTableData = QuizQuestionEntity;

final quizNotifierProvider =
    AsyncNotifierProvider.family<QuizNotifier, List<QuizTableData>, String>(
      QuizNotifier.new,
    );

class QuizNotifier extends FamilyAsyncNotifier<List<QuizTableData>, String> {
  late final QuizRepository _repository;
  late final QuizSyncService _syncService;
  int _currentIndex = 0;
  QuizOption? _selectedOption;
  bool _showExplanation = false;

  @override
  Future<List<QuizTableData>> build(String category) async {
    _repository = ref.watch(quizRepositoryProvider);
    _syncService = ref.watch(quizSyncServiceProvider);
    return _loadLocalQuestions(category);
  }

  QuizOption? get selectedOption => _selectedOption;

  bool get showExplanation => _showExplanation;

  bool get isAnswerRevealed => _showExplanation;

  bool get isLastQuestion {
    final questions = state.value;
    return questions == null ||
        questions.isEmpty ||
        _currentIndex >= questions.length - 1;
  }

  QuizTableData? get currentQuestion {
    final questions = state.value;
    if (questions == null || questions.isEmpty) {
      return null;
    }

    final safeIndex = _currentIndex >= questions.length
        ? questions.length - 1
        : _currentIndex;
    return questions[safeIndex];
  }

  void reset() {
    _currentIndex = 0;
    _selectedOption = null;
    _showExplanation = false;

    final questions = state.value;
    if (questions != null) {
      state = AsyncData(questions);
    }
  }

  void selectOption(QuizOption option) {
    final questions = state.value;
    if (questions == null) {
      return;
    }

    _selectedOption = option;
    _showExplanation = true;
    state = AsyncData(questions);
  }

  void nextQuestion() {
    final questions = state.value;
    if (questions == null || questions.isEmpty || isLastQuestion) {
      return;
    }

    _currentIndex += 1;
    _selectedOption = null;
    _showExplanation = false;
    state = AsyncData(questions);
  }

  Future<void> syncQuestions() async {
    state = const AsyncLoading<List<QuizTableData>>();
    try {
      await _syncService.syncQuestions(arg);
      await _loadLocalQuestions();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<List<QuizTableData>> _loadLocalQuestions([String? category]) async {
    final selectedCategory = category ?? arg;
    state = const AsyncLoading<List<QuizTableData>>();
    try {
      final questions = await _repository.getLocalQuestions(selectedCategory);
      _currentIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      state = AsyncData(questions);
      return questions;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
