import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/app_database.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final ArticleLocal article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final sections = article.content != null ? jsonDecode(article.content!) : {};

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
        actions: [
          // THE BOOKMARK BUTTON
          StreamBuilder<List<Bookmark>>(
            stream: (db.select(db.bookmarks)..where((t) => t.articleId.equals(article.id))).watch(),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.hasData && snapshot.data!.isNotEmpty;
              return IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () async {
                  if (isBookmarked) {
                    await (db.delete(db.bookmarks)..where((t) => t.articleId.equals(article.id))).go();
                  } else {
                    await db.into(db.bookmarks).insert(BookmarksCompanion.insert(articleId: article.id));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Definition', sections['definition'], Icons.info_outline),
            _buildSection('Treatment', sections['treatment'], Icons.medication),
            
            const SizedBox(height: 20),
            
            // THE VIDEO BUTTON
            if (article.videoUrl != null && article.videoUrl!.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("WATCH INSTRUCTOR VIDEO"),
                onPressed: () async {
                  final url = Uri.parse(article.videoUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, dynamic content, IconData icon) {
    if (content == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF1A237E)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(content.toString()))],
      ),
    );
  }
}