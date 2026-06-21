import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';
import '../../../features/articles/article_providers.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../../features/quiz/weakness_service.dart';

const _wardReadyGold = Color(0xFFF9A825);

class _ClinicalSectionConfig {
  const _ClinicalSectionConfig({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final bool initiallyExpanded;
}

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final ArticleLocal article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _showLowYieldSections = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) {
        return;
      }
      await ref.read(streakNotifierProvider.notifier).recordArticleRead();
      if (!mounted) {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final db = ref.watch(databaseProvider);
    final weakFields = ref.watch(weakFieldsProvider(widget.article.id));
    final highYieldMode = ref.watch(highYieldModeProvider);
    final sections = _decodeSections(widget.article.content);
    final imageUrl = widget.article.imageUrl;
    final videoUrl = widget.article.videoUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
        actions: [
          IconButton(
            tooltip: 'High-Yield Mode',
            color: highYieldMode ? _wardReadyGold : null,
            onPressed: () => ref.read(highYieldModeProvider.notifier).toggle(),
            icon: Icon(highYieldMode ? Icons.bolt : Icons.bolt_outlined),
          ),
          StreamBuilder<List<Bookmark>>(
            stream: (db.select(
              db.bookmarks,
            )..where((t) => t.articleId.equals(widget.article.id))).watch(),
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
                    await (db.delete(db.bookmarks)
                          ..where((t) => t.articleId.equals(widget.article.id)))
                        .go();
                  } else {
                    await db
                        .into(db.bookmarks)
                        .insert(
                          BookmarksCompanion.insert(
                            articleId: widget.article.id,
                          ),
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
                widget.article.category?.toUpperCase() ?? 'GENERAL',
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            ..._buildClinicalSections(
              sections,
              weakFields.value ?? const <String>{},
              highYieldMode,
            ),

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

  static const _clinicalSectionOrder = <String>[
    'definition',
    'epidemiology',
    'etiology',
    'pathophysiology',
    'clinicalFeatures',
    'redFlags',
    'approach',
    'diagnosis',
    'treatment',
    'contraindications',
    'dontMiss',
    'complications',
    'clinicalPearls',
    'ethiopianContext',
    'mnemonics',
    'examTraps',
  ];

  static const _nonHighlightableWeakFields = <String>{
    'ethiopianContext',
    'mnemonics',
  };

  static const _highYieldFields = <String>{
    'clinicalFeatures',
    'diagnosis',
    'treatment',
    'complications',
  };

  static const _mediumYieldFields = <String>{'etiology', 'pathophysiology'};

  static const _lowYieldFields = <String>{'definition', 'epidemiology'};

  static const _clinicalSections = <String, _ClinicalSectionConfig>{
    'definition': _ClinicalSectionConfig(
      title: '📝 Definition',
      icon: Icons.info_outline,
      backgroundColor: Color(0xFFE8EAF6),
      borderColor: Color(0xFF1A237E),
    ),
    'epidemiology': _ClinicalSectionConfig(
      title: '🌍 Epidemiology',
      icon: Icons.public,
      backgroundColor: Color(0xFFE3F2FD),
      borderColor: Color(0xFF1976D2),
    ),
    'etiology': _ClinicalSectionConfig(
      title: '🧬 Etiology',
      icon: Icons.biotech,
      backgroundColor: Color(0xFFE8F5E9),
      borderColor: Color(0xFF4CAF50),
    ),
    'pathophysiology': _ClinicalSectionConfig(
      title: '🔬 Pathophysiology',
      icon: Icons.psychology_outlined,
      backgroundColor: Color(0xFFE3F2FD),
      borderColor: Color(0xFF1976D2),
    ),
    'clinicalFeatures': _ClinicalSectionConfig(
      title: '🩺 Clinical Features',
      icon: Icons.list_alt,
      backgroundColor: Color(0xFFE8F5E9),
      borderColor: Color(0xFF4CAF50),
    ),
    'redFlags': _ClinicalSectionConfig(
      title: '🚩 Red Flags',
      icon: Icons.warning_rounded,
      backgroundColor: Color(0xFFFFEBEE),
      borderColor: Color(0xFFD32F2F),
      initiallyExpanded: true,
    ),
    'approach': _ClinicalSectionConfig(
      title: '🧭 Approach',
      icon: Icons.format_list_numbered,
      backgroundColor: Color(0xFFE3F2FD),
      borderColor: Color(0xFF1976D2),
      initiallyExpanded: true,
    ),
    'diagnosis': _ClinicalSectionConfig(
      title: '🔎 Diagnosis',
      icon: Icons.search,
      backgroundColor: Color(0xFFE8EAF6),
      borderColor: Color(0xFF1A237E),
    ),
    'treatment': _ClinicalSectionConfig(
      title: '💊 Treatment',
      icon: Icons.medication,
      backgroundColor: Color(0xFFE8F5E9),
      borderColor: Color(0xFF4CAF50),
    ),
    'contraindications': _ClinicalSectionConfig(
      title: '🛑 Contraindications',
      icon: Icons.report_problem_outlined,
      backgroundColor: Color(0xFFFFF3E0),
      borderColor: Color(0xFFF57C00),
    ),
    'dontMiss': _ClinicalSectionConfig(
      title: "🚨 Don't Miss",
      icon: Icons.priority_high,
      backgroundColor: Color(0xFFFFF8E1),
      borderColor: Color(0xFFF9A825),
    ),
    'complications': _ClinicalSectionConfig(
      title: '⚠️ Complications',
      icon: Icons.warning_amber_rounded,
      backgroundColor: Color(0xFFFFF3E0),
      borderColor: Color(0xFFF57C00),
    ),
    'clinicalPearls': _ClinicalSectionConfig(
      title: '💡 Clinical Pearls',
      icon: Icons.lightbulb_outline,
      backgroundColor: Color(0xFFFFF8E1),
      borderColor: Color(0xFFF9A825),
    ),
    'ethiopianContext': _ClinicalSectionConfig(
      title: '🇪🇹 Ethiopian Clinical Pearl',
      icon: Icons.local_hospital_outlined,
      backgroundColor: Color(0xFFFFF8E1),
      borderColor: Color(0xFFF9A825),
      initiallyExpanded: true,
    ),
    'mnemonics': _ClinicalSectionConfig(
      title: '🧠 Mnemonics',
      icon: Icons.auto_awesome_mosaic_outlined,
      backgroundColor: Color(0xFFE8F5E9),
      borderColor: Color(0xFF4CAF50),
    ),
    'examTraps': _ClinicalSectionConfig(
      title: '🪤 Exam Traps',
      icon: Icons.quiz_outlined,
      backgroundColor: Color(0xFFEDE7F6),
      borderColor: Color(0xFF673AB7),
    ),
  };

  List<Widget> _buildClinicalSections(
    Map<String, Object?> sections,
    Set<String> weakFields,
    bool highYieldMode,
  ) {
    return _clinicalSectionOrder
        .map((key) {
          final config = _clinicalSections[key];
          if (config == null) {
            return null;
          }

          final isLowYield = _lowYieldFields.contains(key);
          if (highYieldMode && isLowYield && !_showLowYieldSections) {
            if (key == 'definition') {
              return _buildShowLowYieldButton();
            }
            return null;
          }

          final content = _markdownContent(sections[key]);
          if (content == null) {
            return null;
          }

          final isWeak =
              weakFields.contains(key) &&
              !_nonHighlightableWeakFields.contains(key);
          final isHighYield = highYieldMode && _highYieldFields.contains(key);
          final isMediumYield =
              highYieldMode && _mediumYieldFields.contains(key);
          final initiallyExpanded = highYieldMode && isHighYield
              ? true
              : isMediumYield
              ? false
              : config.initiallyExpanded;
          final borderColor = isHighYield ? _wardReadyGold : config.borderColor;
          final borderWidth = isHighYield ? 3.0 : 4.0;

          return _buildMarkdownExpansionTile(
            title: config.title,
            content: content,
            icon: config.icon,
            initiallyExpanded: initiallyExpanded,
            backgroundColor: config.backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            isWeak: isWeak,
          );
        })
        .whereType<Widget>()
        .toList(growable: false);
  }

  Widget _buildShowLowYieldButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _showLowYieldSections = true;
        });
      },
      child: const Text('+ Show low-yield sections'),
    );
  }

  Widget _buildWeakSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            ' Review this section',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownExpansionTile({
    required String title,
    required String content,
    required IconData icon,
    required bool initiallyExpanded,
    required Color backgroundColor,
    required Color borderColor,
    double borderWidth = 4.0,
    bool isWeak = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      child: ExpansionTile(
        backgroundColor: backgroundColor,
        collapsedBackgroundColor: backgroundColor,
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: const Color(0xFF1A237E)),
        title: isWeak ? _buildWeakSectionHeader(title) : Text(title),
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
}
