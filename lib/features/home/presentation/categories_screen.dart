import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/config/app_config.dart';
import '../../../features/progress/category_progress_provider.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../articles/data/article_repository.dart';
import 'article_list_screen.dart';

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
    final progress = ref.watch(categoryProgressProvider(name));

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleListScreen(category: name),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              '${_categoryProgressRead(progress.value)}/${_categoryProgressTotal(progress.value)}',
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
              value: _categoryProgressValue(progress.value),
            ),
          ],
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
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
          const SizedBox(height: 80),
        ],
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

  Widget _buildStudyStatsRow(StudyStreakStats stats) {
    return _buildStudyStatsContainer(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            children: [
              const TextSpan(text: '🔥 Day '),
              TextSpan(
                text: stats.currentStreak.toString(),
                style: _goldNumberStyle,
              ),
              const TextSpan(text: ' Streak · '),
              TextSpan(
                text: '${stats.totalArticles}/441',
                style: _goldNumberStyle,
              ),
              const TextSpan(text: ' Articles · '),
              TextSpan(
                text: '${stats.accuracy.round()}%',
                style: _goldNumberStyle,
              ),
              const TextSpan(text: ' Quiz Accuracy'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyStatsLoadingRow() {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white70,
      child: _buildStudyStatsContainer(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: const Text(
            '🔥 Day 0 Streak · 0/441 Articles · 0% Quiz Accuracy',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
