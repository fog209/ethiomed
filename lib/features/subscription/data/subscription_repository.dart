import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRepository {
  final SupabaseClient _supabase;
  SubscriptionRepository(this._supabase);

  Future<bool> checkSubscriptionStatus() async {
    final user = _supabase.auth.currentUser;
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
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
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

final subscriptionRepositoryProvider = Provider(
  (ref) => SubscriptionRepository(Supabase.instance.client),
);

final isSubscribedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).checkSubscriptionStatus();
});
