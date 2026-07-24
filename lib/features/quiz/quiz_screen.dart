import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/config/app_config.dart';
import '../../../features/content/data/content_flag_service.dart';
import '../../../features/content/presentation/content_flag_widget.dart';
import '../../../features/progress/streak_notifier.dart';
import 'quiz_notifier.dart';
import 'quiz_option.dart';
import '../../../features/settings/reading_mode_provider.dart';

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
  Widget build(BuildContext context) {
    final state = ref.watch(quizNotifierProvider(_defaultQuizCategory));
    final notifier = ref.read(
      quizNotifierProvider(_defaultQuizCategory).notifier,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => _resetQuizAndPop(context)),
        title: Text('${notifier.correctThisSession} / ${notifier.totalThisSession}'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.when(
              data: (questions) => questions.isEmpty
                  ? _buildEmptyState(notifier)
                  : _buildQuiz(context, questions, notifier),
              loading: () => _buildShimmerQuestionCard(),
              error: (error, _) => _buildErrorState(notifier),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerQuestionCard() {
    final shimmerTheme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: shimmerTheme.colorScheme.surfaceContainerHighest,
      highlightColor: shimmerTheme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 18,
            width: 120,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Container(
            height: 22,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Container(
            height: 22,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(QuizNotifier notifier) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const EmptyState(
          icon: Icons.check_circle_outline,
          title: 'All caught up!',
          subtitle: 'No cards due for review. Come back tomorrow.',
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
              onPressed: () => unawaited(notifier.syncQuestions()),
              child: const Text('Download Questions'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(QuizNotifier notifier) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 72, color: theme.colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            'Unable to load quiz questions.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
              onPressed: () => unawaited(notifier.syncQuestions()),
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
    final theme = Theme.of(context);
    final question = notifier.currentQuestion;
    final readingMode = ref.watch(readingModeProvider);
    if (question == null) {
      return const SizedBox.shrink();
    }

    final effectiveBackground = readingMode.sepia
        ? const Color(0xFFF4ECD8)
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = readingMode.sepia
        ? const Color(0xFF3B2F1E)
        : theme.colorScheme.onSurface;

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
               color: effectiveBackground,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: theme.colorScheme.secondary),
             ),
             child: Text(
               'Explanation: ${question.explanation}',
               style: TextStyle(height: 1.5, color: textColor),
             ),
           ),
           if (question.attendingTip != null &&
               question.attendingTip!.isNotEmpty) ...[
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: readingMode.sepia
                     ? const Color(0xFFE8DCC0)
                     : theme.colorScheme.secondaryContainer,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: theme.colorScheme.secondary),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.tips_and_updates,
                         size: 18,
                         color: theme.colorScheme.secondary,
                       ),
                       const SizedBox(width: 8),
                       Text(
                         'Attending Tip',
                         style: theme.textTheme.titleSmall?.copyWith(
                           color: readingMode.sepia
                               ? const Color(0xFF3B2F1E)
                               : theme.colorScheme.secondary,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(
                     question.attendingTip!,
                     style: TextStyle(
                       height: 1.5,
                       color: textColor,
                     ),
                   ),
                 ],
               ),
             ),
           ],
           const SizedBox(height: 16),
           if (question.articleId.isNotEmpty)
             SizedBox(
               width: double.infinity,
               child: OutlinedButton.icon(
                 icon: const Icon(Icons.article_outlined, size: 18),
                 label: const Text('Source Article'),
                 onPressed: () => context.push('/article-detail', extra: {'id': question.articleId, 'section': question.testedField}),
               ),
             ),
           const SizedBox(height: 12),
           ContentFlagWidget(
             contentType: ContentType.question,
             contentId: question.remoteId,
           ),
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
            Flexible(
              fit: FlexFit.loose,
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
            Flexible(
              fit: FlexFit.loose,
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
            Flexible(
              fit: FlexFit.loose,
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
            Flexible(
              fit: FlexFit.loose,
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
          : () {
              HapticFeedback.mediumImpact();
              _recordReviewAndAdvance(question, quality, notifier);
            },
      child: Text(label),
    );
  }

  Widget _buildNextReviewLabel(int? interval) {
    final theme = Theme.of(context);
    return Text(
      'Next review: ${_formatNextReview(interval)}',
      textAlign: TextAlign.center,
      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
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
      if (notifier.wrongAnswerCount > 0) {
        _showRetryScreen(context, notifier.wrongQuestionIds);
      } else {
        _resetQuizAndPop(context);
      }
      return;
    }

    await notifier.nextQuestion();
  }

  Future<void> _resetQuizAndPop(BuildContext context) async {
    final notifier = ref.read(quizNotifierProvider(_defaultQuizCategory).notifier);
    await notifier.saveCurrentStateToDrift();
    if (!mounted) {
      return;
    }

    notifier.reset();
    if (context.mounted) {
      final canPop = context.canPop();
      if (canPop) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  void _showRetryScreen(BuildContext context, List<int> wrongQuestionIds) {
    final count = wrongQuestionIds.length;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review Wrong Answers?'),
        content: Text('$count question${count > 1 ? 's' : ''} answered incorrectly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetQuizAndPop(context);
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final notifier = ref.read(quizNotifierProvider(_defaultQuizCategory).notifier);
              await notifier.loadQuestionsByIds(wrongQuestionIds);
            },
            child: Text('Retry $count wrong answer${count > 1 ? 's' : ''}'),
          ),
        ],
      ),
    );
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
    final theme = Theme.of(context);
    final isPastExam = question.sourceType == 'past_exam';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                question.category.isEmpty ? 'Practice' : question.category,
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              question.difficulty,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.stem,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (isPastExam) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_edu,
                  size: 14,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Real Exam Question — ${question.examYear ?? ''}',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final isCorrectRevealed = isCorrectOption && isAnswerRevealed;
    final isIncorrectSelection = isSelectedOption && !isCorrectOption;
    final borderColor = isCorrectRevealed
        ? theme.colorScheme.secondary
        : isIncorrectSelection
            ? theme.colorScheme.error
            : theme.colorScheme.outline;

return Padding(
       padding: const EdgeInsets.only(bottom: 10),
       child: InkWell(
         onTap: () {
           HapticFeedback.selectionClick();
           onTap();
         },
         borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                child: Text(label),
              ),
              const SizedBox(width: 12),
              Flexible(fit: FlexFit.loose, child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface))),
            ],
          ),
        ),
      ),
    );
  }
}