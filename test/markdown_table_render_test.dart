import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

// Smoke test for the flutter_markdown_plus migration: a GitHub-flavored table
// must render without throwing and produce a Table widget. The full visual
// check (borders, zebra styling, horizontal scroll on wide tables) remains on
// the on-device backlog alongside the MaterialIcons check.
void main() {
  testWidgets('markdown table renders via flutter_markdown_plus', (tester) async {
    const tableMd = '''
| Header A | Header B |
| --- | --- |
| Cell 1 | Cell 2 |
''';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownBody(
            data: tableMd,
            extensionSet: md.ExtensionSet.gitHubWeb,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Table), findsOneWidget);
    expect(find.text('Header A'), findsOneWidget);
    expect(find.text('Cell 1'), findsOneWidget);
  });
}
