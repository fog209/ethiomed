import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/app_exception.dart';

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
      sub = subsData.first as Map<String, dynamic>;
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

      debugPrint('DEBUG_ADMIN: Fetched ${response.length} users');

      return response.map((json) => AdminUser.fromSupabase(json)).toList();
    } on PostgrestException catch (e) {
      debugPrint('DEBUG_ADMIN: Database Error: ${e.message}');
      throw AppException(e.message);
    } catch (e) {
      debugPrint('DEBUG_ADMIN: UI/Parsing Error: $e');
      throw AppException('Unable to load users.');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      final expiry = DateTime.now()
          .toUtc()
          .add(const Duration(days: 365))
          .toIso8601String();
      await _supabase.from('subscriptions').upsert({
        'user_id': userId,
        'is_active': true,
        'status': 'active',
        'expiry_date': expiry,
        'activated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      debugPrint('DEBUG_ADMIN: Activation database error: ${e.message}');
      throw AppException(e.message);
    } catch (e) {
      debugPrint('DEBUG_ADMIN: Activation error: $e');
      throw AppException('Activation failed.');
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
  } catch (e) {
    return false;
  }
});
