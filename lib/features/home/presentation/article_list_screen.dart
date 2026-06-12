import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../articles/data/article_repository.dart';
import '../../articles/presentation/article_detail_screen.dart';

class ArticleListScreen extends ConsumerWidget {
  final String category;
  const ArticleListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(allArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: articlesAsync.when(
        data: (articles) {
          final filtered = articles.where((a) => a.category == category).toList();
          return filtered.isEmpty
              ? const Center(child: Text('No articles in this section yet.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final article = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                        ),
                      ),
                    );
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}