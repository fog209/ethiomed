import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _timer = Timer(_timeoutDuration, () async {
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      if (hasSession) {
        await Supabase.instance.client.auth.signOut();
        state = true;
      }
    });
  }

  void consumeLogout() {
    state = false;
  }

  void _cleanup() {
    _timer?.cancel();
  }
}

final sessionTimeoutProvider =
    StateNotifierProvider<SessionTimeoutNotifier, bool>((ref) {
  return SessionTimeoutNotifier(ref);
});