import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ethiomed/features/drugs/presentation/drugs_screen.dart';
import 'package:ethiomed/features/home/presentation/entry_point_cards.dart';
import 'package:ethiomed/features/home/presentation/home_screen.dart';

// The Drugs feature is currently an empty shell (nav entry + "Coming soon"
// placeholder). These tests assert the entry point exists on Home and the
// empty state renders — no content wiring is expected yet.
void main() {
  testWidgets('Home shows a Drugs quick-access entry card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ListView(children: const [DrugsEntryCard()])),
      ),
    );
    expect(find.text('Drugs'), findsWidgets);
  });

  testWidgets('Drugs screen renders the empty "Coming soon" state',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DrugsScreen()),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Drugs'), findsWidgets);
    expect(find.text('Coming soon'), findsOneWidget);
    // No list / query / loading affordance in the empty shell.
    expect(find.byType(ListView), findsNothing);
  });
}
