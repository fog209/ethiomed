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
              Icon(icon, size: 40, color: const Color(0xFF1A237E)),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
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
                backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.2),
                color: const Color(0xFFF9A825),
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
                onPressed: () => ref.invalidate(categoryProgressProvider(name)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WardReady Specialties'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _buildBodyItems(streak, ref).length,
        itemBuilder: (context, index) => _buildBodyItems(streak, ref)[index],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Syncing with WardReady Cloud...'),
              duration: Duration(seconds: 1),
            ),
          );
          unawaited(ref.read(articleRepositoryProvider).syncInBackground());
        },
        child: const Icon(Icons.sync, color: Color(0xFF1A237E)),
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
    return _buildStudyStatsContainer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFF9A825),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            stats.currentStreak.toString(),
            style: _goldNumberStyle.copyWith(fontSize: 24),
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
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFFF9A825)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStatsContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }

  static const TextStyle _goldNumberStyle = TextStyle(
    color: Color(0xFFF9A825),
    fontWeight: FontWeight.bold,
  );

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFB300),
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
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
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
