class AppConfig {
  const AppConfig._();

  static const String _supabaseUrlDartDefineKey = 'ETHIOMED_SUPABASE_URL';
  static const String _supabaseAnonKeyDartDefineKey =
      'ETHIOMED_SUPABASE_ANON_KEY';

  static String get supabaseUrl {
    final value = const String.fromEnvironment(_supabaseUrlDartDefineKey);
    if (value.trim().isEmpty) {
      throw StateError(
        'Missing required Supabase URL: --dart-define=$_supabaseUrlDartDefineKey',
      );
    }

    return value.trim();
  }

  static String get supabaseAnonKey {
    final value = const String.fromEnvironment(_supabaseAnonKeyDartDefineKey);
    if (value.trim().isEmpty) {
      throw StateError(
        'Missing required Supabase anon key: --dart-define=$_supabaseAnonKeyDartDefineKey',
      );
    }

    return value.trim();
  }
}
