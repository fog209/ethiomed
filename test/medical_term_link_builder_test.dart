import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:ethiomed/features/articles/presentation/article_markdown_helpers.dart';

void main() {
  group('MedicalTermLinkBuilder', () {
      testWidgets('long-press on an abbreviation shows its expansion tooltip',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final builder = MedicalTermLinkBuilder(
                  onTapLink: (_, __, ___) => tapped = true,
                );
                final element = md.Element('a', [md.Text('vte')]);
                element.attributes['href'] = 'search:vte';
                final widget = builder.visitElementAfterWithContext(
                  context,
                  element,
                  null,
                  null,
                );
                return widget ?? const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // A Tooltip carrying the expansion is present.
      expect(find.byType(Tooltip), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'venous thromboembolism');

      // Tap still navigates (no regression to existing cross-link behavior).
      await tester.tap(find.text('vte'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('a term without a known expansion renders without a tooltip',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final builder = MedicalTermLinkBuilder(
                  onTapLink: (_, __, ___) {},
                );
                final element = md.Element('a', [md.Text('acute')]);
                element.attributes['href'] = 'search:acute';
                final widget = builder.visitElementAfterWithContext(
                  context,
                  element,
                  null,
                  null,
                );
                return widget ?? const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
      expect(find.text('acute'), findsOneWidget);
    });
  });
}
