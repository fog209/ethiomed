import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../features/progress/streak_notifier.dart';
import 'quiz_notifier.dart';
import 'quiz_option.dart';

const _defaultQuizCategory = AppConfig.internalMedicineCategory;
const _navy = Color(0xFF1A237E);
const _gold = Color(0xFFF9A825);

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
        leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(notifier.scoreText),
        backgroundColor: _navy,
        foregroundColor: _gold,
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
          const Icon(Icons.quiz_outlined, size: 72, color: _navy),
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
                backgroundColor: _gold,
                foregroundColor: _navy,
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
          const Icon(Icons.error_outline, size: 72, color: _navy),
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
                backgroundColor: _gold,
                foregroundColor: _navy,
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
              border: Border.all(color: _gold),
            ),
            child: Text(
              'Explanation: ${question.explanation}',
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildSm2Buttons(question, notifier),
        ],
      ],
    );
  }

  Widget _buildSm2Buttons(QuizTableData question, QuizNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSm2Button(
                label: 'Again',
                quality: 0,
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                question: question,
                notifier: notifier,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSm2Button(
                label: 'Hard',
                quality: 2,
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
                question: question,
                notifier: notifier,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSm2Button(
                label: 'Good',
                quality: 4,
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                question: question,
                notifier: notifier,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSm2Button(
                label: 'Easy',
                quality: 5,
                backgroundColor: _gold,
                foregroundColor: _navy,
                question: question,
                notifier: notifier,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildNextReviewLabel(notifier.lastReviewInterval),
      ],
    );
  }

  Widget _buildSm2Button({
    required String label,
    required int quality,
    required Color backgroundColor,
    required Color foregroundColor,
    required QuizTableData question,
    required QuizNotifier notifier,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        minimumSize: const Size(0, 48),
      ),
      onPressed: notifier.isRecordingReview
          ? null
          : () => _recordReviewAndAdvance(question, quality, notifier),
      child: Text(label),
    );
  }

  Widget _buildNextReviewLabel(int? interval) {
    return Text(
      'Next review: ${_formatNextReview(interval)}',
      textAlign: TextAlign.center,
      style: const TextStyle(color: _navy, fontWeight: FontWeight.w600),
    );
  }

  Future<void> _recordReviewAndAdvance(
    QuizTableData question,
    int quality,
    QuizNotifier notifier,
  ) async {
    final selectedOption = notifier.selectedOption;
    final isCorrect =
        selectedOption != null &&
        question.correctOption == selectedOption.name.toUpperCase();

    await notifier.recordReview(question.id, quality);
    await ref.read(streakNotifierProvider.notifier).recordQuizResult(isCorrect);
    if (!mounted) {
      return;
    }

    if (notifier.isLastQuestion) {
      Navigator.of(context).pop();
      return;
    }

    await notifier.nextQuestion();
  }

  String _formatNextReview(int? interval) {
    if (interval == null) {
      return '—';
    }

    if (interval <= 0) {
      return 'today';
    }

    if (interval == 1) {
      return 'tomorrow';
    }

    if (interval <= 7) {
      return 'in $interval days';
    }

    final due = DateTime.now().add(Duration(days: interval));
    return 'in $interval days (${_formatMonthDay(due)})';
  }

  String _formatMonthDay(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
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
                  color: _gold,
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
            color: _navy,
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
        ? _gold
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
                backgroundColor: _navy,
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
