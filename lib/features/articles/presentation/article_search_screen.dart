import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/database/app_database.dart';
import '../data/article_search_provider.dart';
import '../../../core/widgets/empty_state.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<ArticleSearchScreen> createState() {
    return _ArticleSearchScreenState();
  }
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _categories = const <String>[
    'Cardiology',
    'Pulmonology',
    'Infectious Diseases',
    'Gastroenterology',
    'Neurology',
    'Nephrology',
    'Endocrinology',
    'Hematology',
    'OB/GYN',
    'Pharmacology',
  ];

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialQuery;
    if (initialQuery != null && initialQuery.isNotEmpty) {
      _controller.text = initialQuery;
      _runAfterBuild(() {
        ref.read(articleSearchControllerProvider.notifier).updateQuery(initialQuery);
      });
    } else {
      _runAfterBuild(() {
        ref.read(articleSearchControllerProvider.notifier).updateCategory(null);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runAfterBuild(VoidCallback callback) {
    Future.microtask(callback);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(articleSearchControllerProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: onSurface, fontSize: 18),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: 'Search diseases...',
            hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _runAfterBuild(() {
              ref
                  .read(articleSearchControllerProvider.notifier)
                  .updateQuery(value);
            });
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              searchState.totalCount > searchState.count
                  ? 'Showing ${searchState.count} of ${searchState.totalCount} matches'
                  : '${searchState.count} results found',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          _buildCategoryChips(searchState.category),
          Expanded(child: _buildResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(String? selectedCategory) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.colorScheme.outline;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: primary,
              side: isSelected
                  ? BorderSide(color: primary)
                  : BorderSide(color: outline),
              onSelected: (selected) {
                _runAfterBuild(() {
                  ref
                      .read(articleSearchControllerProvider.notifier)
                      .updateCategory(selected ? category : null);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(ArticleSearchState searchState) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    
    if (searchState.isLoading) {
      return _buildShimmerSearchResults();
    }

    if (searchState.hasError) {
      return Center(child: Text(searchState.message ?? 'Search failed.'));
    }

    if (searchState.results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.builder(
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final article = searchState.results[index];

        return ListTile(
          leading: Icon(Icons.search, color: primary),
          title: _buildHighlightedTitle(article.title, searchState.query),
trailing: Text(
             '~${article.estimatedReadMinutes} min',
             style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
           ),
          subtitle: Text(article.category ?? ''),
          onTap: () => context.push('/article-detail', extra: article),
        );
      },
    );
  }

  Widget _buildHighlightedTitle(String title, String query) {
    final primary = Theme.of(context).colorScheme.primary;
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return Text(title);
    }

    final matches = RegExp(
      RegExp.escape(trimmedQuery),
      caseSensitive: false,
    ).allMatches(title);

    if (matches.isEmpty) {
      return Text(title);
    }

    final spans = <InlineSpan>[];
    var currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: title.substring(currentIndex, match.start)));
      }

      spans.add(
        TextSpan(
          text: title.substring(match.start, match.end),
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < title.length) {
      spans.add(TextSpan(text: title.substring(currentIndex)));
    }

    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildShimmerSearchResults() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 14,
            width: double.infinity,
            color: Colors.white,
          ),
          subtitle: Container(
            height: 10,
            width: 120,
            margin: const EdgeInsets.only(top: 8),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
