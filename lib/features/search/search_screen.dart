import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';
import 'package:ethiomed/features/articles/presentation/article_detail_screen.dart';
import 'search_history_service.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});

  @override
  ConsumerState<ArticleSearchScreen> createState() =>
      _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _selectedCategory;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search WardReady...',
            hintStyle: TextStyle(color: Colors.white60),
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
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          _runAfterBuild(() {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? history.isEmpty
                      ? const Center(child: Text('Search for diseases...'))
                      : ListView(
                          children: [
                            const ListTile(
                              title: Text(
                                'Recent Searches',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            ...history.map(
                              (historyItem) => ListTile(
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
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _runAfterBuild(() {
                                  ref
                                      .read(searchHistoryProvider.notifier)
                                      .clearHistory();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        )
                : articlesAsync.when(
                    data: (articles) {
                      final filtered = articles.where((article) {
                        final matchesQuery = article.title
                            .toLowerCase()
                            .contains(_query);
                        final matchesCategory =
                            _selectedCategory == null ||
                            article.category == _selectedCategory;
                        return matchesQuery && matchesCategory;
                      }).toList();

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) =>
                                        ArticleDetailScreen(article: article),
                                  ),
                                );
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
