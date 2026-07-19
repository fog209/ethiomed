import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../data/spotlight_search_provider.dart';

class SpotlightSearchScreen extends ConsumerStatefulWidget {
  const SpotlightSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SpotlightSearchScreen> createState() =>
      _SpotlightSearchScreenState();
}

class _SpotlightSearchScreenState extends ConsumerState<SpotlightSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery;
    if (initial != null && initial.isNotEmpty) {
      _controller.text = initial;
      Future.microtask(
        () => ref.read(spotlightControllerProvider.notifier).updateQuery(initial),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spotlightControllerProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: onSurface, fontSize: 18),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: 'Search articles, flashcards, questions...',
            hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            border: InputBorder.none,
          ),
          onChanged: (value) => ref
              .read(spotlightControllerProvider.notifier)
              .updateQuery(value),
        ),
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(SpotlightState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError) {
      return Center(child: Text(state.message ?? 'Search failed.'));
    }
    if (state.query.trim().isEmpty) {
      return Center(
        child: Text(
          'Search across all WardReady content.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    if (state.results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 12),
            Text('No results found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final result = state.results[index];
        return _ResultTile(result: result);
      },
    );
  }
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile({required this.result});

  final SpotlightResult result;

  IconData get _icon {
    switch (result.kind) {
      case SpotlightKind.article:
        return Icons.article_outlined;
      case SpotlightKind.flashcard:
        return Icons.style_outlined;
      case SpotlightKind.question:
        return Icons.quiz_outlined;
    }
  }

  String get _kindLabel {
    switch (result.kind) {
      case SpotlightKind.article:
        return 'Article';
      case SpotlightKind.flashcard:
        return 'Flashcard';
      case SpotlightKind.question:
        return 'Question';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(_icon, color: theme.colorScheme.primary),
      title: Text(result.title),
      subtitle: Text(
        result.subtitle != null && result.subtitle!.isNotEmpty
            ? '$_kindLabel · ${result.subtitle}'
            : _kindLabel,
      ),
      onTap: () => _onTap(context, ref),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    switch (result.kind) {
      case SpotlightKind.article:
        context.push(
          '/article-detail',
          extra: ArticleLocal(
            id: result.id,
            title: result.title,
            category: result.subtitle,
            content: null,
            imageUrl: null,
            videoUrl: null,
            subcategory: null,
            isHighYield: false,
            parentCategory: null,
            categoryPath: null,
          ),
        );
      case SpotlightKind.flashcard:
        context.go('/flashcards');
      case SpotlightKind.question:
        context.go('/quiz');
    }
  }
}
