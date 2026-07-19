import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/core/env_guard.dart';

void main() {
  group('validateEnvConfig', () {
    test('throws when a required field is empty', () {
      expect(
        () => validateEnvConfig(<String, String>{
          'supabaseUrl': '',
          'supabaseAnonKey': 'real-key',
        }),
        throwsStateError,
      );
    });

    test('throws when a required field holds a placeholder', () {
      expect(
        () => validateEnvConfig(<String, String>{
          'supabaseUrl': 'YOUR_URL_HERE',
          'supabaseAnonKey': 'real-key',
        }),
        throwsStateError,
      );
    });

    test('error message names only the field, never the value', () {
      StateError? error;
      try {
        validateEnvConfig(<String, String>{
          'supabaseUrl': 'YOUR_KEY_HERE',
          'supabaseAnonKey': 'real-secret-value-123',
        });
      } on StateError catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect(error?.message, contains('supabaseUrl'));
      expect(error!.message, isNot(contains('real-secret-value-123')));
    });

    test('passes when all fields are non-empty and not placeholders', () {
      expect(
        () => validateEnvConfig(<String, String>{
          'supabaseUrl': 'https://example.supabase.co',
          'supabaseAnonKey': 'real-key',
        }),
        returnsNormally,
      );
    });

    test('passes for whitespace-padded real values', () {
      expect(
        () => validateEnvConfig(<String, String>{
          'supabaseUrl': '  https://example.supabase.co  ',
          'supabaseAnonKey': '  real-key  ',
        }),
        returnsNormally,
      );
    });
  });
}
