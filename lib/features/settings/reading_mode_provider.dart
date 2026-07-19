import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading-mode preferences: font scale, line height multiplier, and a
/// sepia background toggle. Persisted via SharedPreferences so the choice
/// survives app restarts. Pure presentation state — no business logic.
class ReadingModeState {
  const ReadingModeState({
    this.fontScale = 1.0,
    this.lineHeight = 1.5,
    this.sepia = false,
  });

  final double fontScale;
  final double lineHeight;
  final bool sepia;

  ReadingModeState copyWith({
    double? fontScale,
    double? lineHeight,
    bool? sepia,
  }) {
    return ReadingModeState(
      fontScale: fontScale ?? this.fontScale,
      lineHeight: lineHeight ?? this.lineHeight,
      sepia: sepia ?? this.sepia,
    );
  }
}

final readingModeProvider =
    StateNotifierProvider<ReadingModeNotifier, ReadingModeState>(
  (ref) => ReadingModeNotifier(),
);

class ReadingModeNotifier extends StateNotifier<ReadingModeState> {
  ReadingModeNotifier() : super(const ReadingModeState()) {
    _load();
  }

  static const String _fontScaleKey = 'reading_font_scale';
  static const String _lineHeightKey = 'reading_line_height';
  static const String _sepiaKey = 'reading_sepia';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final fontScale = prefs.getDouble(_fontScaleKey);
    final lineHeight = prefs.getDouble(_lineHeightKey);
    final sepia = prefs.getBool(_sepiaKey);
    if (fontScale != null || lineHeight != null || sepia != null) {
      state = state.copyWith(
        fontScale: fontScale ?? state.fontScale,
        lineHeight: lineHeight ?? state.lineHeight,
        sepia: sepia ?? state.sepia,
      );
    }
  }

  Future<void> setFontScale(double value) async {
    state = state.copyWith(fontScale: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, value);
  }

  Future<void> setLineHeight(double value) async {
    state = state.copyWith(lineHeight: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, value);
  }

  Future<void> setSepia(bool value) async {
    state = state.copyWith(sepia: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sepiaKey, value);
  }
}
