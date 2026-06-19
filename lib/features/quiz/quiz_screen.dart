import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import 'data/quiz_sync_service.dart';

enum QuizOption { a, b, c, d }

class QuizState {
  const QuizState({
    required this.isLoading,
    required this.hasQuestions,
    required this.questions,
    this.currentIndex = 0,
    this.selectedOption,
    this.showExplanation = false,
  });

  final bool isLoading;
  final bool hasQuestions;
  final List<QuizQuestionLocal> questions;
  final int currentIndex;
  final QuizOption? selectedOption;
  final bool showExplanation;

  QuizQuestionLocal? get currentQuestion =>
      hasQuestions ? questions[currentIndex] : null;

  bool get isLastQuestion =>
      !hasQuestions || currentIndex >= questions.length - 1;

  QuizState copyWith({
    bool? isLoading,
    bool? hasQuestions,
    List<QuizQuestionLocal>? questions,
    int? currentIndex,
    QuizOption? selectedOption,
    bool? showExplanation,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      hasQuestions: hasQuestions ?? this.hasQuestions,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption ?? this.selectedOption,
      showExplanation: showExplanation ?? this.showExplanation,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final AppDatabase _db;
  final QuizSyncService _syncService;

  QuizNotifier(this._db, this._syncService)
    : super(
        const QuizState(
          isLoading: true,
          hasQuestions: false,
          questions: <QuizQuestionLocal>[],
        ),
      );

  Future<void> loadLocalQuestions() async {
    state = state.copyWith(isLoading: true);
    final questions = await _db.select(_db.quizQuestions).get();
    if (questions.isEmpty) {
      state = const QuizState(
        isLoading: false,
        hasQuestions: false,
        questions: <QuizQuestionLocal>[],
      );
      return;
    }

    state = QuizState(
      isLoading: false,
      hasQuestions: true,
      questions: questions,
    );
  }

  Future<void> downloadQuestions() async {
    state = state.copyWith(isLoading: true);
    await _syncService.syncQuestions();
    await loadLocalQuestions();
  }

  void selectOption(QuizOption option) {
    state = state.copyWith(selectedOption: option, showExplanation: true);
  }

  void nextQuestion() {
    if (state.isLastQuestion) {
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedOption: null,
      showExplanation: false,
    );
  }
}

final quizNotifierProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(
    ref.watch(databaseProvider),
    ref.watch(quizSyncServiceProvider),
  ),
);

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizNotifierProvider);
    final notifier = ref.read(quizNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Practice'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : !state.hasQuestions
              ? _buildEmptyState(notifier)
              : _buildQuiz(state, notifier),
        ),
      ),
    );
  }

  Widget _buildEmptyState(QuizNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 72, color: Color(0xFF1A237E)),
          const SizedBox(height: 16),
          const Text(
            'No practice questions downloaded yet.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: const Color(0xFF1A237E),
              ),
              onPressed: notifier.downloadQuestions,
              child: const Text('Download Questions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(QuizState state, QuizNotifier notifier) {
    final question = state.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionHeader(question),
        const SizedBox(height: 16),
        _buildOptionButton(
          label: 'A',
          text: question.optionA,
          selectedOption: state.selectedOption,
          correctOption: question.correctOption,
          onTap: () => notifier.selectOption(QuizOption.a),
        ),
        _buildOptionButton(
          label: 'B',
          text: question.optionB,
          selectedOption: state.selectedOption,
          correctOption: question.correctOption,
          onTap: () => notifier.selectOption(QuizOption.b),
        ),
        _buildOptionButton(
          label: 'C',
          text: question.optionC,
          selectedOption: state.selectedOption,
          correctOption: question.correctOption,
          onTap: () => notifier.selectOption(QuizOption.c),
        ),
        _buildOptionButton(
          label: 'D',
          text: question.optionD,
          selectedOption: state.selectedOption,
          correctOption: question.correctOption,
          onTap: () => notifier.selectOption(QuizOption.d),
        ),
        if (state.showExplanation) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300)),
            ),
            child: Text(
              'Explanation: ${question.explanation}',
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
        const Spacer(),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: const Color(0xFF1A237E),
            ),
            onPressed: state.isLastQuestion ? null : notifier.nextQuestion,
            child: Text(state.isLastQuestion ? 'End of Quiz' : 'Next Question'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(QuizQuestionLocal question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                question.category ?? 'Practice',
                style: const TextStyle(
                  color: Color(0xFFFFB300),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              question.difficulty ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.stem,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String text,
    required QuizOption? selectedOption,
    required String correctOption,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedOption != null;
    final selectedLetter = selectedOption?.name.toUpperCase();
    final isCorrect = selectedLetter == correctOption;
    final borderColor = isSelected
        ? isCorrect
              ? const Color(0xFFFFB300)
              : const Color(0xFFD32F2F)
        : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                child: Text(label),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}
