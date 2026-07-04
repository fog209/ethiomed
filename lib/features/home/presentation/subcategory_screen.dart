import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

/// Fetches distinct subcategories for the given parent category from Drift.
final subcategoriesForParentProvider =
    FutureProvider.family<List<String>, String>((ref, parentCategory) async {
  final db = ref.watch(databaseProvider);
  return db.fetchSubcategories(parentCategory);
});

/// Holds the current in-screen search query (scoped to SubcategoryScreen use).
final _subcategorySearchQueryProvider = StateProvider<String>((ref) => '');

/// Returns search results when query is non-empty; null when idle.
final _subcategorySearchResultsProvider =
    FutureProvider.family<List<ArticleLocal>?, String>((ref, parentCategory) async {
  final query = ref.watch(_subcategorySearchQueryProvider).trim();
  if (query.isEmpty) return null;
  final db = ref.watch(databaseProvider);
  return db.searchWithinParent(parentCategory, query);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class SubcategoryScreen extends ConsumerStatefulWidget {
  final String parentCategory;

  const SubcategoryScreen({super.key, required this.parentCategory});

  @override
  ConsumerState<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends ConsumerState<SubcategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset search when screen opens.
    Future.microtask(
      () => ref.read(_subcategorySearchQueryProvider.notifier).state = '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(_subcategorySearchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(_subcategorySearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subcategoriesAsync =
        ref.watch(subcategoriesForParentProvider(widget.parentCategory));
    final searchQuery = ref.watch(_subcategorySearchQueryProvider);
    final isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentCategory),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface),
              cursorColor: theme.colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search in ${widget.parentCategory}...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Body: search results or subcategory list ────────────────────
          Expanded(
            child: isSearching
                ? _buildSearchResults(theme)
                : _buildSubcategoryList(theme, subcategoriesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    final resultsAsync =
        ref.watch(_subcategorySearchResultsProvider(widget.parentCategory));

    return resultsAsync.when(
      data: (results) {
        if (results == null || results.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No results',
            subtitle: 'Try a different search term',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            return _ArticleTile(article: article);
          },
        );
      },
      loading: () => _buildShimmerList(theme),
      error: (e, _) => Center(
        child: Text(
          'Search error: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(
    ThemeData theme,
    AsyncValue<List<String>> subcategoriesAsync,
  ) {
    return subcategoriesAsync.when(
      data: (subcategories) {
        // "View All Articles" tile is always first.
        final itemCount = 1 + subcategories.length;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ViewAllTile(parentCategory: widget.parentCategory);
            }
            final sub = subcategories[index - 1];
            return _SubcategoryTile(
              parentCategory: widget.parentCategory,
              subcategory: sub,
            );
          },
        );
      },
      loading: () => _buildShimmerList(theme),
      error: (e, _) => Center(
        child: Text(
          'Failed to load subcategories: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildShimmerList(ThemeData theme) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Container(
              height: 14,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ViewAllTile extends StatelessWidget {
  const _ViewAllTile({required this.parentCategory});

  final String parentCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.secondaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.list_alt,
          color: theme.colorScheme.secondary,
        ),
        title: Text(
          'View All Articles',
          style: TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Browse every article under $parentCategory',
          style: TextStyle(
            color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSecondaryContainer,
        ),
        onTap: () => context.push(
          '/article-list/${Uri.encodeComponent(parentCategory)}',
        ),
      ),
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  const _SubcategoryTile({
    required this.parentCategory,
    required this.subcategory,
  });

  final String parentCategory;
  final String subcategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.folder_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          subcategory,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.outline,
        ),
        onTap: () => context.push(
          '/article-list/${Uri.encodeComponent(subcategory)}'
          '?parentCategory=${Uri.encodeComponent(parentCategory)}',
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final ArticleLocal article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: article.isHighYield
            ? Icon(Icons.star, color: theme.colorScheme.primary, size: 20)
            : Icon(Icons.article_outlined, color: theme.colorScheme.primary),
        title: Text(
          article.title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: article.subcategory != null && article.subcategory!.isNotEmpty
            ? Text(
                article.subcategory!,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '~${article.estimatedReadMinutes} min',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
        onTap: () => context.push('/article-detail', extra: article),
      ),
    );
  }
}
