import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../analytics/achievement_provider.dart';

final totalStudyTimeProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTotalStudySeconds();
});

typedef PastExamCoverage = ({
  int totalPastExamQuestions,
  int masteredPastExamQuestions,
  double coveragePercent,
});

final pastExamCoverageProvider =
    FutureProvider<PastExamCoverage>((ref) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.customSelect('''
    SELECT 
      COUNT(*) as total_past_exam,
      SUM(CASE WHEN COALESCE(last_quality, 0) >= 3 THEN 1 ELSE 0 END) as mastered
    FROM quiz_table
    WHERE source_type = 'past_exam'
  ''').get();

  if (rows.isEmpty) {
    return (totalPastExamQuestions: 0, masteredPastExamQuestions: 0, coveragePercent: 0.0);
  }

  final row = rows.first;
  final total = row.read<int>('total_past_exam');
  final mastered = row.read<int?>('mastered') ?? 0;
  final coverage = total > 0 ? (mastered / total) * 100 : 0.0;

  return (totalPastExamQuestions: total, masteredPastExamQuestions: mastered, coveragePercent: coverage);
});

typedef SpecialtyAnalytics = ({
  String specialty,
  int totalQuestions,
  int attemptedQuestions,
  int correctAnswers,
  double accuracyPercent,
  double completionPercent,
});

final specialtyAnalyticsProvider =
    FutureProvider<List<SpecialtyAnalytics>>((ref) async {
  final db = ref.watch(databaseProvider);

  final rows = await db.customSelect('''
    SELECT
      category,
      COUNT(*) AS total,
      SUM(CASE WHEN wrong_count > 0 OR last_attempted_at IS NOT NULL THEN 1 ELSE 0 END) AS attempted,
      SUM(CASE WHEN COALESCE(last_quality, 0) >= 3 THEN 1 ELSE 0 END) AS correct
    FROM quiz_table
    WHERE category IS NOT NULL AND category != ''
    GROUP BY category
    ORDER BY category ASC
  ''').get();

  final categoryToSpecialty = <String, String>{
    'Internal Medicine': 'Internal Medicine',
    'Cardiology': 'Internal Medicine',
    'Pulmonology': 'Internal Medicine',
    'Infectious Diseases': 'Internal Medicine',
    'Pediatrics': 'Pediatrics',
    'Developmental Milestones': 'Pediatrics',
    'OB/GYN': 'OB/GYN',
    'Obstetrics': 'OB/GYN',
    'Gynecology': 'OB/GYN',
    'General Surgery': 'Surgery',
    'Psychiatry': 'Psychiatry',
    'Endocrinology': 'Internal Medicine',
    'Gastroenterology': 'Internal Medicine',
    'Ophthalmology': 'Ophthalmology',
    'ENT': 'ENT',
    'Dermatology': 'Dermatology',
    'Hematology': 'Internal Medicine',
    'Pharmacology': 'Pharmacology',
    'Microbiology': 'Preclinical',
    'Physiology': 'Preclinical',
    'Biochemistry': 'Preclinical',
    'Pathology': 'Preclinical',
    'Anatomy': 'Preclinical',
  };

  final Map<String, (int, int, int)> specialtyAgg = {};

  for (final row in rows) {
    final category = row.read<String>('category');
    final specialty = categoryToSpecialty[category] ?? 'Other';
    final total = row.read<int>('total');
    final attempted = row.read<int?>('attempted') ?? 0;
    final correct = row.read<int?>('correct') ?? 0;

    final current = specialtyAgg[specialty] ?? (0, 0, 0);
    specialtyAgg[specialty] = (
      current.$1 + total,
      current.$2 + attempted,
      current.$3 + correct,
    );
  }

  final results = <SpecialtyAnalytics>[];
  for (final entry in specialtyAgg.entries) {
    final specialty = entry.key;
    final t = entry.value.$1;
    final a = entry.value.$2;
    final c = entry.value.$3;

    final accuracy = t > 0 ? (c / t) * 100 : 0.0;
    final completion = t > 0 ? (a / t) * 100 : 0.0;

    results.add((
      specialty: specialty,
      totalQuestions: t,
      attemptedQuestions: a,
      correctAnswers: c,
      accuracyPercent: accuracy,
      completionPercent: completion,
    ));
  }

  results.sort((a, b) => a.accuracyPercent.compareTo(b.accuracyPercent));

  return results;
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  String _formatStudyTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(specialtyAnalyticsProvider);
    final studyTimeAsync = ref.watch(totalStudyTimeProvider);
    final pastExamCoverageAsync = ref.watch(pastExamCoverageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialty Analytics'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
studyTimeAsync.when(
             loading: () => const SizedBox.shrink(),
             error: (error, _) => Center(child: Text('Error loading study time')),
             data: (totalSeconds) => Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Total Study Time: ${_formatStudyTime(totalSeconds)}',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
pastExamCoverageAsync.when(
             loading: () => const SizedBox.shrink(),
             error: (error, _) => Center(child: Text('Error loading coverage')),
             data: (coverage) => Card(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Exam Coverage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: coverage.coveragePercent / 100,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.2),
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coverage.coveragePercent.toStringAsFixed(0)}% (${coverage.masteredPastExamQuestions}/${coverage.totalPastExamQuestions} questions)',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
),
           const SizedBox(height: 16),
           const TrophyCaseSection(),
           const SizedBox(height: 16),
           analyticsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error loading analytics: $error'),
            ),
            data: (analytics) {
              if (analytics.isEmpty) {
                return const Center(child: Text('No quiz data available.'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Areas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...analytics.take(3).map((a) => _SpecialtyTile(
                        specialty: a.specialty,
                        accuracy: a.accuracyPercent,
                        completion: a.completionPercent,
                        isWeak: true,
                      )),
                  const SizedBox(height: 24),
                  Text(
                    'All Specialties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...analytics.skip(3).map((a) => _SpecialtyTile(
                        specialty: a.specialty,
                        accuracy: a.accuracyPercent,
                        completion: a.completionPercent,
                        isWeak: false,
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({
    required this.specialty,
    required this.accuracy,
    required this.completion,
    required this.isWeak,
  });

  final String specialty;
  final double accuracy;
  final double completion;
  final bool isWeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isWeak
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  specialty,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${accuracy.toStringAsFixed(0)}% accuracy',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completion / 100,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.2),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              '${completion.toStringAsFixed(0)}% completion',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}