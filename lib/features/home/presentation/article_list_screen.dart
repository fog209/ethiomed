import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../articles/data/article_repository.dart';
import '../../articles/presentation/article_detail_screen.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  final String category;
  const ArticleListScreen({super.key, required this.category});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
  @override
  void initState() {
    super.initState();
    // SAFE: Triggering logic in initState is allowed
    Future.microtask(() {
      ref.read(articleRepositoryProvider).fetchAndSyncArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ONLY READ here. No ".state =" or "ref.read(...).state" allowed.
    final articlesAsync = ref.watch(allArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: articlesAsync.when(
        data: (articles) {
          final filtered = articles.where((a) => 
            a.category?.trim().toLowerCase() == widget.category.trim().toLowerCase()
          ).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 80, color: const Color(0xFF1A237E).withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('No articles in ${widget.category} yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final article = filtered[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (c) => ArticleDetailScreen(article: article))
                  ),
                ),
              );
            },
          );
        },
        loading: () => _buildShimmer(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white),
          title: Container(height: 15, width: 100, color: Colors.white),
        ),
      ),
    );
  }
}