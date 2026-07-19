import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User's selected flashcard study stage preference.
/// 'clinical' | 'preclinical' | 'both' (default 'both' until explicitly chosen).
const String _trackPrefKey = 'flashcardTrack';
const String _trackChosenKey = 'flashcardTrackChosen';

const String flashcardTrackClinical = 'clinical';
const String flashcardTrackPreclinical = 'preclinical';
const String flashcardTrackBoth = 'both';

class FlashcardTrackNotifier extends StateNotifier<String> {
  FlashcardTrackNotifier() : super(flashcardTrackBoth) {
    _load();
  }

  /// True once the user has actively answered the study-stage prompt.
  /// Drives the one-time personalization prompt.
  bool hasChosen = false;

  /// True while the persisted preference is still loading from storage,
  /// so the UI can avoid a flash of the prompt for returning users.
  bool isLoading = true;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chosen = prefs.getBool(_trackChosenKey) ?? false;
      hasChosen = chosen;
      if (chosen) {
        final stored = prefs.getString(_trackPrefKey);
        if (stored == flashcardTrackClinical ||
            stored == flashcardTrackPreclinical ||
            stored == flashcardTrackBoth) {
          state = stored!;
        }
      }
    } catch (e) {
      debugPrint('Failed to load flashcard track pref: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Persist an explicit stage choice. This is a personalization/identity
  /// decision (not a filter tweak), so it also marks the prompt as answered.
  Future<void> setTrack(String track) async {
    if (track != flashcardTrackClinical &&
        track != flashcardTrackPreclinical &&
        track != flashcardTrackBoth) {
      return;
    }
    state = track;
    hasChosen = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_trackPrefKey, track);
      await prefs.setBool(_trackChosenKey, true);
    } catch (e) {
      debugPrint('Failed to save flashcard track pref: $e');
    }
  }
}

/// Reactive user study-stage preference. Defaults to 'both' so nothing breaks
/// before it is ever set, and gracefully matches null-track rows.
final flashcardTrackProvider =
    StateNotifierProvider<FlashcardTrackNotifier, String>(
  (ref) => FlashcardTrackNotifier(),
);
