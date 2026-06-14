import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';
import 'package:ethiomed/features/articles/presentation/article_detail_screen.dart';
import 'search_history_service.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});

  @override
  ConsumerState<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

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
        foregroundColor: const Color(0xFFFFB300),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search diseases...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value.toLowerCase()),
        ),
      ),
      body: Column(
        children: [
          // Show history only when query is empty
          if (_query.isEmpty && history.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ...history.map((h) => ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(h),
                  onTap: () {
                    setState(() {
                      _controller.text = h;
                      _query = h.toLowerCase();
                    });
                  },
                )),
          ],
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                final filtered = articles.where((a) => a.title.toLowerCase().contains(_query)).toList();

                if (_query.isNotEmpty && filtered.isEmpty) {
                  return const Center(child: Text("No results found."));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final article = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.search, color: Color(0xFF1A237E)),
                      title: Text(article.title),
                      subtitle: Text(article.category ?? ''),
                      onTap: () {
                        // Save to history when an article is tapped
                        ref.read(searchHistoryProvider.notifier).saveSearch(article.title);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}