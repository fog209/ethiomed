import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../articles/data/article_repository.dart';
import '../../articles/presentation/article_detail_screen.dart';
import '../../../core/database/app_database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start sync in background
    Future.microtask(() => ref.read(articleRepositoryProvider).fetchAndSyncArticles());
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(allArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EthioMed Library'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: articlesAsync.when(
        data: (articles) => articles.isEmpty
            ? const Center(child: Text('No articles yet. Tap sync!'))
            : ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1A237E),
                        child: Icon(Icons.menu_book, color: Color(0xFFFFB300), size: 20),
                      ),
                      title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(article.category ?? 'General Medicine'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(article: article),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () => ref.read(articleRepositoryProvider).fetchAndSyncArticles(),
        child: const Icon(Icons.sync, color: Color(0xFF1A237E)),
      ),
    );
  }
}