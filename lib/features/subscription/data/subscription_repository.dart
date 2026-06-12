import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRepository {
  final SupabaseClient _supabase;
  SubscriptionRepository(this._supabase);

  Future<bool> checkSubscriptionStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('is_active')
          .eq('user_id', user.id)
          .maybeSingle();
      if (response == null) return false;
      return response['is_active'] ?? false;
    } catch (e) {
      return false;
    }
  }
}

final subscriptionRepositoryProvider = Provider((ref) => SubscriptionRepository(Supabase.instance.client));

final isSubscribedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).checkSubscriptionStatus();
});