import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) => SearchHistoryNotifier());

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) { _load(); }
  static const _key = 'recent_searches';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getStringList(_key) ?? [];
  }

  Future<void> saveSearch(String q) async {
    final term = q.trim();
    if (term.isEmpty) return;
    final p = await SharedPreferences.getInstance();
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