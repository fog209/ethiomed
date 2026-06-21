import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectivity();
    });
  }

  Timer? _timer;

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
