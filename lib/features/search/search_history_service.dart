import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSearchHistoryKey = 'search_history';
const _kMaxHistoryEntries = 10;

/// Provides access to [SearchHistoryService].
final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return SearchHistoryService();
});

/// Riverpod provider that exposes the current search history list.
/// Call `ref.invalidate(searchHistoryProvider)` after mutations to refresh.
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(searchHistoryServiceProvider);
  return service.getHistory();
});

/// Manages a capped, de-duplicated search history backed by [SharedPreferences].
class SearchHistoryService {
  /// Persists [query] to history.
  ///
  /// Rules:
  /// * Blank / whitespace-only strings are ignored.
  /// * Duplicate entries (case-insensitive comparison on trimmed value) are
  ///   moved to the front rather than duplicated.
  /// * History is capped at [_kMaxHistoryEntries] most-recent entries.
  Future<void> saveSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = _readList(prefs);

    // Remove existing duplicate (case-insensitive).
    history.removeWhere(
      (entry) => entry.toLowerCase() == trimmed.toLowerCase(),
    );

    // Prepend the new entry.
    history.insert(0, trimmed);

    // Enforce cap.
    if (history.length > _kMaxHistoryEntries) {
      history.removeRange(_kMaxHistoryEntries, history.length);
    }

    await prefs.setStringList(_kSearchHistoryKey, history);
  }

  /// Returns the stored history list, newest first.
  /// Returns an empty list when no history has been saved yet.
  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return _readList(prefs);
  }

  /// Removes all search history entries.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSearchHistoryKey);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> _readList(SharedPreferences prefs) {
    return List<String>.from(
      prefs.getStringList(_kSearchHistoryKey) ?? <String>[],
    );
  }
}
