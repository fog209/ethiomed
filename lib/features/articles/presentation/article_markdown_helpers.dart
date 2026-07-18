// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Builds a GitHub-flavored markdown [Table] from a parsed `<table>` element,
/// wrapping it in a horizontal [SingleChildScrollView] so wide tables scroll
/// instead of overflowing (only the table, not the rest of the body).
///
/// Zebra striping alternates row backgrounds between [zebraA] (even rows,
/// including the header) and [zebraB] (odd rows), using theme-consistent
/// surface colors rather than hardcoded hex.
class ScrollableTableBuilder extends MarkdownElementBuilder {
  ScrollableTableBuilder({
    required this.zebraA,
    required this.zebraB,
  });

  final Color zebraA;
  final Color zebraB;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final table = _buildTableWidget(element);
    if (table == null) return null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: table,
    );
  }

  Table? _buildTableWidget(md.Element tableElement) {
    final rows = <TableRow>[];
    var isHeader = true;

    for (final body in tableElement.children ?? <md.Node>[]) {
      if (body is! md.Element) continue;
      if (body.tag == 'thead') {
        final headerRows = _extractRows(body, isHeaderRow: true);
        rows.addAll(headerRows);
        isHeader = false;
      } else if (body.tag == 'tbody') {
        final bodyRows = _extractRows(body, isHeaderRow: false);
        rows.addAll(bodyRows);
      } else if (body.tag == 'tr') {
        // A table with no thead/tbody wrappers.
        final row = _buildRow(body, isHeaderRow: isHeader, index: rows.length);
        if (row != null) rows.add(row);
        isHeader = false;
      }
    }

    if (rows.isEmpty) return null;

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(
        color: Colors.black12,
        width: 1,
      ),
      children: rows,
    );
  }

  List<TableRow> _extractRows(md.Element group, {required bool isHeaderRow}) {
    final result = <TableRow>[];
    for (final node in group.children ?? <md.Node>[]) {
      if (node is! md.Element || node.tag != 'tr') continue;
      final row = _buildRow(node, isHeaderRow: isHeaderRow, index: result.length);
      if (row != null) result.add(row);
    }
    return result;
  }

  TableRow? _buildRow(md.Element tr, {required bool isHeaderRow, required int index}) {
    final cells = <Widget>[];
    for (final node in tr.children ?? <md.Node>[]) {
      if (node is! md.Element) continue;
      if (node.tag != 'th' && node.tag != 'td') continue;
      final text = node.textContent.trim();
      final cellStyle = isHeaderRow
          ? const TextStyle(fontWeight: FontWeight.w700)
          : const TextStyle();
      cells.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: index.isEven ? zebraA : zebraB,
          child: Text(text, style: cellStyle),
        ),
      );
    }
    if (cells.isEmpty) return null;
    return TableRow(children: cells);
  }
}

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
