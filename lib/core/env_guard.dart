/// Startup validation for environment configuration.
///
/// The actual secret values live in `lib/app/env.dart`, which is (correctly)
/// gitignored. This file contains only the *validation logic* — no secrets —
/// so it survives a fresh clone and lets a misconfigured build fail loudly
/// instead of silently degrading to offline mode with placeholder values.
library;

/// Placeholder/empty values that indicate an unconfigured or copy-pasted
/// default environment. Matching any of these fails validation.
const List<String> _placeholderValues = <String>[
  '',
  'your_key_here',
  'your_url_here',
  'replace_me',
  'changeme',
  'todo',
  'fixme',
  'null',
  'undefined',
];

/// Throws a [StateError] when any required environment field is missing or
/// still carries an obvious placeholder value.
///
/// Only field *names* are included in the error message — never the values
/// themselves, so no secret can leak into logs or crash reports.
///
/// [values] maps a logical field name (e.g. `'supabaseUrl'`) to its loaded
/// value. An empty value is treated as unconfigured.
void validateEnvConfig(Map<String, String> values) {
  final missing = <String>[];
  final placeholder = <String>[];

  for (final entry in values.entries) {
    final name = entry.key;
    final value = entry.value;
    if (value.isEmpty) {
      missing.add(name);
      continue;
    }
    final normalized = value.trim().toLowerCase();
    if (_placeholderValues.contains(normalized)) {
      placeholder.add(name);
    }
  }

  if (missing.isEmpty && placeholder.isEmpty) return;

  final parts = <String>[];
  if (missing.isNotEmpty) {
    parts.add('missing: ${missing.join(', ')}');
  }
  if (placeholder.isNotEmpty) {
    parts.add('still set to a placeholder: ${placeholder.join(', ')}');
  }
  throw StateError(
    'Environment configuration invalid (${parts.join('; ')}). '
    'Provide real values via env.dart / .env / --dart-define.',
  );
}
