import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/config/app_config.dart';
import '../../../features/progress/category_progress_provider.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../articles/data/article_repository.dart';

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
              Icon(icon, size: 40, color: theme.colorScheme.surface),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_categoryProgressRead(progress)}/${_categoryProgressTotal(progress)}',
                style: const TextStyle(
                  color: Colors.white,
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
              const Icon(Icons.sync_problem, color: Colors.amber, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Could not sync. Showing cached data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
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
    return [
      streak.when(
        data: _buildStudyStatsRow,
        loading: _buildStudyStatsLoadingRow,
        error: (_, _) => _buildStudyStatsErrorRow(ref),
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
          const Text(
            'day streak',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStatsLoadingRow() {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white70,
      child: _buildStudyStatsContainer(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('0', style: TextStyle(color: Colors.white, fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'day streak',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
          const Text(
            'Unable to load study progress.',
            style: TextStyle(
              color: Colors.white,
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
      child: _CategoryTile(name: 'General', icon: Icons.folder),
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
