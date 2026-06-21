import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const highYieldModeStorageKey = 'highYieldMode';

final highYieldModeProvider =
    StateNotifierProvider<HighYieldModeNotifier, bool>(
      (ref) => HighYieldModeNotifier(),
    );

class HighYieldModeNotifier extends StateNotifier<bool> {
  HighYieldModeNotifier() : super(false) {
    _load();
  }

  Future<void> toggle() async {
    final nextValue = !state;
    state = nextValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(highYieldModeStorageKey, nextValue);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(highYieldModeStorageKey) ?? false;
  }
}
