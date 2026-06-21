import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../data/article_search_provider.dart';
import 'article_detail_screen.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});

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
    _runAfterBuild(() {
      ref.read(articleSearchControllerProvider.notifier).updateCategory(null);
    });
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
        iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: const Color(0xFFFFB300),
          decoration: const InputDecoration(
            hintText: 'Search diseases...',
            hintStyle: TextStyle(color: Colors.white60),
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
              '${searchState.count} results found',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          _buildCategoryChips(searchState.category),
          Expanded(child: _buildResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(String? selectedCategory) {
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
              selectedColor: const Color(0xFFFFB300),
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
    if (searchState.isLoading) {
      return _buildShimmerSearchResults();
    }

    if (searchState.hasError) {
      return Center(child: Text(searchState.message ?? 'Search failed.'));
    }

    if (searchState.results.isEmpty) {
      return const Center(child: Text('No results. Try browsing by category.'));
    }

    return ListView.builder(
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final article = searchState.results[index];

        return ListTile(
          leading: const Icon(Icons.search, color: Color(0xFF1A237E)),
          title: _buildHighlightedTitle(article.title, searchState.query),
          subtitle: Text(article.category ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHighlightedTitle(String title, String query) {
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
          style: const TextStyle(
            color: Color(0xFFF9A825),
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
