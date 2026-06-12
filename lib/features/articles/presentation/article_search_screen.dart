import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/article_repository.dart';
import 'article_detail_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Navy
        foregroundColor: const Color(0xFFFFB300), // Gold
        iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
        title: TextField(
          controller: _controller,
          autofocus: true,
          // FIX: Explicitly set text style to be visible
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: const Color(0xFFFFB300), // Gold cursor
          decoration: const InputDecoration(
            hintText: 'Search diseases...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFFFFB300)),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
        ],
      ),
      body: articlesAsync.when(
        data: (articles) {
          final filtered = articles.where((a) {
            return a.title.toLowerCase().contains(_query) ||
                   (a.category?.toLowerCase().contains(_query) ?? false);
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No matching articles found.'));
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}