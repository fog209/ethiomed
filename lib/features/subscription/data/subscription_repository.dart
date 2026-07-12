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
      return expiryDate == null || expiryDate.isAfter(DateTime.now().toUtc());
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
