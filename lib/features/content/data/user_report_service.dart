import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/connectivity_notifier.dart';

final userReportServiceProvider = Provider<UserReportService>((ref) {
  return UserReportService(
    supabase: Supabase.instance.client,
    onOffline: () => ref.read(connectivityProvider.notifier).markOffline(),
  );
});

class UserReportService {
  final SupabaseClient _supabase;
  final VoidCallback _onOffline;

  UserReportService({
    required SupabaseClient supabase,
    required VoidCallback onOffline,
  })  : _supabase = supabase,
        _onOffline = onOffline;

  Future<bool> submitReport({
    required String contentType,
    required String contentId,
    required String reportText,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('UserReportService: No authenticated user');
        return false;
      }

      await _supabase.from('user_reports').insert({
        'user_id': user.id,
        'content_type': contentType,
        'content_id': contentId,
        'report_text': reportText,
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.code == 'offline') {
        _onOffline();
        return false;
      }
      debugPrint('UserReportService error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('UserReportService unexpected error: $e');
      return false;
    }
  }
}