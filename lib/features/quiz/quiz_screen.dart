import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import 'quiz_notifier.dart';
import 'quiz_option.dart';

const _defaultQuizCategory = AppConfig.internalMedicineCategory;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void dispose() {
    ref.read(quizNotifierProvider(_defaultQuizCategory).notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizNotifierProvider(_defaultQuizCategory));
    final notifier = ref.read(
      quizNotifierProvider(_defaultQuizCategory).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('MCQ Practice'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.when(
              data: (questions) => questions.isEmpty
                  ? _buildEmptyState(notifier)
                  : _buildQuiz(context, questions, notifier),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(notifier),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(QuizNotifier notifier) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              onPressed: notifier.syncQuestions,
              child: const Text('Download Questions'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(QuizNotifier notifier) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 72, color: Color(0xFF1A237E)),
          const SizedBox(height: 16),
          const Text(
            'Unable to load quiz questions.',
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
              onPressed: notifier.syncQuestions,
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(
    BuildContext context,
    List<QuizTableData> questions,
    QuizNotifier notifier,
  ) {
    final question = notifier.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionHeader(question),
        const SizedBox(height: 16),
        _buildOptionButton(
          label: 'A',
          text: question.optionA,
          isCorrectOption:
              question.correctOption == QuizOption.a.name.toUpperCase(),
          isSelectedOption: notifier.selectedOption == QuizOption.a,
          isAnswerRevealed: notifier.isAnswerRevealed,
          onTap: () => notifier.selectOption(QuizOption.a),
        ),
        _buildOptionButton(
          label: 'B',
          text: question.optionB,
          isCorrectOption:
              question.correctOption == QuizOption.b.name.toUpperCase(),
          isSelectedOption: notifier.selectedOption == QuizOption.b,
          isAnswerRevealed: notifier.isAnswerRevealed,
          onTap: () => notifier.selectOption(QuizOption.b),
        ),
        _buildOptionButton(
          label: 'C',
          text: question.optionC,
          isCorrectOption:
              question.correctOption == QuizOption.c.name.toUpperCase(),
          isSelectedOption: notifier.selectedOption == QuizOption.c,
          isAnswerRevealed: notifier.isAnswerRevealed,
          onTap: () => notifier.selectOption(QuizOption.c),
        ),
        _buildOptionButton(
          label: 'D',
          text: question.optionD,
          isCorrectOption:
              question.correctOption == QuizOption.d.name.toUpperCase(),
          isSelectedOption: notifier.selectedOption == QuizOption.d,
          isAnswerRevealed: notifier.isAnswerRevealed,
          onTap: () => notifier.selectOption(QuizOption.d),
        ),
        if (notifier.isAnswerRevealed) ...[
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
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: const Color(0xFF1A237E),
            ),
            onPressed: notifier.isLastQuestion
                ? () => Navigator.of(context).pop()
                : notifier.nextQuestion,
            child: Text(notifier.isLastQuestion ? 'End Quiz' : 'Next Question'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(QuizTableData question) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                question.category.isEmpty ? 'Practice' : question.category,
                style: const TextStyle(
                  color: Color(0xFFFFB300),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              question.difficulty,
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
    required bool isCorrectOption,
    required bool isSelectedOption,
    required bool isAnswerRevealed,
    required VoidCallback onTap,
  }) {
    final isCorrectRevealed = isCorrectOption && isAnswerRevealed;
    final isIncorrectSelection = isSelectedOption && !isCorrectOption;
    final borderColor = isCorrectRevealed
        ? const Color(0xFFFFB300)
        : isIncorrectSelection
        ? const Color(0xFFD32F2F)
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
