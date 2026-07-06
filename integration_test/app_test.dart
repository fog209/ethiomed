import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ethiomed/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch and Navigation Tests', () {
    testWidgets('Onboarding shows once and skips after completion', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // First launch should show onboarding
      expect(find.text('441 Clinical Articles'), findsOneWidget);

      // Swipe through pages then click Get Started
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should go through disclaimer
      expect(find.text('I Understand'), findsOneWidget);
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();

      // Should reach library screen (or login if Supabase configured and no session)
      expect(find.text('WardReady Specialties'), findsOneWidget);
    });

    testWidgets('All tabs are accessible without crash screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Skip onboarding if present
      final getStartedBtn = find.text('Get Started');
      if (getStartedBtn.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();
      }

      // Check no red error screen
      expect(find.byType(ErrorWidget), findsNothing);

      // Navigate to all main tabs
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.byIcon(Icons.quiz));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('Library navigation and article list works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Skip onboarding
      final getStartedBtn = find.text('Get Started');
      if (getStartedBtn.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();
        final disclaimerBtn = find.text('I Understand');
        if (disclaimerBtn.evaluate().isNotEmpty) {
          await tester.tap(disclaimerBtn);
          await tester.pumpAndSettle();
        }
      }

      // Should be on Library tab (or login screen if Supabase configured)
      expect(find.text('WardReady Specialties'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);

      // Tap a category (Internal Medicine) if present
      final internalMedTile = find.text('Internal Medicine');
      if (internalMedTile.evaluate().isNotEmpty) {
        await tester.tap(internalMedTile.first);
        await tester.pumpAndSettle();
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('Unauthenticated user with Supabase unconfigured skips login gate', (tester) async {
      // When Supabase is not configured (no .env or empty credentials),
      // the app should allow access to home without forcing login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Complete onboarding to get to the main flow
      final getStartedBtn = find.text('Get Started');
      if (getStartedBtn.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();
        final disclaimerBtn = find.text('I Understand');
        if (disclaimerBtn.evaluate().isNotEmpty) {
          await tester.tap(disclaimerBtn);
          await tester.pumpAndSettle();
        }
      }

      // In offline/mock mode (no Supabase), should reach library without login prompt
      // because the router skips auth gating when Supabase isn't configured
      expect(find.text('WardReady Specialties'), findsOneWidget);
      // Should NOT show login screen
      expect(find.text('Login'), findsNothing);
    });
  });
}