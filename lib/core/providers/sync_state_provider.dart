import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>(
  (ref) => SyncStateNotifier(),
);

class SyncState {
  const SyncState({
    this.serverUnreachable = false,
    this.rateLimited = false,
    this.syncIncomplete = false,
    this.diskFull = false,
    this.lastRateLimitedAt,
    this.lastSuccessfulSyncAt,
  });

  final bool serverUnreachable;
  final bool rateLimited;
  final bool syncIncomplete;
  final bool diskFull;
  final DateTime? lastRateLimitedAt;
  final DateTime? lastSuccessfulSyncAt;

  SyncState copyWith({
    bool? serverUnreachable,
    bool? rateLimited,
    bool? syncIncomplete,
    bool? diskFull,
    DateTime? lastRateLimitedAt,
    DateTime? lastSuccessfulSyncAt,
  }) {
    return SyncState(
      serverUnreachable: serverUnreachable ?? this.serverUnreachable,
      rateLimited: rateLimited ?? this.rateLimited,
      syncIncomplete: syncIncomplete ?? this.syncIncomplete,
      diskFull: diskFull ?? this.diskFull,
      lastRateLimitedAt: lastRateLimitedAt ?? this.lastRateLimitedAt,
      lastSuccessfulSyncAt:
          lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
    );
  }
}

class SyncStateNotifier extends StateNotifier<SyncState> {
  SyncStateNotifier() : super(const SyncState());

  Timer? _rateLimitTimer;

  void setServerUnreachable() {
    markServerUnreachable();
  }

  void setRateLimited() {
    markRateLimited();
  }

  void setDiskFull() {
    markDiskFull();
  }

  void setSuccessfulSync() {
    markSuccessfulSync();
  }

  void markServerUnreachable() {
    state = state.copyWith(
      serverUnreachable: true,
      syncIncomplete: false,
    );
  }

  void markRateLimited() {
    _rateLimitTimer?.cancel();
    final now = DateTime.now();
    state = state.copyWith(
      rateLimited: true,
      lastRateLimitedAt: now,
    );
    _rateLimitTimer = Timer(const Duration(seconds: 30), () {
      if (DateTime.now().difference(now) >= const Duration(seconds: 30)) {
        state = state.copyWith(rateLimited: false);
      }
    });
  }

  bool canSyncAfterRateLimit() {
    final last = state.lastRateLimitedAt;
    if (last == null) {
      return true;
    }

    return DateTime.now().difference(last) >= const Duration(seconds: 60);
  }

  void markSyncIncomplete() {
    state = state.copyWith(
      syncIncomplete: true,
      serverUnreachable: false,
      rateLimited: false,
    );
  }

  void markDiskFull() {
    state = state.copyWith(diskFull: true);
  }

  void markSuccessfulSync() {
    state = state.copyWith(
      serverUnreachable: false,
      rateLimited: false,
      syncIncomplete: false,
      lastSuccessfulSyncAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    super.dispose();
  }
}
