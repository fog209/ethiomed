import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'quiz_option.dart';
import 'quiz_repository.dart';
import 'quiz_sync_service.dart';
import 'spaced_repetition_service.dart';

typedef QuizTableData = QuizQuestionEntity;

final quizNotifierProvider =
    AsyncNotifierProvider.family<QuizNotifier, List<QuizTableData>, String>(
      QuizNotifier.new,
    );

class QuizNotifier extends FamilyAsyncNotifier<List<QuizTableData>, String> {
  late final QuizRepository _repository;
  late final QuizSyncService _syncService;
  late final SpacedRepetitionService _spacedRepetitionService;
  int _currentIndex = 0;
  QuizOption? _selectedOption;
  bool _showExplanation = false;
  int _correctCount = 0;
  int _answeredCount = 0;
  int? _lastReviewInterval;
  bool _isRecordingReview = false;

  @override
  Future<List<QuizTableData>> build(String category) async {
    _repository = ref.watch(quizRepositoryProvider);
    _syncService = ref.watch(quizSyncServiceProvider);
    _spacedRepetitionService = ref.watch(spacedRepetitionServiceProvider);
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

  int get correctCount => _correctCount;

  int get answeredCount => _answeredCount;

  int get totalQuestions => state.value?.length ?? 0;

  int get questionIndex => _currentIndex + 1;

  String get scoreText => '$_correctCount / $_answeredCount correct';

  int? get lastReviewInterval => _lastReviewInterval;

  bool get isRecordingReview => _isRecordingReview;

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
    _correctCount = 0;
    _answeredCount = 0;
    _lastReviewInterval = null;
    _isRecordingReview = false;

    final questions = state.value;
    if (questions != null) {
      state = AsyncData(questions);
    }
  }

  void selectOption(QuizOption option) {
    final questions = state.value;
    final question = currentQuestion;
    if (questions == null || question == null || _showExplanation) {
      return;
    }

    _selectedOption = option;
    _showExplanation = true;
    _isRecordingReview = false;
    _answeredCount += 1;
    if (_isCorrectOption(question, option)) {
      _correctCount += 1;
    }
    state = AsyncData(questions);
  }

  Future<void> saveCurrentStateToDrift() async {
    final question = currentQuestion;
    final option = selectedOption;
    if (question == null || option == null) {
      return;
    }

    await recordReview(question.id, 0);
  }

  Future<void> nextQuestion() async {
    final questions = state.value;
    if (questions == null || questions.isEmpty || isLastQuestion) {
      return;
    }

    _currentIndex += 1;
    _resetCurrentQuestionState();
    state = AsyncData(questions);
  }

  Future<int> recordReview(int id, int quality) async {
    _isRecordingReview = true;
    state = AsyncData(state.value ?? <QuizTableData>[]);
    try {
      final result = await _spacedRepetitionService.recordReview(id, quality);
      final interval = result.interval;
      _lastReviewInterval = interval;
      state = AsyncData(state.value ?? <QuizTableData>[]);
      return interval;
    } finally {
      _isRecordingReview = false;
      state = AsyncData(state.value ?? <QuizTableData>[]);
    }
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
      final dueCards = await _spacedRepetitionService.getDueCards(
        selectedCategory,
      );
      final allQuestions = await _repository.getLocalQuestions(
        selectedCategory,
      );
      final dueIds = <int>{for (final card in dueCards) card.id};
      final newCards = allQuestions
          .where((question) => !dueIds.contains(question.id))
          .toList(growable: false);
      final questions = <QuizTableData>[...dueCards, ...newCards];

      _currentIndex = 0;
      _resetCurrentQuestionState();
      state = AsyncData(questions);
      return questions;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _resetCurrentQuestionState() {
    _selectedOption = null;
    _showExplanation = false;
    _lastReviewInterval = null;
  }

  bool _isCorrectOption(QuizTableData question, QuizOption option) {
    return question.correctOption == option.name.toUpperCase();
  }
}
