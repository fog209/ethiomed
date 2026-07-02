import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';
import '../../../features/articles/article_providers.dart';
import '../../../features/progress/category_progress_provider.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../../features/quiz/weakness_service.dart';

final _medicalTerms = <String>{
  'acute',
  'chronic',
  'heart failure',
  'myocardial infarction',
  'coronary artery disease',
  'heart attack',
  'stroke',
  'cerebrovascular accident',
  'diabetes mellitus',
  'hypertension',
  'renal failure',
  'kidney failure',
  'pneumonia',
  'sepsis',
  'shock',
  'anemia',
  'thrombocytopenia',
  'leukocytosis',
  'leukopenia',
  'dyspnea',
  'dyspepsia',
  'bradycardia',
  'tachycardia',
  'hypotension',
  'orthopnea',
  'edema',
  'rales',
  'wheezes',
  'hemoptysis',
  'hematemesis',
  'melena',
  'arrhythmia',
  'atrial fibrillation',
  'ventricular fibrillation',
  'pulmonary embolism',
  'deep vein thrombosis',
  'peptic ulcer',
  'osteoarthritis',
  'rheumatoid arthritis',
  'copd',
  'asthma',
  'bronchitis',
  'gastroenteritis',
  'hepatitis',
  'nephrotic syndrome',
  'nephritis',
  'hyperkalemia',
  'hypokalemia',
  'hyponatremia',
  'hypernatremia',
  'acidosis',
  'alkalosis',
  'cardiac arrest',
  'angina',
  'atherosclerosis',
  'valvular disease',
  'pulmonary hypertension',
  'venous thromboembolism',
  'vte',
  'acute respiratory distress syndrome',
  'ards',
  'chronic obstructive pulmonary disease',
  'chronic kidney disease',
  'ckd',
  'end-stage renal disease',
  'esrd',
};

class _ClinicalSectionConfig {
  const _ClinicalSectionConfig({
    required this.title,
    required this.icon,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final bool initiallyExpanded;
}

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final ArticleLocal? article;

  const ArticleDetailScreen({super.key, this.article});

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _showLowYieldSections = false;

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    if (article == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This article is no longer available.'),
            ),
          );
        }
      });
      return;
    }
    final db = ref.read(databaseProvider);
    final category = article.category;
    Future.microtask(() async {
      if (!mounted) {
        return;
      }
      await ref.read(streakNotifierProvider.notifier).recordArticleRead();
      if (!mounted) {
        return;
      }
      await _recordViewHistory(db);
      if (!mounted) {
        return;
      }
      ref.invalidate(categoryProgressProvider(category ?? ''));
      if (!mounted) {
        return;
      }
    });
  }

  Future<void> _recordViewHistory(AppDatabase db) async {
    final article = widget.article;
    if (article == null) return;
    try {
      await db
          .customSelect(
            '''
            INSERT INTO view_history (
              article_id,
              article_title,
              category,
              viewed_at
            ) VALUES (?, ?, ?, ?)
            ''',
            variables: [
              Variable(article.id),
              Variable(article.title),
              Variable(article.category ?? ''),
              Variable(DateTime.now()),
            ],
          )
          .get();
    } catch (error) {
      debugPrint('Unable to record article view history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    if (article == null) {
      return const SizedBox.shrink();
    }

    final ref = this.ref;
    final db = ref.watch(databaseProvider);
    final weakFieldsAsync = ref.watch(weakFieldsProvider(article.id));
    final weakFields = weakFieldsAsync.value ?? const <String>{};
    final highYieldMode = ref.watch(highYieldModeProvider);
    final sections = _decodeSections(article.content);
    final imageUrl = article.imageUrl;
    final videoUrl = article.videoUrl;

    final theme = Theme.of(context);
    if (sections.isEmpty) {
      return _buildEmptyArticleFallback(context);
    }

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(article.title),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            tooltip: 'High-Yield Mode',
            color: highYieldMode ? theme.colorScheme.secondary : null,
            onPressed: () =>
                ref.read(highYieldModeProvider.notifier).state = !highYieldMode,
            icon: Icon(highYieldMode ? Icons.bolt : Icons.bolt_outlined),
          ),
          StreamBuilder<List<Bookmark>>(
            stream: (db.select(
              db.bookmarks,
            )..where((t) => t.articleId.equals(article.id))).watch(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong. Pull down to retry.'),
                );
              }

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
      body: _buildBody(weakFields, highYieldMode, sections, imageUrl, videoUrl),
    );
  }

  Widget _buildBody(
    Set<String> weakFields,
    bool highYieldMode,
    Map<String, Object?> sections,
    String? imageUrl,
    String? videoUrl,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
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
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.article?.category?.toUpperCase() ?? 'GENERAL',
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          ..._buildClinicalSections(sections, weakFields, highYieldMode),

          const SizedBox(height: 20),

          if (videoUrl != null && videoUrl.isNotEmpty)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
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
    );
  }

  Widget _buildImagePlaceholder() {
    final shimmerTheme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: shimmerTheme.colorScheme.surfaceContainerHighest,
      highlightColor: shimmerTheme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 20),
          Container(
            height: 24,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            width: 180,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Container(
            height: 14,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            color: shimmerTheme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ],
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
    ),
    'epidemiology': _ClinicalSectionConfig(
      title: '🌍 Epidemiology',
      icon: Icons.public,
    ),
    'etiology': _ClinicalSectionConfig(
      title: '🧬 Etiology',
      icon: Icons.biotech,
    ),
    'pathophysiology': _ClinicalSectionConfig(
      title: '🔬 Pathophysiology',
      icon: Icons.psychology_outlined,
    ),
    'clinicalFeatures': _ClinicalSectionConfig(
      title: '🩺 Clinical Features',
      icon: Icons.list_alt,
    ),
    'redFlags': _ClinicalSectionConfig(
      title: '🚩 Red Flags',
      icon: Icons.warning_rounded,
      initiallyExpanded: true,
    ),
    'approach': _ClinicalSectionConfig(
      title: '🧭 Approach',
      icon: Icons.format_list_numbered,
      initiallyExpanded: true,
    ),
    'diagnosis': _ClinicalSectionConfig(
      title: '🔎 Diagnosis',
      icon: Icons.search,
    ),
    'treatment': _ClinicalSectionConfig(
      title: '💊 Treatment',
      icon: Icons.medication,
    ),
    'contraindications': _ClinicalSectionConfig(
      title: '🛑 Contraindications',
      icon: Icons.report_problem_outlined,
    ),
    'dontMiss': _ClinicalSectionConfig(
      title: "🚨 Don't Miss",
      icon: Icons.priority_high,
    ),
    'complications': _ClinicalSectionConfig(
      title: '⚠️ Complications',
      icon: Icons.warning_amber_rounded,
    ),
    'clinicalPearls': _ClinicalSectionConfig(
      title: '💡 Clinical Pearls',
      icon: Icons.lightbulb_outline,
    ),
    'ethiopianContext': _ClinicalSectionConfig(
      title: '🇪🇹 Ethiopian Clinical Pearl',
      icon: Icons.local_hospital_outlined,
      initiallyExpanded: true,
    ),
    'mnemonics': _ClinicalSectionConfig(
      title: '🧠 Mnemonics',
      icon: Icons.auto_awesome_mosaic_outlined,
    ),
    'examTraps': _ClinicalSectionConfig(
      title: '📋 Exam Traps',
      icon: Icons.help_outline,
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
final theme = Theme.of(context);
           final borderColor = isHighYield ? theme.colorScheme.secondary : theme.colorScheme.outline;
          final borderWidth = isHighYield ? 3.0 : 4.0;
          final backgroundColor = theme.colorScheme.surfaceContainerHighest;

          return _buildMarkdownExpansionTile(
            title: config.title,
            content: content,
            icon: config.icon,
            initiallyExpanded: initiallyExpanded,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            isWeak: isWeak,
          );
        })
        .whereType<Widget>()
        .toList(growable: false);
  }

Widget _buildShowLowYieldButton() {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        setState(() {
          _showLowYieldSections = true;
        });
      },
      child: Text(
        '+ Show low-yield sections',
        style: TextStyle(color: theme.colorScheme.secondary),
      ),
    );
  }

  Widget _buildEmptyArticleFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              color: theme.colorScheme.secondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'This article is still being prepared.',
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back after the next sync.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakSectionHeader(String title) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.secondary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            ' Review this section',
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final linkedContent = _addMedicalTermLinks(content);

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
        leading: Icon(icon, color: theme.colorScheme.onSurface),
        title: isWeak ? _buildWeakSectionHeader(title) : Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: linkedContent,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: TextStyle(color: theme.colorScheme.onSurface),
                a: TextStyle(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              onTapLink: _handleLinkTap,
            ),
          ),
        ],
      ),
    );
  }

  String _addMedicalTermLinks(String content) {
    var result = content;
    for (final term in _medicalTerms) {
      final escapedTerm = RegExp.escape(term);
      final pattern = RegExp(
        r'\b' + escapedTerm + r'\b',
        caseSensitive: false,
      );
      result = result.replaceAll(pattern, '[$term](search:$term)');
    }
    return result;
  }

  void _handleLinkTap(String text, String? href, String title) {
    if (href != null && href.startsWith('search:')) {
      final query = href.substring(7);
      context.push('/search', extra: query);
    }
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
