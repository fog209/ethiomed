import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionTimeoutProvider =
    StateNotifierProvider<SessionTimeoutNotifier, bool>((ref) {
  return SessionTimeoutNotifier(ref);
});

class SessionTimeoutNotifier extends StateNotifier<bool> {
  SessionTimeoutNotifier(this._ref) : super(false);

  final Ref _ref;
  static const _timeoutDuration = Duration(minutes: 30);
  Timer? _timer;
  bool _isInitialized = false;

  void resetTimer() {
    if (!_isInitialized) {
      _isInitialized = true;
      _ref.onDispose(_cleanup);
    }
    _timer?.cancel();
    _timer = Timer(_timeoutDuration, () {
      Supabase.instance.client.auth.signOut();
      // Only set state to true if not already logged out
      if (Supabase.instance.client.auth.currentSession != null) {
        state = true;
      }
    });
  }

  void _cleanup() {
    _timer?.cancel();
  }
}