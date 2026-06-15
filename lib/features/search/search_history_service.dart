import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// THE GLUE: This matches exactly what the Search Screen expects
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) { _load(); }
  static const _key = 'wardready_history';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getStringList(_key) ?? [];
  }

  Future<void> saveSearch(String query) async {
    final term = query.trim();
    if (term.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    // Clean up: no duplicates, case-insensitive, limit to 10
    final updated = [term, ...state.where((e) => e.toLowerCase() != term.toLowerCase())].take(10).toList();
    await p.setStringList(_key, updated);
    state = updated;
  }

  Future<void> clearHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    state = [];
  }
}