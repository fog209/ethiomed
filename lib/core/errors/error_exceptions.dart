class DiskFullException implements Exception {
  const DiskFullException([this.message = 'Storage full.']);

  final String message;

  @override
  String toString() => 'DiskFullException: $message';
}

class SearchUnavailableException implements Exception {
  const SearchUnavailableException([
    this.message = 'Search temporarily unavailable.',
  ]);

  final String message;

  @override
  String toString() => 'SearchUnavailableException: $message';
}

class SupabaseSessionExpiredException implements Exception {
  const SupabaseSessionExpiredException([
    this.message = 'Your session expired. Please sign in again.',
  ]);

  final String message;

  @override
  String toString() => 'SupabaseSessionExpiredException: $message';
}
