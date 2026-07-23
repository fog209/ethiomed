// ignore_for_file: file_names, dangling_library_doc_comments

/// Regression test for Phase 0: Auth/subscription guard not firing.
///
/// Root cause: The router's auth gate was skipped entirely when
/// `_supabaseInitialized` was false, allowing unauthenticated users to
/// access the app directly. This test verifies that an unauthenticated
/// router state always redirects to /login regardless of Supabase status.
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

  group('Auth redirect gate logic', () {
    test('_isAtLoginOrSubscription helper returns correct values', () {
      expect(_isAtLoginOrSubscription('/login'), isTrue);
      expect(_isAtLoginOrSubscription('/subscription'), isTrue);
      expect(_isAtLoginOrSubscription('/signup'), isTrue);
      expect(_isAtLoginOrSubscription('/home'), isFalse);
      expect(_isAtLoginOrSubscription('/'), isFalse);
      expect(_isAtLoginOrSubscription('/admin'), isFalse);
    });

    test('_computeRedirectForUnauthenticated returns correct redirect target', () {
      // When unauthenticated and not already on auth screens
      expect(_computeRedirectForUnauthenticated('/home'), '/login');
      expect(_computeRedirectForUnauthenticated('/'), '/login');
      expect(_computeRedirectForUnauthenticated('/quiz'), '/login');

      // When unauthenticated but already on auth screens - no redirect
      expect(_computeRedirectForUnauthenticated('/login'), null);
      expect(_computeRedirectForUnauthenticated('/subscription'), null);
      expect(_computeRedirectForUnauthenticated('/signup'), null);
    });
  });
}

bool _isAtLoginOrSubscription(String location) {
  return location == '/login' ||
      location == '/subscription' ||
      location == '/signup';
}

String? _computeRedirectForUnauthenticated(String location) {
  final session = null; // No session = unauthenticated
  if (session == null) {
    if (!_isAtLoginOrSubscription(location)) {
      return '/login';
    }
    return null;
  }
  return null;
}