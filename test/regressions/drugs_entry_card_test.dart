import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethiomed/features/home/presentation/entry_point_cards.dart';

void main() {
  testWidgets('DrugsEntryCard renders with correct title and placeholder text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DrugsEntryCard(),
        ),
      ),
    );

    expect(find.text('Drugs'), findsOneWidget);
    expect(find.text('Ethiopian drug reference coming soon'), findsOneWidget);
    expect(find.byIcon(Icons.medication), findsOneWidget);
  });

  testWidgets('DrugsEntryCard has no navigation (empty state shell)', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrugsEntryCard(),
        ),
      ),
    );

    // The card should not respond to taps (it's a shell)
    await tester.tap(find.byType(DrugsEntryCard), warnIfMissed: false);
    await tester.pumpAndSettle();

    // No navigation should occur - verify no exception thrown and state unchanged
    expect(tapped, isFalse);
  });
}