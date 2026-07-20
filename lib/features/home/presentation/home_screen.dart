import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../articles/article_providers.dart';
import 'entry_point_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentlyReadAsync = ref.watch(recentlyReadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Quick Access'),
          ),
          SliverToBoxAdapter(child: const DailyPearlCard()),
          SliverToBoxAdapter(child: const CalculatorsEntryCard()),
          SliverToBoxAdapter(child: const CasesEntryCard()),
          SliverToBoxAdapter(child: const FlashcardsEntryCard()),
          SliverToBoxAdapter(child: const ExamModeEntryCard()),
          SliverToBoxAdapter(child: const ProgressEntryCard()),
          SliverToBoxAdapter(child: const DrugsEntryCard()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: _buildSectionHeader(context, 'Recently Read'),
            ),
          ),
          recentlyReadAsync.when(
            data: (items) => items.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Articles you open will appear here.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return _RecentlyReadTile(item: item);
                      },
                      childCount: items.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Loading...', style: TextStyle(fontSize: 14)),
              ),
            ),
            error: (_, _) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Recently read unavailable',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
}

class _RecentlyReadTile extends StatelessWidget {
  const _RecentlyReadTile({required this.item});

  final RecentlyReadArticle item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = ArticleLocal(
      id: item.id,
      title: item.title,
      category: item.category,
      subcategory: item.subcategory,
      content: item.content,
      imageUrl: item.imageUrl,
      videoUrl: item.videoUrl,
      isHighYield: item.isHighYield,
      parentCategory: item.parentCategory,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: item.isHighYield
            ? Icon(Icons.star, color: theme.colorScheme.primary, size: 20)
            : Icon(Icons.article_outlined, color: theme.colorScheme.primary),
        title: Text(
          item.title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: item.category != null && item.category!.isNotEmpty
            ? Text(
                item.category!,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.outline,
        ),
        onTap: () => context.push('/article-detail', extra: article),
      ),
    );
  }
}
