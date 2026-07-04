import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/article_providers.dart';
import '../models/article.dart';

class ArticleCatalogScreen extends ConsumerStatefulWidget {
  const ArticleCatalogScreen({super.key});

  @override
  ConsumerState<ArticleCatalogScreen> createState() =>
      _ArticleCatalogScreenState();
}

class _ArticleCatalogScreenState extends ConsumerState<ArticleCatalogScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(articleSearchQueryProvider.notifier).state =
        _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final seedState = ref.watch(seedWardReadyCatalogProvider);
    final filteredArticles = ref.watch(filteredArticlesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WardReady'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sync mock catalog',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await ref
                  .read(wardReadyArticleRepositoryProvider)
                  .syncFromRemote();
              ref.invalidate(articleTitlesProvider);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock articles synced')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: seedState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _MessageState(
            icon: Icons.error_outline,
            title: 'Could not prepare the local catalog',
            subtitle: '$error',
          ),
          data: (_) => Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search articles',
                  leading: const Icon(Icons.search),
                  trailing: _searchController.text.isEmpty
                      ? null
                      : <Widget>[
                          IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: _searchController.clear,
                          ),
                        ],
                ),
              ),
              Expanded(
                child: filteredArticles.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _MessageState(
                    icon: Icons.error_outline,
                    title: 'Could not load local articles',
                    subtitle: '$error',
                  ),
                  data: (articles) {
                    if (articles.isEmpty) {
                      return const _MessageState(
                        icon: Icons.search_off,
                        title: 'No matching articles',
                        subtitle: 'Try a condition, category, or bedside clue.',
                      );
                    }
                    return _GroupedArticleList(articles: articles);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        icon: const Icon(Icons.cloud_download_outlined),
        label: const Text('Sync'),
        onPressed: () async {
          await ref.read(wardReadyArticleRepositoryProvider).syncFromRemote();
          ref.invalidate(articleTitlesProvider);
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock articles written locally')),
          );
        },
      ),
    );
  }
}

class _GroupedArticleList extends StatelessWidget {
  const _GroupedArticleList({required this.articles});

  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Article>>{};
    for (final article in articles) {
      grouped.putIfAbsent(article.parentCategory, () => <Article>[]).add(article);
    }

    final categories = grouped.keys.toList(growable: false)..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryArticles = grouped[category] ?? const <Article>[];
        return _CategorySection(category: category, articles: categoryArticles);
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.articles});

  final String category;
  final List<Article> articles;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 6),
            child: Text(
              category,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final article in articles)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(article.title),
                subtitle: Text(article.subcategory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(
                    '/articles/${Uri.encodeComponent(article.title)}',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 44, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
