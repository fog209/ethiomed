import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Variable;
// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/articles/presentation/article_markdown_helpers.dart';

import '../../../core/database/app_database.dart';
import '../../../features/articles/article_providers.dart';
import '../../../features/articles/data/content_update_service.dart';
import '../../../features/articles/models/article_model.dart';
import '../../../features/articles/presentation/article_notes_section.dart';
import '../../../features/content/data/content_flag_service.dart';
import '../../../features/content/presentation/content_flag_widget.dart';
import '../../../features/progress/category_progress_provider.dart';
import '../../../features/progress/streak_notifier.dart';
import '../../../features/quiz/weakness_service.dart';
import '../../../features/settings/reading_mode_provider.dart';

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

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final ArticleLocal? article;
  final String? articleId;
  final String? scrollToSection;

  const ArticleDetailScreen({super.key, this.article, this.articleId, this.scrollToSection});

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _showLowYieldSections = false;
  bool _filterHighYieldBody = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    if (article != null && widget.articleId == null) {
      final db = ref.read(databaseProvider);
      final category = article.category;
      final articleId = article.id;
      Future.microtask(() async {
        if (!mounted) {
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_viewed_article', articleId);
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
        _scrollToInitialSection();
      });
    } else if (widget.articleId != null) {
      Future.microtask(_scrollToInitialSection);
    }
  }

  void _scrollToInitialSection() {
    final scrollToSection = widget.scrollToSection;
    if (scrollToSection == null || scrollToSection.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionIndex = _clinicalSectionOrder.indexOf(scrollToSection);
      if (sectionIndex >= 0 && _scrollController.hasClients) {
        final estimatedOffset = sectionIndex * 80.0;
        _scrollController.animateTo(
          estimatedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _recordViewHistory(AppDatabase db, {ArticleLocal? article}) async {
    final targetArticle = article ?? widget.article;
    if (targetArticle == null) return;
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
              Variable(targetArticle.id),
              Variable(targetArticle.title),
              Variable(targetArticle.category ?? ''),
              Variable(DateTime.now()),
            ],
          )
          .get();
    } catch (error) {
      // AUDIT NOTE: This failure is intentionally silent.
      // Failing to record history should not interrupt the user's reading experience.
      debugPrint('View history background write failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    if (article != null) {
      return _buildContent(article);
    }

    final articleId = widget.articleId;
    if (articleId != null && articleId.isNotEmpty) {
      final articleAsync = ref.watch(articleByIdProvider(articleId));
      return articleAsync.when(
        data: (fetchedArticle) {
          if (fetchedArticle == null) {
            return _buildEmptyArticleFallback(context);
          }
          Future.microtask(() async {
            if (!mounted) return;
            await ref.read(streakNotifierProvider.notifier).recordArticleRead();
            if (!mounted) return;
            final db = ref.read(databaseProvider);
            _recordViewHistory(db, article: fetchedArticle);
            if (!mounted) return;
            ref.invalidate(categoryProgressProvider(fetchedArticle.category ?? ''));
          });
          return _buildContent(fetchedArticle);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(child: Text('Error loading article: $error')),
        ),
      );
    }

    return _buildEmptyArticleFallback(context);
  }

  Widget _buildContent(ArticleLocal article) {
    final ref = this.ref;
    final db = ref.watch(databaseProvider);
    final weakFieldsAsync = ref.watch(weakFieldsProvider(article.id));
    final weakFields = weakFieldsAsync.value ?? const <String>{};
    final highYieldMode = ref.watch(highYieldModeProvider);
    final articleContent = _decodeSections(article.content);
    final imageUrl = article.imageUrl;
    final videoUrl = article.videoUrl;

    final theme = Theme.of(context);
    if (articleContent.sections.isEmpty) {
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
          Tooltip(
            message: 'Hide Strong-tier bullets within sections',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('HY'),
                Switch(
                  value: _filterHighYieldBody,
                  activeColor: theme.colorScheme.secondary,
                  onChanged: (value) {
                    setState(() {
                      _filterHighYieldBody = value;
                    });
                  },
                ),
              ],
            ),
          ),
          ContentFlagWidget(contentType: ContentType.article, contentId: article.id),
          StreamBuilder<List<Bookmark>>(
            stream: (db.select(db.bookmarks)
                  ..where((t) => t.articleId.equals(article.id)))
                .watch(),
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
                    await (db.delete(db.bookmarks)
                          ..where((t) => t.articleId.equals(article.id)))
                        .go();
                  } else {
                    await db
                        .into(db.bookmarks)
                        .insert(BookmarksCompanion.insert(articleId: article.id));
                  }
                },
              );
            },
          ),
          _buildLearntButton(db, article.id),
        ],
      ),
      body: _buildBody(article, weakFields, highYieldMode, articleContent, imageUrl, videoUrl),
    );
  }

  Widget _buildBody(
    ArticleLocal article,
    Set<String> weakFields,
    bool highYieldMode,
    ArticleContent articleContent,
    String? imageUrl,
    String? videoUrl,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: _scrollController,
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
                  memCacheWidth: 1280,
                  memCacheHeight: 1280,
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
              article.category?.toUpperCase() ?? 'GENERAL',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
             ),
           ),

           Builder(builder: (innerContext) {
             final pastExamInfoAsync = ref.watch(pastExamArticleInfoProvider(article.id));
             final pastExamInfo = pastExamInfoAsync.valueOrNull;
if (pastExamInfo == null || !pastExamInfo.isHighYield) {
                return const SizedBox.shrink();
              }
              final sortedYears = [...pastExamInfo.years]
                ..sort((a, b) => b.compareTo(a));
              final yearsText = sortedYears.join(', ');
              return Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               margin: const EdgeInsets.only(bottom: 16),
               decoration: BoxDecoration(
                 color: theme.colorScheme.secondaryContainer,
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(
                     Icons.local_fire_department,
                     size: 16,
                     color: theme.colorScheme.onSecondaryContainer,
                   ),
                   const SizedBox(width: 6),
                   Text(
                     'Tested in ${pastExamInfo.examCount} Past Exams ($yearsText)',
                     style: TextStyle(
                       color: theme.colorScheme.onSecondaryContainer,
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                     ),
                   ),
                 ],
               ),
             );
           }),

           ..._buildClinicalSections(
            articleContent,
            weakFields,
            highYieldMode,
            category: article.category,
          ),

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

          ArticleNotesSection(articleId: article.id),
        ],
      ),
    );
  }

  Widget _buildLearntButton(AppDatabase db, String articleId) {
    return StreamBuilder<List<LearntData>>(
      stream: (db.select(db.learnt)
            ..where((t) => t.articleId.equals(articleId)))
          .watch(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final learntList = snapshot.data;
        final isLearnt = learntList != null && learntList.isNotEmpty;
        return IconButton(
          tooltip: 'Mark as learnt',
          color: isLearnt ? Theme.of(context).colorScheme.secondary : null,
          icon: Icon(
            isLearnt ? Icons.school : Icons.school_outlined,
          ),
          onPressed: () async {
            if (isLearnt) {
              await (db.delete(db.learnt)
                    ..where((t) => t.articleId.equals(articleId)))
                  .go();
            } else {
              await db
                  .into(db.learnt)
                  .insert(LearntCompanion.insert(articleId: articleId));
            }
          },
        );
      },
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

  /// Maps the Supabase `section_registry.icon_name` string (and the legacy
  /// `_ClinicalSectionConfig.icon`) to a Flutter [IconData]. Unknown names fall
  /// back to [Icons.article_outlined] (see [_resolveSectionMeta]). Extend this
  /// with one line whenever a genuinely new field gets a real icon — the part
  /// that actually matters (label/order) is already dynamic from the registry.
  static const Map<String, IconData> _iconByName = {
    'info_outline': Icons.info_outline,
    'public': Icons.public,
    'biotech': Icons.biotech,
    'psychology_outlined': Icons.psychology_outlined,
    'list_alt': Icons.list_alt,
    'warning_rounded': Icons.warning_rounded,
    'format_list_numbered': Icons.format_list_numbered,
    'search': Icons.search,
    'medication': Icons.medication,
    'report_problem_outlined': Icons.report_problem_outlined,
    'priority_high': Icons.priority_high,
    'warning_amber_rounded': Icons.warning_amber_rounded,
    'lightbulb_outline': Icons.lightbulb_outline,
    'local_hospital_outlined': Icons.local_hospital_outlined,
    'auto_awesome_mosaic_outlined': Icons.auto_awesome_mosaic_outlined,
    'help_outline': Icons.help_outline,
  };

  /// In-code fallback labels/icons for the 16 existing keys, used when the
  /// local `section_registry` cache is empty (offline / not yet synced). Mirrors
  /// the seed in `supabase/migrations/0002_section_registry.sql` so existing
  /// content renders identically without the registry present.
  static const Map<String, String> _fallbackLabels = {
    'definition': '📝 Definition',
    'epidemiology': '🌍 Epidemiology',
    'etiology': '🧬 Etiology',
    'pathophysiology': '🔬 Pathophysiology',
    'clinicalFeatures': '🩺 Clinical Features',
    'redFlags': '🚩 Red Flags',
    'approach': '🧭 Approach',
    'diagnosis': '🔎 Diagnosis',
    'treatment': '💊 Treatment',
    'contraindications': '🛑 Contraindications',
    'dontMiss': "🚨 Don't Miss",
    'complications': '⚠️ Complications',
    'clinicalPearls': '💡 Clinical Pearls',
    'ethiopianContext': '🇪🇹 Ethiopian Clinical Pearl',
    'mnemonics': '🧠 Mnemonics',
    'examTraps': '📋 Exam Traps',
  };

  static const Map<String, String> _fallbackIconNames = {
    'definition': 'info_outline',
    'epidemiology': 'public',
    'etiology': 'biotech',
    'pathophysiology': 'psychology_outlined',
    'clinicalFeatures': 'list_alt',
    'redFlags': 'warning_rounded',
    'approach': 'format_list_numbered',
    'diagnosis': 'search',
    'treatment': 'medication',
    'contraindications': 'report_problem_outlined',
    'dontMiss': 'priority_high',
    'complications': 'warning_amber_rounded',
    'clinicalPearls': 'lightbulb_outline',
    'ethiopianContext': 'local_hospital_outlined',
    'mnemonics': 'auto_awesome_mosaic_outlined',
    'examTraps': 'help_outline',
  };

  /// Humanizes a camelCase key into a title-case label (e.g. `theWardScenario`
  /// → "The Ward Scenario"). Used as the label fallback for a genuinely new
  /// section key that has no registry entry yet.
  static String _humanizeKey(String key) {
    final spaced = key.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (m) => ' ${m[0]}',
    );
    final trimmed = spaced.trim();
    if (trimmed.isEmpty) return key;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  /// Resolves display metadata for a section [key].
  ///
  /// Priority:
  /// 1. Local `section_registry` cache entry (from Supabase) that is enabled,
  ///    with a per-category label override (when [category] matches one in the
  ///    registry entry's `category_label_overrides`).
  /// 2. In-code fallback (known 16 keys) — keeps existing content identical
  ///    when the registry hasn't synced yet.
  /// 3. Unknown key: humanized label, default order, default icon. This is the
  ///    "dynamic for the future" guarantee — a new field renders reasonably
  ///    before anyone touches app code.
  ({String label, String? iconName, int order, bool initiallyExpanded})
      _resolveSectionMeta(String key, {String? category}) {
    final registry = ref.read(sectionRegistryProvider)[key];
    if (registry != null && registry.enabled) {
      final overrides = registry.parsedCategoryLabelOverrides;
      final overrideLabel =
          category != null && overrides != null ? overrides[category] : null;
      return (
        label: overrideLabel ?? registry.label,
        iconName: registry.iconName,
        order: registry.displayOrder,
        initiallyExpanded: _defaultExpandedFor(key),
      );
    }

    if (_fallbackLabels.containsKey(key)) {
      return (
        label: _fallbackLabels[key]!,
        iconName: _fallbackIconNames[key],
        order: _clinicalSectionOrder.indexOf(key),
        initiallyExpanded: _defaultExpandedFor(key),
      );
    }

    return (
      label: _humanizeKey(key),
      iconName: null,
      order: 999,
      initiallyExpanded: _defaultExpandedFor(key),
    );
  }

  /// Preserves the existing per-section "expanded by default" behavior: red
  /// flags, approach, and Ethiopian context start expanded.
  bool _defaultExpandedFor(String key) =>
      key == 'redFlags' || key == 'approach' || key == 'ethiopianContext';

  List<Widget> _buildClinicalSections(
    ArticleContent articleContent,
    Set<String> weakFields,
    bool highYieldMode, {
    String? category,
  }) {
    final theme = Theme.of(context);
    final readingMode = ref.watch(readingModeProvider);

    // Resolve metadata + sort: registry order first (including fallback order
    // for known keys), unknown keys (order 999) appended in array order.
    final resolved = articleContent.sections.map((section) {
      final meta = _resolveSectionMeta(section.key, category: category);
      return (section: section, meta: meta);
    }).toList();

    resolved.sort((a, b) {
      final orderDiff = a.meta.order.compareTo(b.meta.order);
      if (orderDiff != 0) return orderDiff;
      // Stable secondary sort by original array position.
      return articleContent.sections
          .indexOf(a.section)
          .compareTo(articleContent.sections.indexOf(b.section));
    });

    final widgets = <Widget>[];
    for (final item in resolved) {
      final key = item.section.key;
      final meta = item.meta;

      final isLowYield = _lowYieldFields.contains(key);
      if (highYieldMode && isLowYield && !_showLowYieldSections) {
        if (key == 'definition') {
          widgets.add(_buildShowLowYieldButton());
        }
        continue;
      }

      final rawBody = _filterHighYieldBody
          ? applyHighYieldFilter(item.section.body)
          : item.section.body;
      final content = _markdownContent(rawBody);
      if (content == null) {
        continue;
      }

      final isWeak = weakFields.contains(key) &&
          !_nonHighlightableWeakFields.contains(key);
      final isHighYield = highYieldMode && _highYieldFields.contains(key);
      final isMediumYield = highYieldMode && _mediumYieldFields.contains(key);
      final isEthiopianContext = key == 'ethiopianContext';
      final initiallyExpanded = highYieldMode && isHighYield
          ? true
          : isMediumYield
              ? false
              : meta.initiallyExpanded;
      final borderColor = isHighYield
          ? theme.colorScheme.secondary
          : theme.colorScheme.outline;
      final borderWidth = isHighYield ? 3.0 : 4.0;
      final backgroundColor = isEthiopianContext
          ? const Color(0xFFE8F5E9)
          : theme.colorScheme.surfaceContainerHighest;
      final icon = _iconByName[meta.iconName] ?? Icons.article_outlined;

      widgets.add(
        _buildMarkdownExpansionTile(
          title: meta.label,
          content: content,
          icon: icon,
          initiallyExpanded: initiallyExpanded,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          isWeak: isWeak,
          readingMode: readingMode,
        ),
      );
    }

    return widgets;
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
  required ReadingModeState readingMode,
  double borderWidth = 4.0,
  bool isWeak = false,
}) {
  final theme = Theme.of(context);
  final linkedContent = _addMedicalTermLinks(content);

  // Sepia toggle replaces the navy surface with a warm paper tone for
  // lower-contrast, eye-friendly long-form reading.
  final effectiveBackground = readingMode.sepia
      ? const Color(0xFFF4ECD8)
      : backgroundColor;

  final textColor = readingMode.sepia
      ? const Color(0xFF3B2F1E)
      : theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      child: ExpansionTile(
        backgroundColor: effectiveBackground,
        collapsedBackgroundColor: effectiveBackground,
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
                extensionSet: md.ExtensionSet.gitHubWeb,
                builders: <String, MarkdownElementBuilder>{
                  'table': ScrollableTableBuilder(
                    zebraA: theme.colorScheme.surfaceContainerHighest,
                    zebraB: theme.colorScheme.surface,
                  ),
                  'a': MedicalTermLinkBuilder(onTapLink: _handleLinkTap),
                },
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: TextStyle(
                    color: textColor,
                    fontSize: 16 * readingMode.fontScale,
                    height: readingMode.lineHeight,
                  ),
                  a: TextStyle(
                    color: theme.colorScheme.secondary,
                    decoration: TextDecoration.underline,
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
    result = result.replaceAllMapped(
      RegExp(r'\[\[([^\]]+)\]\]'),
      (match) => '[${match[1]}](internal:article:${match[1]!})',
    );
    return result;
  }

  void _handleLinkTap(String text, String? href, String title) {
    if (href != null) {
      if (href.startsWith('search:')) {
        final query = href.substring(7);
        context.push('/search', extra: query);
      } else if (href.startsWith('internal:article:')) {
        final term = href.substring(16);
        _handleInternalLink(term);
      } else if (href.startsWith('internal:')) {
        final term = href.substring(9);
        _handleInternalLink(term);
      }
    }
  }

  void _handleInternalLink(String term) async {
    final db = ref.read(databaseProvider);
    final articles = await db.customSelect(
      'SELECT id FROM articles WHERE title LIKE ?',
      variables: [Variable('%$term%')],
    ).get();
    if (!mounted) return;
    ArticleLocal? matchedArticle;
    for (final row in articles) {
      final id = row.read<String>('id');
      final article = await (db.select(db.articles)
            ..where((t) => t.id.equals(id)))
          .get();
      if (article.isNotEmpty &&
          article.first.title.toLowerCase() == term.toLowerCase()) {
        matchedArticle = article.first;
        break;
      }
    }
    if (!mounted) return;
    if (matchedArticle != null) {
      context.push('/article-detail/${Uri.encodeComponent(matchedArticle.id)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Content coming soon! This topic is currently being curated.',
          ),
        ),
      );
    }
  }

  ArticleContent _decodeSections(String? encodedContent) {
    if (encodedContent == null || encodedContent.trim().isEmpty) {
      return const ArticleContent();
    }

    try {
      final decoded = jsonDecode(encodedContent);
      if (decoded is Map<String, dynamic>) {
        return ArticleContent.fromJson(decoded);
      }
    } catch (error) {
      debugPrint('Unable to decode article content: $error');
    }

    return const ArticleContent();
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
