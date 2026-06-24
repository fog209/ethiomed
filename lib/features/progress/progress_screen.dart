import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'progress_notifier.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: progressAsync.when(
        loading: () => const _ProgressLoading(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to load progress.',
                style: TextStyle(color: Colors.white70),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('PROGRESS_ERROR_TYPE: ${error.runtimeType}');
                  debugPrint('PROGRESS_ERROR_DETAIL: $error');
                  ref.invalidate(progressNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final streak = data.streak;
          final heatmapByDate = data.heatmapByDate;

          // Grid: 52 columns x 7 rows, horizontally scrollable.
          // Iterate days from DateTime.now() - 364 days.
          const cols = 52;
          const rows = 7;
          const totalCells = cols * rows; // 364

          final start = DateTime.now().subtract(
            const Duration(days: totalCells - 1),
          );

          // Build study activity columns (each column represents a week).
          final List<List<int>> grid = List.generate(
            rows,
            (_) => List<int>.filled(cols, 0, growable: false),
            growable: false,
          );

          for (var dayIndex = 0; dayIndex < totalCells; dayIndex++) {
            final date = DateTime(
              start.year,
              start.month,
              start.day,
            ).add(Duration(days: dayIndex));
            final key = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

            final articlesRead = heatmapByDate[key] ?? 0;

            final col = dayIndex ~/ rows; // 0..51
            final row = dayIndex % rows; // 0..6

            if (col < cols && row < rows) {
              grid[row][col] = articlesRead;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // SECTION 1 — Stat Cards Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Day Streak',
                      value: '🔥 ${streak.currentStreak}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Articles',
                      value: '${streak.totalArticles}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Quiz Score',
                      value: '${streak.accuracy.toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Days Active',
                      value: '${_estimateDaysActive(heatmapByDate)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // SECTION 2 — Study Heatmap
              const Text(
                'Study Activity — Past Year',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(cols, (colIndex) {
                    return Column(
                      children: List.generate(rows, (rowIndex) {
                        final articlesRead = grid[rowIndex][colIndex];
                        final color = _heatmapColor(articlesRead);

                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 3 — Category Progress
              const Text(
                'Category Progress',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              for (final row in data.categoryProgress)
                _CategoryProgressRow(
                  category: row.category,
                  read: row.read,
                  total: row.total,
                ),

              const SizedBox(height: 20),

              // SECTION 4 — Quiz Accuracy by Category
              const Text(
                'Quiz Accuracy by Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              for (final row in data.quizAccuracyByCategory)
                _QuizAccuracyRow(
                  category: row.category,
                  correct: row.correct,
                  total: row.total,
                ),
            ],
          );
        },
      ),
    );
  }

  int _estimateDaysActive(Map<String, int> heatmapByDate) {
    // "Days Active" best-effort: count of days with articles_read > 0.
    int days = 0;
    for (final entry in heatmapByDate.entries) {
      if (entry.value > 0) days++;
    }
    return days;
  }

  Color _heatmapColor(int articlesRead) {
    const navy = Color(0xFF1A237E);
    const gold = Color(0xFFF9A825);

    // Avoid deprecated Color.withOpacity.
    if (articlesRead == 0) {
      return navy.withAlpha((0.15 * 255).round());
    }
    if (articlesRead >= 1 && articlesRead <= 3) {
      return navy.withAlpha((0.45 * 255).round());
    }
    if (articlesRead >= 4 && articlesRead <= 9) {
      return gold.withAlpha((0.6 * 255).round());
    }
    return gold;
  }
}

class _ProgressLoading extends StatelessWidget {
  const _ProgressLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _StatCard(label: 'Day Streak', value: '—', isLoading: true),
        SizedBox(height: 12),
        Text(
          'Study Activity — Past Year',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final valueColor = Theme.of(context).colorScheme.secondary;
    
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: textColor?.withValues(alpha: 0.7), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.category,
    required this.read,
    required this.total,
  });

  final String category;
  final int read;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : read / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$category $read/$total',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFFF9A825),
          ),
        ],
      ),
    );
  }
}

class _QuizAccuracyRow extends StatelessWidget {
  const _QuizAccuracyRow({
    required this.category,
    required this.correct,
    required this.total,
  });

  final String category;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : correct / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$category $correct/$total (${(pct * 100).toStringAsFixed(0)}%)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFFF9A825),
          ),
        ],
      ),
    );
  }
}
