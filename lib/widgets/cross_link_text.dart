import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/article_providers.dart';

class CrossLinkText extends ConsumerWidget {
  const CrossLinkText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = ref.watch(articleTitlesProvider).valueOrNull ?? <String>{};
    final availableTitles = {
      for (final title in titles) title.trim().toLowerCase(): title,
    };
    final theme = Theme.of(context);
    final effectiveStyle =
        style ?? theme.textTheme.bodyLarge?.copyWith(height: 1.45);

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: _spansForText(
          context: context,
          theme: theme,
          availableTitles: availableTitles,
        ),
      ),
    );
  }

  List<InlineSpan> _spansForText({
    required BuildContext context,
    required ThemeData theme,
    required Map<String, String> availableTitles,
  }) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\[\[([^\]]+)\]\]');
    var currentIndex = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      final term = match.group(1)?.trim() ?? '';
      final matchedTitle = availableTitles[term.toLowerCase()];
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _InlineArticleLink(
            label: term,
            matchedTitle: matchedTitle,
            theme: theme,
            onTap: matchedTitle == null
                ? null
                : () {
                    context.push(
                      '/articles/${Uri.encodeComponent(matchedTitle)}',
                    );
                  },
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }
}

class _InlineArticleLink extends StatelessWidget {
  const _InlineArticleLink({
    required this.label,
    required this.matchedTitle,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final String? matchedTitle;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = matchedTitle != null;
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: isAvailable ? colorScheme.secondary : colorScheme.onSurfaceVariant,
      decoration: isAvailable ? TextDecoration.underline : TextDecoration.none,
      decorationColor: colorScheme.secondary,
      fontWeight: isAvailable ? FontWeight.w700 : FontWeight.w500,
      height: 1.45,
    );

    final child = Text(label, style: textStyle);
    if (!isAvailable) {
      return Tooltip(message: 'Article not yet available', child: child);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}
