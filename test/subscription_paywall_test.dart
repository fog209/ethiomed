import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ethiomed/features/subscription/data/subscription_repository.dart';
import 'package:ethiomed/features/subscription/presentation/paywall_screen.dart';

void main() {
  group('isSubscriptionActive (paywall read-path logic)', () {
    final now = DateTime.utc(2026, 7, 19, 12, 0, 0);

    test('non-active status denies access even if far-future expiry', () {
      expect(
        isSubscriptionActive(
          status: 'expired',
          expiryDate: now.add(const Duration(days: 30)),
          now: now,
        ),
        isFalse,
      );
    });

    test('missing status (null) denies access', () {
      expect(
        isSubscriptionActive(status: null, expiryDate: null, now: now),
        isFalse,
      );
    });

    test('active status with null expiry grants access', () {
      expect(
        isSubscriptionActive(status: 'active', expiryDate: null, now: now),
        isTrue,
      );
    });

    test('active status with future expiry grants access', () {
      expect(
        isSubscriptionActive(
          status: 'active',
          expiryDate: now.add(const Duration(hours: 1)),
          now: now,
        ),
        isTrue,
      );
    });

    test('active status with past expiry denies access (expired sub)', () {
      expect(
        isSubscriptionActive(
          status: 'active',
          expiryDate: now.subtract(const Duration(hours: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    test('boundary: expiry exactly at now is treated as expired', () {
      // The instant a subscription lapses, the paywall must show. `isAfter`
      // is exclusive, so an equal timestamp denies access.
      expect(
        isSubscriptionActive(status: 'active', expiryDate: now, now: now),
        isFalse,
      );
    });

    test('boundary: one microsecond of remaining life still grants access', () {
      expect(
        isSubscriptionActive(
          status: 'active',
          expiryDate: now.add(const Duration(microseconds: 1)),
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('PaywallScreen (read-path rendering only)', () {
    testWidgets('renders premium title and the paid-check button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PaywallScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WardReady Premium'), findsOneWidget);
      expect(find.text('I HAVE PAID - CHECK STATUS'), findsOneWidget);
      // The copy-number affordance is present (read-only UI).
      expect(find.text(PaywallScreen.telebirrNumber), findsOneWidget);
    });

    testWidgets('paywall check-status button triggers a refresh (no activation)', (
      tester,
    ) async {
      // We only assert the button exists and is tappable; tapping calls
      // ref.refresh(isSubscribedProvider) — a read path, not activateUser().
      // No real activation flow is exercised.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PaywallScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final checkButton = find.text('I HAVE PAID - CHECK STATUS');
      expect(checkButton, findsOneWidget);
      // Tapping must not throw (it refreshes the read-only provider).
      await tester.ensureVisible(checkButton);
      await tester.pumpAndSettle();
      await tester.tap(checkButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    });
  });
}
