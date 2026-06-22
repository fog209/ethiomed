import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/error_exceptions.dart';
import 'postgrest_status_helper.dart';

Future<void> handleSupabaseSessionFailure({
  required BuildContext context,
  required SupabaseClient supabase,
  required Object error,
}) async {
  final isSessionFailure = _isSessionFailure(error);
  if (!isSessionFailure || !context.mounted) {
    return;
  }

  await supabase.auth.signOut();
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Your session expired. Please sign in again.')),
  );
  context.go('/login');
}

Future<void> handleSupabaseAccountSessionFailure({
  required BuildContext context,
  required SupabaseClient supabase,
  required Object error,
}) async {
  final isAccountSessionFailure = _isSessionFailure(error) ||
      error.toString().toLowerCase().contains('user not found');
  if (!isAccountSessionFailure || !context.mounted) {
    return;
  }

  await supabase.auth.signOut();
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Account session ended. Please sign in.')),
  );
  context.go('/login');
}

bool isSupabaseSessionFailure(Object error) => _isSessionFailure(error);

bool _isSessionFailure(Object error) {
  if (error is SupabaseSessionExpiredException) {
    return true;
  }

  if (error is PostgrestException) {
    return postgrestStatus(error) == 401;
  }

  return false;
}
