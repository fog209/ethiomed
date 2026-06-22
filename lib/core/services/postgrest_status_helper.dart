import 'package:supabase_flutter/supabase_flutter.dart';

int? postgrestStatus(PostgrestException exception) {
  final code = exception.code;
  if (code != null && RegExp(r'^\d{3}$').hasMatch(code)) {
    return int.tryParse(code);
  }

  final message = exception.message;
  final match = RegExp(r'\b(401|403|429|503|504)\b').firstMatch(message);
  if (match != null) {
    return int.tryParse(match.group(0)!);
  }

  return null;
}
