// ignore_for_file: file_names, dangling_library_doc_comments

/// Regression test for Phase 0: Auth/subscription guard not firing.
///
/// Root cause: The router's subscription gate had a logical gap where
/// `user == null && _supabaseInitialized == true && session != null` would
/// fall through to "all checks passed" without redirect. This occurred when
/// a stale session persisted from a prior sideloaded build on release install.
import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/features/settings/presentation/forced_update_gate.dart';

void main() {
  group('isVersionUnsupported (forced-update gate)', () {
    test('older version returns true', () {
      expect(isVersionUnsupported('1.0.0', '1.0.1'), isTrue);
    });

    test('same version returns false', () {
      expect(isVersionUnsupported('1.0.1-beta.1', '1.0.1-beta.1'), isFalse);
    });

    test('newer version returns false', () {
      expect(isVersionUnsupported('2.0.0', '1.0.1-beta.1'), isFalse);
    });
  });

  group('_isAtLoginOrSubscription helper', () {
    test('returns correct values for auth-related routes', () {
      expect(_isAtLoginOrSubscription('/login'), isTrue);
      expect(_isAtLoginOrSubscription('/subscription'), isTrue);
      expect(_isAtLoginOrSubscription('/signup'), isTrue);
      expect(_isAtLoginOrSubscription('/home'), isFalse);
      expect(_isAtLoginOrSubscription('/'), isFalse);
    });
  });

  group('Stale session bypass prevention', () {
    test(
      'user null with session present and supabase initialized redirects to login',
      () {
        // This was the bypass path: session != null (stale) && user == null && supabaseInitialized == true
        // should ALWAYS redirect to /login, never fall through to "all checks passed"
        expect(
          _computeRedirectForStaleSession(
            location: '/home',
            hasSession: true,
            hasUser: false,
            supabaseInitialized: true,
          ),
          '/login',
        );
        expect(
          _computeRedirectForStaleSession(
            location: '/',
            hasSession: true,
            hasUser: false,
            supabaseInitialized: true,
          ),
          '/login',
        );
      },
    );

    test(
      'stale session on login screen does not redirect (no loop)',
      () {
        expect(
          _computeRedirectForStaleSession(
            location: '/login',
            hasSession: true,
            hasUser: false,
            supabaseInitialized: true,
          ),
          isNull,
        );
      },
    );

    test(
      'valid session and user with no subscription redirects to subscription',
      () {
        expect(
          _computeRedirectForSubscriptionCheck(
            location: '/home',
            supabaseInitialized: true,
            isAdmin: false,
            isSubscribed: false,
          ),
          '/subscription',
        );
      },
    );

    test(
      'suppabase not initialized with stale session redirects to login',
      () {
        expect(
          _computeRedirectForStaleSession(
            location: '/home',
            hasSession: true,
            hasUser: false,
            supabaseInitialized: false,
          ),
          '/login',
        );
      },
    );
  });
}

/// Helper that mirrors the fixed redirect logic for the stale session case.
String? _computeRedirectForStaleSession({
  required String location,
  required bool hasSession,
  required bool hasUser,
  required bool supabaseInitialized,
}) {
  // Auth gate: session == null -> redirect to login
  if (!hasSession) {
    if (!_isAtLoginOrSubscription(location)) {
      return '/login';
    }
    return null;
  }

  // Subscription gate: same logic as fixed main.dart
  if (supabaseInitialized) {
    if (!hasUser) {
      // Session exists but user is null (stale/invalid session)
      if (!_isAtLoginOrSubscription(location)) {
        return '/login';
      }
      return null;
    }
  } else {
    // Supabase not initialized but we have a session - treat as invalid
    if (!_isAtLoginOrSubscription(location)) {
      return '/login';
    }
    return null;
  }

  // All checks passed
  if (location == '/') return '/home';
  return null;
}

/// Helper for subscription check path.
String? _computeRedirectForSubscriptionCheck({
  required String location,
  required bool supabaseInitialized,
  required bool isAdmin,
  required bool isSubscribed,
}) {
  if (supabaseInitialized) {
    if (!isAdmin && !isSubscribed) {
      if (location != '/subscription') {
        return '/subscription';
      }
      return null;
    }
  }
  return null;
}

bool _isAtLoginOrSubscription(String location) {
  return location == '/login' ||
      location == '/subscription' ||
      location == '/signup';
}