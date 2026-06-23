import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the device has network connectivity.
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);

/// Tracks whether the Supabase server was recently unreachable.
/// Set to true on 503/504/SocketException, auto-clears on next successful sync.
final serverUnreachableProvider =
    StateNotifierProvider<ServerUnreachableNotifier, bool>(
      (ref) => ServerUnreachableNotifier(),
    );

class ServerUnreachableNotifier extends StateNotifier<bool> {
  ServerUnreachableNotifier() : super(false);

  void markUnreachable() {
    state = true;
  }

  void markReachable() {
    state = false;
  }
}

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectivity();
    });
  }

  Timer? _timer;

  void markOffline() {
    state = false;
  }

  void markOnline() {
    state = true;
  }

  Future<void> _checkConnectivity() async {
    try {
      await InternetAddress.lookup('example.com');
      state = true;
    } on SocketException {
      state = false;
    } catch (error) {
      debugPrint('Connectivity check error: $error');
      state = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
