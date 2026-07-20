import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../main.dart' show supabaseInitializedProvider;
import 'reference_models.dart';

/// Read-only access to the admin-managed `flowcharts` and `local_guidelines`
/// Supabase tables. Clients can only SELECT (RLS-enforced); content is added
/// from the Supabase dashboard / a service-role script.
class ReferenceRepository {
  const ReferenceRepository(this._supabase);

  final SupabaseClient? _supabase;

  Future<List<Flowchart>> fetchFlowcharts() async {
    if (_supabase == null) {
      throw const AppException('Offline — flowcharts unavailable.');
    }
    try {
      final response = await _supabase
          .from('flowcharts')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => Flowchart.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('Flowcharts fetch error: ${e.message}');
      throw AppException(e.message);
    } catch (e) {
      debugPrint('Flowcharts fetch error: $e');
      throw const AppException('Failed to load flowcharts.');
    }
  }

  Future<List<LocalGuideline>> fetchLocalGuidelines() async {
    if (_supabase == null) {
      throw const AppException('Offline — guidelines unavailable.');
    }
    try {
      final response = await _supabase
          .from('local_guidelines')
          .select()
          .order('uploaded_at', ascending: false);
      return (response as List)
          .map((json) => LocalGuideline.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('Local guidelines fetch error: ${e.message}');
      throw AppException(e.message);
    } catch (e) {
      debugPrint('Local guidelines fetch error: $e');
      throw const AppException('Failed to load guidelines.');
    }
  }
}

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  final isReady = ref.watch(supabaseInitializedProvider);
  return ReferenceRepository(isReady ? Supabase.instance.client : null);
});

final flowchartsProvider = FutureProvider<List<Flowchart>>((ref) async {
  return ref.watch(referenceRepositoryProvider).fetchFlowcharts();
});

final localGuidelinesProvider = FutureProvider<List<LocalGuideline>>((ref) {
  return ref.watch(referenceRepositoryProvider).fetchLocalGuidelines();
});
