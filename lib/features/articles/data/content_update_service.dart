import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart' show supabaseInitializedProvider;

/// True when the server has article content newer than what the
/// user last viewed. Drives the dot/badge on the Library tab.
final contentUpdateAvailableProvider = StateProvider<bool>((ref) => false);

final contentUpdateServiceProvider = Provider((ref) => ContentUpdateService(ref));

class ContentUpdateService {
  ContentUpdateService(this._ref);

  final Ref _ref;

  static const String _lastSeenKey = 'content_last_seen_at';

  /// Compares the server's newest article [updated_at] against the locally
  /// stored last-seen timestamp. Sets the flag when newer content exists.
  /// No-op when Supabase is not initialized (offline/mock mode).
  Future<void> checkForUpdates() async {
    if (!_ref.read(supabaseInitializedProvider)) return;
    try {
      final rows = await Supabase.instance.client
          .from('articles')
          .select('updated_at')
          .order('updated_at', ascending: false)
          .limit(1);
      if (rows.isEmpty) return;
      final serverMaxStr = rows.first['updated_at'] as String?;
      if (serverMaxStr == null) return;
      final serverMax = DateTime.tryParse(serverMaxStr);
      if (serverMax == null) return;

      final prefs = await SharedPreferences.getInstance();
      final lastSeenMs = prefs.getInt(_lastSeenKey);
      if (lastSeenMs == null ||
          serverMax.isAfter(
            DateTime.fromMillisecondsSinceEpoch(lastSeenMs),
          )) {
        _ref.read(contentUpdateAvailableProvider.notifier).state = true;
      }
    } on PostgrestException catch (e) {
      debugPrint('Content update check failed: ${e.message}');
    } catch (e) {
      debugPrint('Content update check failed: $e');
    }
  }

  /// Records "now" as the last-seen time and clears the badge.
  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastSeenKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    _ref.read(contentUpdateAvailableProvider.notifier).state = false;
  }
}
