import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/sync_state_provider.dart';
import '../../../features/progress/category_progress_provider.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../../features/progress/weekly_stats_provider.dart';
import '../../articles/data/article_repository.dart';

final todayPlanProvider = FutureProvider<TodayPlanData>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  final dueRows = await db.customSelect(
    '''
    SELECT COUNT(*) AS count, category
    FROM quiz_table
    WHERE next_due_at IS NULL OR next_due_at <= ?
    GROUP BY category
    ORDER BY count DESC
    LIMIT 1
    ''',
    variables: [Variable(now)],
  ).get();

  int dueCount = 0;
  String category = '';

  if (dueRows.isNotEmpty) {
    dueCount = dueRows.first.read<int>('count');
    category = dueRows.first.read<String>('category');
  }

  final weakFieldRows = await db.customSelect(
    '''
    SELECT COUNT(DISTINCT tested_field) AS field_count
    FROM quiz_table
    WHERE last_quality IS NOT NULL AND last_quality < 3
    ''',
  ).get();

  final weakFieldCount = weakFieldRows.isNotEmpty
      ? weakFieldRows.first.read<int>('field_count')
      : 0;

  return (dueCount: dueCount, weakFieldCount: weakFieldCount, category: category);
});

typedef TodayPlanData = ({int dueCount, int weakFieldCount, String category});

int _categoryProgressRead(CategoryProgress? progress) => progress?.read ?? 0;

int _categoryProgressTotal(CategoryProgress? progress) => progress?.total ?? 0;

double _categoryProgressValue(CategoryProgress? progress) {
  final read = _categoryProgressRead(progress);
  final total = _categoryProgressTotal(progress);
  if (total == 0) {
    return 0;
  }

  return (read / total).clamp(0.0, 1.0).toDouble();
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsyncValue = ref.watch(categoryProgressProvider(name));
    final theme = Theme.of(context);

    return progressAsyncValue.when(
      data: (progress) => InkWell(
        onTap: () => context.push('/article-list/${Uri.encodeComponent(name)}'),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.secondary),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_categoryProgressRead(progress)}/${_categoryProgressTotal(progress)}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.2),
                color: theme.colorScheme.primary,
                value: _categoryProgressValue(progress),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync_problem, color: theme.colorScheme.secondary, size: 48),
              const SizedBox(height: 8),
              Text(
                'Could not sync. Showing cached data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('SYNC_ERROR_TYPE: ${error.runtimeType}');
                  debugPrint('SYNC_ERROR_DETAIL: $error');
                  ref.invalidate(categoryProgressProvider(name));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _didAutoSync = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_performAutoSyncIfNeeded);
  }

  Future<void> _performAutoSyncIfNeeded() async {
    if (_didAutoSync || !mounted) return;

    final repo = ref.read(articleRepositoryProvider);
    final localArticles = await ref.read(allArticlesProvider.future);

    if (localArticles.isEmpty) {
      _didAutoSync = true;
      unawaited(repo.syncInBackground().then((_) {
        if (!mounted) return;
        for (final cat in AppConfig.clinicalCategories) {
          ref.invalidate(categoryProgressProvider(cat['name'] as String));
        }
        for (final cat in AppConfig.preclinicalCategories) {
          ref.invalidate(categoryProgressProvider(cat['name'] as String));
        }
        ref.invalidate(categoryProgressProvider('General'));
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WardReady Specialties'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _buildBodyItems(streak, ref).length,
        itemBuilder: (context, index) => _buildBodyItems(streak, ref)[index],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Syncing with WardReady Cloud...'),
              duration: Duration(seconds: 1),
            ),
          );
          unawaited(
            ref.read(articleRepositoryProvider).syncInBackground().then((_) {
              if (!mounted) return;
              // Invalidate all category progress providers after sync
              for (final cat in AppConfig.clinicalCategories) {
                ref.invalidate(categoryProgressProvider(cat['name'] as String));
              }
              for (final cat in AppConfig.preclinicalCategories) {
                ref.invalidate(categoryProgressProvider(cat['name'] as String));
              }
              ref.invalidate(categoryProgressProvider('General'));
            }),
          );
        },
        child: Icon(Icons.sync, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  List<Widget> _buildBodyItems(
    AsyncValue<StudyStreakStats> streak,
    WidgetRef ref,
  ) {
    final todayPlanAsync = ref.watch(todayPlanProvider);
    final syncState = ref.watch(syncStateProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return [
      _buildSyncStatusRow(syncState),
      weeklyStatsAsync.when(
        data: (stats) => _buildWeeklySummaryCard(stats),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      _buildCalculatorsCard(),
      _buildCasesCard(),
      streak.when(
        data: _buildStudyStatsRow,
        loading: _buildStudyStatsLoadingRow,
        error: (_, _) => _buildStudyStatsErrorRow(ref),
      ),
      todayPlanAsync.when(
        data: (plan) => _buildTodaysPlanCard(plan),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      if (streak.isLoading) _buildShimmerCategoryGrid(),
      _buildSectionHeader('Clinical'),
      _buildCategoryGrid(AppConfig.clinicalCategories),
      const SizedBox(height: 24),
      _buildSectionHeader('Preclinical'),
      _buildCategoryGrid(AppConfig.preclinicalCategories),
      _buildFallbackGeneralTile(),
      const SizedBox(height: 80),
    ];
  }

  Widget _buildWeeklySummaryCard(WeeklyStats stats) {
    final theme = Theme.of(context);
    final accuracy = stats.quizzesAnswered > 0
        ? (stats.quizzesCorrect / stats.quizzesAnswered * 100).round()
        : 0;

    if (stats.articlesRead == 0 && stats.quizzesAnswered == 0) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This Week's Progress",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Complete a few quizzes to generate your first weekly report.',
                style: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final summaryLines = <String>[];

    if (accuracy >= 80) {
      summaryLines.add('Excellent week! $accuracy% accuracy.');
    } else if (accuracy >= 60) {
      summaryLines.add('Good progress this week. $accuracy% accuracy.');
    } else {
      summaryLines.add('$accuracy% quiz accuracy this week.');
    }

    if (stats.streak > 0) {
      summaryLines.add('You maintained a ${stats.streak}-day study streak.');
    }

    if (stats.strongestCategory.isNotEmpty) {
      summaryLines.add('${stats.strongestCategory} remains your strongest topic.');
    }

    if (stats.weakestCategory.isNotEmpty) {
      summaryLines.add('Focus on ${stats.weakestCategory} next week.');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This Week's Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Articles read: ${stats.articlesRead}',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 4),
            Text(
              'Quiz accuracy: $accuracy%',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 12),
            ...summaryLines.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusRow(SyncState syncState) {
    final theme = Theme.of(context);
    final lastSync = syncState.lastSuccessfulSyncAt;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          if (syncState.serverUnreachable) ...[
            Icon(
              Icons.wifi_off,
              color: theme.colorScheme.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Offline',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ] else
            Icon(
              Icons.wifi,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          const SizedBox(width: 8),
          Text(
            'Last synced ',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            _formatLastSync(lastSync),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildCalculatorsCard() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => context.push('/calculators'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.calculate,
                color: theme.colorScheme.secondary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Calculators',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quick medical calculations',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSecondaryContainer,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasesCard() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => context.push('/cases'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.medical_services,
                color: theme.colorScheme.secondary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Cases',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Case-based learning scenarios',
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSecondaryContainer,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysPlanCard(TodayPlanData plan) {
    final theme = Theme.of(context);
    final hasContent = plan.dueCount > 0 || plan.weakFieldCount > 0;
    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Plan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${plan.dueCount} card${plan.dueCount != 1 ? 's' : ''} due. '
              '${plan.weakFieldCount} weak section${plan.weakFieldCount != 1 ? 's' : ''} in ${plan.category}.',
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyStatsRow(StudyStreakStats stats) {
    final theme = Theme.of(context);
    return _buildStudyStatsContainer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            stats.currentStreak.toString(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
const SizedBox(width: 8),
           Text(
             'day streak',
             style: TextStyle(
               color: theme.colorScheme.onSurface,
               fontSize: 16,
               fontWeight: FontWeight.w600,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildStudyStatsLoadingRow() {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surface.withValues(alpha: 0.2),
      highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
      child: _buildStudyStatsContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, color: theme.colorScheme.onSurface, size: 24),
            const SizedBox(width: 8),
            Text('0', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'day streak',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyStatsErrorRow(WidgetRef ref) {
    final theme = Theme.of(context);
    return _buildStudyStatsContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unable to load study progress.',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(streakNotifierProvider),
            child: Text(
              'Retry',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStatsContainer({required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildShimmerCategoryGrid() {
    final categories = AppConfig.clinicalCategories.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 12, width: 100, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackGeneralTile() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: const _CategoryTile(name: 'General', icon: Icons.folder),
    );
  }

  Widget _buildCategoryGrid(List<Map<String, Object?>> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final name = category['name']?.toString() ?? '';
        final icon = category['icon'] as IconData? ?? Icons.category;

        return _CategoryTile(name: name, icon: icon);
      },
    );
  }
}