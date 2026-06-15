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
      appBar: AppBar(title: Text(category), backgroundColor: const Color(0xFF1A237E), foregroundColor: const Color(0xFFFFB300)),
      body: articlesAsync.when(
        data: (articles) {
          final filtered = articles.where((a) => a.category?.trim() == category.trim()).toList();
          if (filtered.isEmpty) return const Center(child: Text("No articles in this section yet."));
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(filtered[index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ArticleDetailScreen(article: filtered[index]))),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}