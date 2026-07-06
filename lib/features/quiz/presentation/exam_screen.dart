import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../exam_session_notifier.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleExit(BuildContext ctx) async {
    final canPop = ctx.canPop();
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text('Progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted && canPop) {
      ctx.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(examSessionProvider.notifier).startExam();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examSessionProvider);
    final theme = Theme.of(context);

    ref.listen(examSessionProvider, (_, next) {
      if (next.isComplete) {
        context.push('/exam-results');
      }
    });

    final bool isLoading = !state.isActive && state.questions.isEmpty;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EHPLE Exam'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading exam questions...'),
            ],
          ),
        ),
      );
    }

    final questions = state.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EHPLE Exam'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          leading: CloseButton(onPressed: () {
            _handleExit(context);
          }),
        ),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentQuestion = questions[state.currentIndex];
    final currentAnswer = state.answers[state.currentIndex];
    final hasAnswered = currentAnswer != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EHPLE Exam'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          leading: CloseButton(onPressed: () {
            _handleExit(context);
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱ ${_formatTime(state.timeRemaining)}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        'Question ${state.currentIndex + 1} / ${questions.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentQuestion.category,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentQuestion.difficulty,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currentQuestion.stem,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionCard('A', currentQuestion.optionA, hasAnswered && currentAnswer == 'a'),
                _buildOptionCard('B', currentQuestion.optionB, hasAnswered && currentAnswer == 'b'),
                _buildOptionCard('C', currentQuestion.optionC, hasAnswered && currentAnswer == 'c'),
                _buildOptionCard('D', currentQuestion.optionD, hasAnswered && currentAnswer == 'd'),
                const SizedBox(height: 16),
                if (hasAnswered) ...[
                  Text(
                    'How confident were you?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ConfidenceRow(theme: theme),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                if (state.currentIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: hasAnswered
                        ? () {
                            ref.read(examSessionProvider.notifier).nextQuestion();
                          }
                        : null,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: hasAnswered
                        ? () {
                            ref.read(examSessionProvider.notifier).submitExam();
                          }
                        : null,
                    child: const Text('Submit Exam'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String label, String text, bool isSelected) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: isSelected
            ? null
            : () {
                ref.read(examSessionProvider.notifier)
                    .answerQuestion(label.toLowerCase());
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                child: Text(label),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfidenceRow extends ConsumerWidget {
  const _ConfidenceRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdx = ref.watch(examSessionProvider.select((s) => s.currentIndex));
    final currentConfidence = ref.watch(examSessionProvider.select((s) => s.confidenceLevels[currentIdx]));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildConfidenceChip(ref, 1, 'Guessing', currentConfidence),
        _buildConfidenceChip(ref, 2, 'Somewhat Sure', currentConfidence),
        _buildConfidenceChip(ref, 3, 'Confident', currentConfidence),
      ],
    );
  }

  Widget _buildConfidenceChip(WidgetRef ref, int level, String label, int? currentLevel) {
    final isSelected = currentLevel == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isSelected
          ? null
          : (selected) {
              if (selected) {
                ref.read(examSessionProvider.notifier).setConfidence(level);
              }
            },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.secondary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurface,
        fontSize: 12,
      ),
    );
  }
}