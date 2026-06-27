import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';
import 'search_history_service.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});

  @override
  ConsumerState<ArticleSearchScreen> createState() =>
      _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  final List<String> _categories = const <String>[
    'Cardiology',
    'Pulmonology',
    'Infectious Diseases',
    'Gastroenterology',
    'Neurology',
  ];

  void _runAfterBuild(VoidCallback callback) {
    Future.microtask(callback);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(allArticlesProvider);
    final history = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          style: TextStyle(color: onSurface),
          decoration: InputDecoration(
            hintText: 'Search WardReady...',
            hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _runAfterBuild(() {
              setState(() => _query = value.toLowerCase());
            });
          },
          onSubmitted: (value) {
            _runAfterBuild(() {
              ref.read(searchHistoryProvider.notifier).saveSearch(value);
            });
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) => _buildCategoryChip(_categories[index]),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? history.isEmpty
                    ? const Center(child: Text('Search for diseases...'))
                    : ListView.builder(
                        itemCount: history.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const ListTile(
                              title: Text(
                                'Recent Searches',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }

                          if (index == history.length + 1) {
                            return TextButton(
                              onPressed: () {
                                _runAfterBuild(() {
                                  ref
                                      .read(searchHistoryProvider.notifier)
                                      .clearHistory();
                                });
                              },
                              child: const Text('Clear'),
                            );
                          }

                          final historyItem = history[index - 1];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(historyItem),
                            onTap: () {
                              _runAfterBuild(() {
                                setState(() {
                                  _controller.text = historyItem;
                                  _query = historyItem.toLowerCase();
                                });
                              });
                            },
                          );
                        },
                      )
                : articlesAsync.when(
                    data: (articles) {
                      final filtered = articles.where((article) {
                        final matchesQuery = article.title
                            .toLowerCase()
                            .contains(_query);
                        final matchesCategory =
                            ref.read(selectedCategoryProvider) == null ||
                            article.category == ref.read(selectedCategoryProvider);
                        return matchesQuery && matchesCategory;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.search_off,
                          title: 'No results found',
                          subtitle: 'Try a different search term',
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final article = filtered[index];
                          return ListTile(
                            leading: const Icon(Icons.search),
                            title: Text(article.title),
                            onTap: () {
                              _runAfterBuild(() {
                                ref
                                    .read(searchHistoryProvider.notifier)
                                    .saveSearch(article.title);
                                context.push('/article-detail', extra: article);
                              });
                            },
                          );
                        },
                      );
                    },
                    loading: () => _buildShimmerSearchResults(),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(category),
        selected: selectedCategory == category,
        onSelected: (selected) {
          ref.read(selectedCategoryProvider.notifier).state =
              selected ? category : null;
        },
      ),
    );
  }

  Widget _buildShimmerSearchResults() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
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