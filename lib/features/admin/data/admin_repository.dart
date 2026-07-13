import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_exceptions.dart';
import '../../../core/services/postgrest_status_helper.dart';

class AdminUser {
  final String userId;
  final String? email;
  final String? fullName;
  final bool isAdmin;
  final String status;
  final String? expiryDate;

  const AdminUser({
    required this.userId,
    this.email,
    this.fullName,
    this.isAdmin = false,
    required this.status,
    this.expiryDate,
  });

  bool get isSubscribed => status == 'active';

  factory AdminUser.fromSupabase(Map<String, dynamic> json) {
    // Defensive check for subscriptions list
    final dynamic subsData = json['subscriptions'];
    Map<String, dynamic> sub = {};

    if (subsData is List && subsData.isNotEmpty) {
      final firstElement = subsData.first;
      if (firstElement is Map<String, dynamic>) {
        sub = firstElement;
      } else {
        debugPrint('Warning: subscriptions first element is not a Map');
      }
    } else if (subsData is Map<String, dynamic>) {
      sub = subsData;
    }

    return AdminUser(
      userId: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? 'No Email',
      fullName: json['full_name']?.toString() ?? 'No Name',
      isAdmin: json['is_admin'] == true,
      status: sub['status']?.toString() ?? 'pending',
      expiryDate: sub['expiry_date']?.toString(),
    );
  }
}

class AdminRepository {
  final SupabaseClient _supabase;
  AdminRepository(this._supabase);

  Future<List<AdminUser>> fetchAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select(
            'id, full_name, email, is_admin, subscriptions(status, expiry_date)',
          )
          .order('created_at', ascending: false);

      return response.map((json) => AdminUser.fromSupabase(json)).toList();
    } on PostgrestException catch (e) {
      final status = postgrestStatus(e);
      if (status == 401) {
        throw const SupabaseSessionExpiredException();
      }
      if (status == 403) {
        debugPrint('RLS rejection on profiles: ${e.message}');
        throw AppException('Permission denied. Admin access required.');
      }
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      final now = DateTime.now().toUtc();
      final totalMonths = now.month - 1 + 4;
      final year = now.year + totalMonths ~/ 12;
      final month = totalMonths % 12 + 1;
      final lastDay = DateTime.utc(year, month + 1, 0).day;
      final day = now.day > lastDay ? lastDay : now.day;
      final expiry = DateTime.utc(year, month, day).toIso8601String();
      await _supabase.from('subscriptions').upsert({
        'user_id': userId,
        'is_active': true,
        'status': 'active',
        'expiry_date': expiry,
        'activated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      final status = postgrestStatus(e);
      if (status == 401) {
        throw const SupabaseSessionExpiredException();
      }
      if (status == 403) {
        debugPrint('RLS rejection on subscriptions: ${e.message}');
        throw AppException('Permission denied. Admin access required.');
      }
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}

// PROVIDERS
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(Supabase.instance.client),
);

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchAllUsers();
});

final currentAdminProfileProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;
  try {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .maybeSingle();
    return profile?['is_admin'] == true;
    } on PostgrestException catch (e) {
      final status = postgrestStatus(e);
      if (status == 401) {
        throw const SupabaseSessionExpiredException();
      }
      if (status == 403) {
        debugPrint('RLS rejection on profiles: ${e.message}');
        throw AppException('Permission denied. Admin access required.');
      }
      debugPrint('Admin activate error: ${e.message}');
      throw AppException(e.message);
    } catch (e) {
      debugPrint('Admin activate error: $e');
      throw AppException('Could not activate user.');
    }
});
