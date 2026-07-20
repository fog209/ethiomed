// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Applies the High-Yield filter to a single section [body] string.
///
/// Scoped filtering: only *tagged* bullet lines within a section are touched.
/// A section that contains zero tier-tagged bullets is returned unchanged
/// (so prose-only sections like `definition`/`pathophysiology` are never
/// trimmed). Among tagged bullets, `🔴 Core` and `⭐ Sharp` are kept; `🟡
/// Strong` is dropped.
String applyHighYieldFilter(String body) {
  final lines = body.split('\n');

  // Detect whether ANY tier tag exists anywhere in this body.
  var hasAnyTag = false;
  for (final line in lines) {
    if (_isTaggedBullet(line)) {
      hasAnyTag = true;
      break;
    }
  }
  if (!hasAnyTag) return body;

  final kept = <String>[];
  for (final line in lines) {
    if (_isTaggedBullet(line) && line.contains('🟡')) {
      // Drop "Strong" tier bullets only.
      continue;
    }
    kept.add(line);
  }

  return kept.join('\n');
}

const List<String> _tierTags = <String>[
  '🔴 Core:',
  '🟡 Strong:',
  '⭐ Sharp:',
];

bool _isTaggedBullet(String line) {
  final trimmed = line.trimLeft();
  if (!trimmed.startsWith('- ') && !trimmed.startsWith('* ')) return false;
  return _tierTags.any((tag) => line.contains(tag));
}

/// Trusted abbreviation → full expansion map.
///
/// Every expansion here is itself an entry already present in the
/// `_medicalTerms` cross-link set in [ArticleDetailScreen], so no new clinical
/// content is introduced — these are 1:1 pairs the codebase already trusts.
/// Long-press tooltips expose the expansion only for these known terms.
const Map<String, String> _medicalAbbreviationExpansions = <String, String>{
  'vte': 'venous thromboembolism',
  'ards': 'acute respiratory distress syndrome',
  'ckd': 'chronic kidney disease',
  'esrd': 'end-stage renal disease',
  'copd': 'chronic obstructive pulmonary disease',
};

/// Renders inline medical-term cross-links produced by
/// `_addMedicalTermLinks` (e.g. `[vte](search:vte)`).
///
/// Tap navigates via [onTapLink] (unchanged behavior). Long-press shows a
/// [Tooltip] with the term's full expansion when one is known, without
/// interfering with the tap gesture.
class MedicalTermLinkBuilder extends MarkdownElementBuilder {
  MedicalTermLinkBuilder({required this.onTapLink});

  final void Function(String, String?, String) onTapLink;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final href = element.attributes['href'];
    final text = element.textContent;
    if (href == null || text.isEmpty) return null;

    final theme = Theme.of(context);
    final expansion = _medicalAbbreviationExpansions[text.toLowerCase()];

    final linkText = Text(
      text,
      style: (preferredStyle ?? parentStyle ?? const TextStyle()).copyWith(
        color: theme.colorScheme.secondary,
        decoration: TextDecoration.underline,
      ),
    );

    final child = GestureDetector(
      onTap: () => onTapLink(text, href, ''),
      child: linkText,
    );

    if (expansion == null) return child;

    return Tooltip(
      message: expansion,
      preferBelow: true,
      child: child,
    );
  }
}

