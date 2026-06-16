import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final ArticleLocal article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final sections = _decodeSections(article.content);
    final imageUrl = article.imageUrl;
    final videoUrl = article.videoUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
        actions: [
          StreamBuilder<List<Bookmark>>(
            stream: (db.select(
              db.bookmarks,
            )..where((t) => t.articleId.equals(article.id))).watch(),
            builder: (context, snapshot) {
              final bookmarkList = snapshot.data;
              final isBookmarked =
                  bookmarkList != null && bookmarkList.isNotEmpty;
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () async {
                  if (isBookmarked) {
                    await (db.delete(
                      db.bookmarks,
                    )..where((t) => t.articleId.equals(article.id))).go();
                  } else {
                    await db
                        .into(db.bookmarks)
                        .insert(
                          BookmarksCompanion.insert(articleId: article.id),
                        );
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
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),

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
                  fontSize: 12,
                ),
              ),
            ),

            _buildSection(
              'Definition',
              sections['definition'],
              Icons.info_outline,
            ),
            _buildSection(
              'Epidemiology',
              sections['epidemiology'],
              Icons.public,
            ),
            _buildSection('Etiology', sections['etiology'], Icons.biotech),
            _buildSection(
              'Pathophysiology',
              sections['pathophysiology'],
              Icons.psychology_outlined,
            ),
            _buildSection(
              'Clinical Features',
              sections['clinicalFeatures'],
              Icons.list_alt,
            ),
            _buildRedFlagsSection(sections),
            _buildSection('Diagnosis', sections['diagnosis'], Icons.search),
            _buildApproachSection(sections),
            _buildSection('Treatment', sections['treatment'], Icons.medication),
            _buildContraindicationsSection(sections),
            _buildSection(
              'Complications',
              sections['complications'],
              Icons.warning_amber_rounded,
            ),
            _buildClinicalPearlsSection(sections),
            _buildEthiopianContextSection(sections),
            _buildMnemonicsSection(sections),

            const SizedBox(height: 20),

            if (videoUrl != null && videoUrl.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: const Color(0xFF1A237E),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('WATCH INSTRUCTOR VIDEO'),
                onPressed: () async {
                  final url = Uri.tryParse(videoUrl);
                  if (url == null) {
                    return;
                  }
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

  Widget _buildSection(String title, Object? content, IconData icon) {
    if (content == null || content.toString().isEmpty) {
      return const SizedBox.shrink();
    }

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
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

  Widget _buildEthiopianContextSection(Map<String, Object?> sections) {
    final ethiopianContext = _optionalString(sections['ethiopianContext']);
    if (ethiopianContext == null || ethiopianContext.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: '🇪🇹 Ethiopian Clinical Pearl',
      content: ethiopianContext,
      icon: Icons.local_hospital_outlined,
      initiallyExpanded: true,
      backgroundColor: const Color(0xFFFFF8E1),
      borderColor: const Color(0xFFF9A825),
    );
  }

  Widget _buildRedFlagsSection(Map<String, Object?> sections) {
    final redFlags = _markdownContent(sections['redFlags']);
    if (redFlags == null) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: 'Red Flags',
      content: redFlags,
      icon: Icons.warning_rounded,
      initiallyExpanded: true,
      backgroundColor: const Color(0xFFFFEBEE),
      borderColor: const Color(0xFFD32F2F),
    );
  }

  Widget _buildApproachSection(Map<String, Object?> sections) {
    final approach = _markdownContent(sections['approach']);
    if (approach == null) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: 'Approach',
      content: approach,
      icon: Icons.format_list_numbered,
      initiallyExpanded: true,
      backgroundColor: const Color(0xFFE3F2FD),
      borderColor: const Color(0xFF1976D2),
    );
  }

  Widget _buildContraindicationsSection(Map<String, Object?> sections) {
    final contraindications = _markdownContent(sections['contraindications']);
    if (contraindications == null) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: 'Contraindications',
      content: contraindications,
      icon: Icons.report_problem_outlined,
      initiallyExpanded: false,
      backgroundColor: const Color(0xFFFFF3E0),
      borderColor: const Color(0xFFF57C00),
    );
  }

  Widget _buildClinicalPearlsSection(Map<String, Object?> sections) {
    final clinicalPearls = _markdownContent(sections['clinicalPearls']);
    if (clinicalPearls == null) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: 'Clinical Pearls',
      content: clinicalPearls,
      icon: Icons.lightbulb_outline,
      initiallyExpanded: false,
      backgroundColor: const Color(0xFFFFF8E1),
      borderColor: const Color(0xFFF9A825),
    );
  }

  Widget _buildMnemonicsSection(Map<String, Object?> sections) {
    final mnemonics = _optionalString(sections['mnemonics']);
    if (mnemonics == null || mnemonics.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildMarkdownExpansionTile(
      title: '🧠 Mnemonics',
      content: mnemonics,
      icon: Icons.auto_awesome_mosaic_outlined,
      initiallyExpanded: false,
      backgroundColor: const Color(0xFFE8F5E9),
      borderColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildMarkdownExpansionTile({
    required String title,
    required String content,
    required IconData icon,
    required bool initiallyExpanded,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: ExpansionTile(
        backgroundColor: backgroundColor,
        collapsedBackgroundColor: backgroundColor,
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: const Color(0xFF1A237E)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(data: content),
          ),
        ],
      ),
    );
  }

  Map<String, Object?> _decodeSections(String? encodedContent) {
    if (encodedContent == null || encodedContent.trim().isEmpty) {
      return const <String, Object?>{};
    }

    try {
      final decoded = jsonDecode(encodedContent);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value));
      }
    } catch (error) {
      debugPrint('Unable to decode article content: $error');
    }

    return const <String, Object?>{};
  }

  String? _markdownContent(Object? value) {
    if (value is String) {
      if (value.trim().isEmpty) {
        return null;
      }
      return value;
    }

    if (value is List<Object?>) {
      final items = value
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
      if (items.isEmpty) {
        return null;
      }
      return items
          .asMap()
          .entries
          .map((entry) {
            return '${entry.key + 1}. ${entry.value}';
          })
          .join('\n');
    }

    return null;
  }

  String? _optionalString(Object? value) {
    if (value is String) {
      return value;
    }

    return null;
  }
}
