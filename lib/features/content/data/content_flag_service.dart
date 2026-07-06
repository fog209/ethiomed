import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/connectivity_notifier.dart';

enum ContentType { article, question }

enum IssueType { typo, factual, unclear }

final contentFlagServiceProvider = Provider<ContentFlagService>((ref) {
  return ContentFlagService(
    supabase: Supabase.instance.client,
    onOffline: () => ref.read(connectivityProvider.notifier).markOffline(),
  );
});

class ContentFlagService {
  final SupabaseClient _supabase;
  final VoidCallback _onOffline;

  ContentFlagService({
    required SupabaseClient supabase,
    required VoidCallback onOffline,
  })  : _supabase = supabase,
        _onOffline = onOffline;

  Future<bool> submitFlag({
    required ContentType contentType,
    required String contentId,
    required IssueType issueType,
    required String userNote,
  }) async {
    try {
      await _supabase.from('content_flags').insert({
        'content_type': contentType.name,
        'content_id': contentId,
        'issue_type': issueType.name,
        'user_note': userNote,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.code == 'offline') {
        _onOffline();
        return false;
      }
      debugPrint('Content flag error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Content flag error: $e');
      return false;
    }
  }
}