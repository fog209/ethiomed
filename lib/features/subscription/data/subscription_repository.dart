import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../main.dart' show supabaseInitializedProvider;

class SubscriptionRepository {
  final SupabaseClient? _supabase;
  final FlutterSecureStorage _secureStorage;

  SubscriptionRepository(this._supabase, {FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  bool get _isAvailable => _supabase != null;

  static const String _lastSubCheckTimestampKey = 'last_sub_check_timestamp';
  static const Duration _gracePeriod = Duration(days: 30);

  Future<bool> checkSubscriptionStatus() async {
    if (!_isAvailable) {
      // Offline mode: no subscription check possible, default to false
      return false;
    }
    final user = _supabase!.auth.currentUser;
    if (user == null) return false;

    try {
      final profile = await _supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();

      if (profile?['is_admin'] == true) {
        return true;
      }

      final sub = await _supabase
          .from('subscriptions')
          .select('status, expiry_date')
          .eq('user_id', user.id)
          .maybeSingle();

      if (sub == null) return false;

      final status = sub['status']?.toString();
      if (status != 'active') {
        return false;
      }

      final expiryDate = _parseExpiryDate(sub['expiry_date']);
      // Use server time, not the device clock, so a user who rolls back
      // their system clock cannot spoof an unexpired subscription.
      final now = await _fetchServerNow();
      return isSubscriptionActive(
        status: status,
        expiryDate: expiryDate,
        now: now,
      );
    } on PostgrestException catch (e) {
      debugPrint('Sub check error: ${e.message}');
      // If network failure, check grace period (Part 4-B)
      if (_isNetworkError(e)) {
        return _hasGracePeriod();
      }
      throw AppException(e.message);
    } catch (e) {
      debugPrint('Sub check error: $e');
      // If network failure, check grace period (Part 4-B)
      if (_isNetworkError(e)) {
        return _hasGracePeriod();
      }
      throw AppException('Could not verify subscription.');
    }
  }

  bool _isNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('dio');
  }

  /// Fetches the current time from the Postgres server (via the `server_now`
  /// RPC) so subscription expiry is evaluated against authoritative time
  /// rather than the user's device clock. Falls back to device UTC time if
  /// the RPC is unavailable or the request fails, so offline/expired-RPC
  /// scenarios still degrade gracefully instead of throwing.
  Future<DateTime> _fetchServerNow() async {
    if (!_isAvailable) return DateTime.now().toUtc();
    try {
      final response = await _supabase!
          .rpc('server_now')
          .timeout(const Duration(seconds: 10));
      if (response is String) {
        final parsed = DateTime.tryParse(response);
        if (parsed != null) return parsed.toUtc();
      }
      return DateTime.now().toUtc();
    } catch (e) {
      debugPrint('Server time fetch failed, using device time: $e');
      return DateTime.now().toUtc();
    }
  }

  Future<bool> _hasGracePeriod() async {
    final stored = await _secureStorage.read(key: _lastSubCheckTimestampKey);
    if (stored == null) return false;
    final lastCheck = DateTime.tryParse(stored);
    if (lastCheck == null) return false;
    return DateTime.now().toUtc().difference(lastCheck) < _gracePeriod;
  }

  Future<void> recordSuccessfulCheck() async {
    await _secureStorage.write(
      key: _lastSubCheckTimestampKey,
      value: DateTime.now().toUtc().toIso8601String(),
    );
  }

  DateTime? _parseExpiryDate(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toUtc();
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    final timestamp = num.tryParse(text);
    if (timestamp != null) {
      final milliseconds = timestamp > 100000000000
          ? timestamp
          : timestamp * 1000;
      return DateTime.fromMillisecondsSinceEpoch(
        milliseconds.round(),
        isUtc: true,
      );
    }

    return DateTime.tryParse(text)?.toUtc();
  }
}

/// Pure, Supabase-free decision used by [SubscriptionRepository
/// .checkSubscriptionStatus] to decide whether a subscription grants access.
///
/// Extracted as a free function so the read-path (paywall show/hide) logic can
/// be unit-tested without a network/Supabase client. It mirrors the in-app
/// rule exactly:
///   - a non-`active` status denies access;
///   - a null expiry (no expiry set) grants access;
///   - an expiry in the future grants access;
///   - an expiry in the past denies access.
///
/// The boundary (expiry == now) is treated as expired (not `isAfter`), so the
/// paywall shows the instant a subscription lapses.
bool isSubscriptionActive({
  required String? status,
  required DateTime? expiryDate,
  required DateTime now,
}) {
  if (status != 'active') {
    return false;
  }
  if (expiryDate == null) {
    return true;
  }
  return expiryDate.isAfter(now);
}

final subscriptionRepositoryProvider = Provider((ref) {
  final isReady = ref.watch(supabaseInitializedProvider);
  if (!isReady) {
    return SubscriptionRepository(null);
  }
  return SubscriptionRepository(Supabase.instance.client);
});

final isSubscribedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final result = await repo.checkSubscriptionStatus();
  if (result) {
    await repo.recordSuccessfulCheck();
  }
  return result;
});
