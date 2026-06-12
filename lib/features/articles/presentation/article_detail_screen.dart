import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            
            // 1. PATHOPHYSIOLOGY DIAGRAM (Step 4 Implementation)
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    placeholder: (context, url) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // 2. SPECIALTY TAG (The "AMBOSS" Style Bubble)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article.category?.toUpperCase() ?? 'GENERAL',
                style: const TextStyle(
                  color: Color(0xFF1A237E), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12
                ),
              ),
            ),

            // 3. ARTICLE CONTENT SECTIONS
            _buildSection('Definition', sections['definition'], Icons.info_outline),
            _buildSection('Epidemiology', sections['epidemiology'], Icons.public),
            _buildSection('Etiology', sections['etiology'], Icons.biotech),
            _buildSection('Pathophysiology', sections['pathophysiology'], Icons.psychology_outlined),
            _buildSection('Clinical Features', sections['clinicalFeatures'], Icons.list_alt),
            _buildSection('Diagnosis', sections['diagnosis'], Icons.search),
            _buildSection('Treatment', sections['treatment'], Icons.medication),
            _buildSection('Complications', sections['complications'], Icons.warning_amber_rounded),

            const SizedBox(height: 20),

            // 4. THE VIDEO BUTTON
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
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, dynamic content, IconData icon) {
    if (content == null || content.toString().isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF1A237E)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content.toString(),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}