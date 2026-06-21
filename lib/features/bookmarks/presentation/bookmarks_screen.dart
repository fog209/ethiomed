import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    // This query joins Bookmarks with Articles to show the full article data
    final bookmarksStream = db.select(db.articles).join([
      innerJoin(db.bookmarks, db.bookmarks.articleId.equalsExp(db.articles.id)),
    ]).watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: StreamBuilder(
        stream: bookmarksStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.amber, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Could not load bookmarks.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No bookmarks yet',
              subtitle: 'Tap the bookmark icon on any article to save it',
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final row = results[index];
              final article = row.readTable(db.articles);

              return ListTile(
                leading: const Icon(Icons.bookmark, color: Color(0xFF1A237E)),
                title: Text(article.title),
                onTap: () => context.push('/article-detail', extra: article),
              );
            },
          );
        },
      ),
    );
  }
}
