import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/article_providers.dart';
import '../models/article.dart';
import '../widgets/cross_link_text.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleState = ref.watch(articleByTitleProvider(title));

    return articleState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: Center(child: Text('Could not load article: $error')),
      ),
      data: (article) {
        if (article == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not yet available')),
            body: _MissingArticle(title: title),
          );
        }
        return _ArticleDetail(article: article);
      },
    );
  }
}

class _ArticleDetail extends StatelessWidget {
  const _ArticleDetail({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: <Widget>[
            Text(
              article.title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
Wrap(
               spacing: 8,
               runSpacing: 8,
               children: <Widget>[
                 _MetaChip(label: 'Category', value: article.parentCategory),
                 _MetaChip(label: 'Subcategory', value: article.subcategory),
               ],
             ),
            const SizedBox(height: 22),
            for (final section in article.textSections)
              _ArticleSectionView(section: section),
            Text(
              'Related Topics',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: article.relatedTopics
                  .map((topic) => _RelatedTopicChip(topic: topic))
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleSectionView extends StatelessWidget {
  const _ArticleSectionView({required this.section});

  final ArticleSection section;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.label,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          CrossLinkText(text: section.body),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      side: BorderSide(color: colorScheme.outline),
      backgroundColor: colorScheme.surfaceContainerHighest,
      label: Text('$label: $value'),
    );
  }
}

class _RelatedTopicChip extends ConsumerWidget {
  const _RelatedTopicChip({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CrossLinkText(text: '[[$topic]]');
  }
}

class _MissingArticle extends StatelessWidget {
  const _MissingArticle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.link_off, color: colorScheme.onSurfaceVariant, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This linked article is not yet available locally.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
