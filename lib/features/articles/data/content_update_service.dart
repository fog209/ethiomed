import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart' show supabaseInitializedProvider;

/// True when the server has article content newer than what the
/// user last viewed. Drives the dot/badge on the Library tab.
final contentUpdateAvailableProvider = StateProvider<bool>((ref) => false);

/// Holds the locally-cached section registry (key → metadata) so the article
/// detail renderer can look up icon/label/order for a section key without
/// re-querying Supabase on every render. Populated by
/// [ContentUpdateService.syncSectionRegistry].
final sectionRegistryProvider =
    StateProvider<Map<String, SectionRegistryEntry>>((ref) => const {});

/// Parsed form of [SectionRegistryEntry.appliesTo] (stored as a JSON array
/// string in the Drift TEXT column, mirroring the Postgres `text[]`).
extension SectionRegistryEntryX on SectionRegistryEntry {
  List<String>? get parsedAppliesTo {
    if (appliesTo == null || appliesTo!.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(appliesTo!);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // Fall back to comma-separated for resilience.
      return appliesTo!.split(',').map((e) => e.trim()).toList();
    }
    return null;
  }

  /// Parsed form of [SectionRegistryEntry.categoryLabelOverrides] (stored as a
  /// JSON object string in the Drift TEXT column, mirroring the Postgres
  /// `jsonb`). Returns a map keyed by category name → override label, or null
  /// when no overrides are present.
  Map<String, String>? get parsedCategoryLabelOverrides {
    final raw = categoryLabelOverrides;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    } catch (_) {
      // Ignore malformed overrides — fall back to the generic label.
    }
    return null;
  }
}

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

  /// Pulls the entire `section_registry` table from Supabase and caches it
  /// locally (Drift) + in [sectionRegistryProvider] for the article renderer.
  ///
  /// The registry is tiny (~16-32 rows) and changes rarely, so it is always
  /// fetched in full on app launch — no badge/diff logic, by design. No-op
  /// when Supabase is not initialized (offline/mock mode). Missing table or
  /// RLS rejection is treated as "use the in-code fallback defaults" rather
  /// than an error.
  Future<void> syncSectionRegistry() async {
    if (!_ref.read(supabaseInitializedProvider)) return;
    try {
       final rows = await Supabase.instance.client
           .from('section_registry')
            .select(
              'key, label, icon_name, display_order, applies_to, enabled, category_label_overrides',
            )
           .order('display_order', ascending: true);

      final db = _ref.read(databaseProvider);
      final entries = <String, SectionRegistryEntry>{};
      await db.transaction(() async {
        // Replace the local cache wholesale — the table is small and the
        // remote source is authoritative.
        await (db.delete(db.sectionRegistry)).go();
        for (final row in rows) {
          final key = (row['key'] as String?) ?? '';
          if (key.isEmpty) continue;
          final appliesTo = row['applies_to'];
          final appliesToList = appliesTo is List
              ? appliesTo.map((e) => e.toString()).toList()
              : null;
          final overrides = row['category_label_overrides'];
          final overridesJson = overrides == null
              ? null
              : (overrides is String ? overrides : jsonEncode(overrides));
          final entry = SectionRegistryEntry(
            key: key,
            label: (row['label'] as String?) ?? key,
            iconName: row['icon_name'] as String?,
            displayOrder: (row['display_order'] as int?) ?? 999,
            appliesTo: appliesToList == null
                ? null
                : jsonEncode(appliesToList),
            categoryLabelOverrides: overridesJson,
            enabled: (row['enabled'] as bool?) ?? true,
          );
          await db
              .into(db.sectionRegistry)
              .insert(entry, mode: InsertMode.insertOrReplace);
          entries[key] = entry;
        }
      });
      _ref.read(sectionRegistryProvider.notifier).state = entries;
    } on PostgrestException catch (e) {
      debugPrint('Section registry sync failed (using fallback): ${e.message}');
    } catch (e) {
      debugPrint('Section registry sync failed (using fallback): $e');
    }
  }
}
