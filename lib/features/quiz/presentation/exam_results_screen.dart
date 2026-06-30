import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../exam_session_notifier.dart';

class ExamResultsScreen extends ConsumerWidget {
  const ExamResultsScreen({super.key});

  Map<String, ({int correct, int total})> _calculateCategoryBreakdown(
    List<QuizQuestionEntity> questions,
    Map<int, String> answers,
  ) {
    final breakdown = <String, ({int correct, int total})>{};

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final category = question.category.isEmpty ? 'Unknown' : question.category;
      final correctOption = question.correctOption.toLowerCase();
      final userAnswer = answers[i];

      final current = breakdown[category] ?? (correct: 0, total: 0);
      final isCorrect = userAnswer == correctOption;
      breakdown[category] = (
        correct: current.correct + (isCorrect ? 1 : 0),
        total: current.total + 1,
      );
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examSessionProvider);
    final theme = Theme.of(context);

    final questions = state.questions;
    final answers = state.answers;
    final total = answers.length;
    final correct = answers.entries.where((e) {
      final qIndex = e.key;
      if (qIndex >= questions.length) return false;
      final question = questions[qIndex];
      return e.value == question.correctOption.toLowerCase();
    }).length;

    final scorePercent = total > 0 ? ((correct / total) * 100).round() : 0;
    final breakdown = _calculateCategoryBreakdown(questions, answers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: CloseButton(onPressed: () => context.go('/home')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '$scorePercent%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $correct / $total correct',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Performance by Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              itemBuilder: (context, index) {
                final entry = breakdown.entries.elementAt(index);
                final category = entry.key;
                final data = entry.value;
                final percent = data.total > 0 ? data.correct / data.total : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                          Text(
                            '${data.correct} / ${data.total}',
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (percent as double?) ?? 0.0,
                        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(examSessionProvider.notifier).startExam();
                      if (context.mounted) {
                        context.push('/exam');
                      }
                    },
                    child: const Text('Retake Exam'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review mode coming soon')),
                      );
                    },
                    child: const Text('Review Wrong Answers'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}