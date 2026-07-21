import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/config/app_config.dart';
import '../../../main.dart' show supabaseInitializedProvider;
import '../../articles/data/content_update_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseAvailable = ref.watch(supabaseInitializedProvider);
  return AuthService(supabaseAvailable: supabaseAvailable, ref: ref);
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  final supabaseAvailable = ref.watch(supabaseInitializedProvider);
  if (!supabaseAvailable) {
    return const Stream.empty();
  }
  return ref.watch(authServiceProvider).authStateStream;
});

enum AuthUiStatus { initial, loading, success, error }

class AuthUiState {
  const AuthUiState({this.status = AuthUiStatus.initial, this.message});

  final AuthUiStatus status;
  final String? message;

  bool get isLoading {
    return status == AuthUiStatus.loading;
  }

  bool get hasError {
    return status == AuthUiStatus.error;
  }

  AuthUiState copyWith({AuthUiStatus? status, String? message}) {
    return AuthUiState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class AuthController extends StateNotifier<AuthUiState> {
  AuthController(this._authService, this._ref) : super(const AuthUiState());

  final AuthService _authService;
  final Ref _ref;

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthUiState(status: AuthUiStatus.loading);

    final ready = _ref.read(supabaseInitializedProvider);
    if (!ready) {
      state = const AuthUiState(
        status: AuthUiStatus.error,
        message: 'Cannot sign in while offline.',
      );
      return;
    }

    try {
      await _authService.signIn(email: email, password: password);
      state = const AuthUiState(
        status: AuthUiStatus.success,
        message: 'Signed in successfully.',
      );
    } on AppException catch (error) {
      state = AuthUiState(status: AuthUiStatus.error, message: error.message);
    } catch (error) {
      debugPrint('Auth sign in unexpected error: $error');
      state = AuthUiState(
        status: AuthUiStatus.error,
        message: 'Unable to sign in. Please try again.',
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentType,
  }) async {
    state = const AuthUiState(status: AuthUiStatus.loading);

    final ready = _ref.read(supabaseInitializedProvider);
    if (!ready) {
      state = const AuthUiState(
        status: AuthUiStatus.error,
        message: 'Cannot sign up while offline.',
      );
      return;
    }

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentType: studentType,
      );
      state = const AuthUiState(
        status: AuthUiStatus.success,
        message: 'Account created successfully. Sign in to continue.',
      );
    } on AppException catch (error) {
      state = AuthUiState(status: AuthUiStatus.error, message: error.message);
    } catch (error) {
      debugPrint('Auth sign up unexpected error: $error');
      state = AuthUiState(
        status: AuthUiStatus.error,
        message: 'Unable to create account. Please try again.',
      );
    }
  }

  void clearMessage() {
    if (state.hasError) {
      state = const AuthUiState();
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthUiState>((ref) {
      return AuthController(ref.watch(authServiceProvider), ref);
    });

class AuthService {
  final bool supabaseAvailable;
  final FlutterSecureStorage _secureStorage;
  final Ref? _ref;

  AuthService({this.supabaseAvailable = false, Ref? ref})
    : _ref = ref,
      _secureStorage = const FlutterSecureStorage();

  Stream<Session?> get authStateStream {
    if (!supabaseAvailable) {
      return const Stream.empty();
    }
    return Supabase.instance.client.auth.onAuthStateChange.map((event) {
      return event.session;
    });
  }

  Session? get currentSession {
    if (!supabaseAvailable) {
      return null;
    }
    return Supabase.instance.client.auth.currentSession;
  }

  Future<void> initialize() async {
    // No-op: initialization is handled in main() before app starts
    return;
  }

  Future<bool> restoreSession() async {
    if (!supabaseAvailable) {
      return false;
    }
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        return false;
      }

      final response = await Supabase.instance.client.auth.refreshSession(refreshToken);
      final session = response.session;

      if (session == null) {
        await clearStoredTokens();
        return false;
      }

      await _persistSession(session);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Auth restore error: ${e.message}');
      await clearStoredTokens();
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      await clearStoredTokens();
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (!supabaseAvailable) {
      throw AppException('Cannot sign in while offline.');
    }
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session;

      if (session == null) {
        throw AppException('Sign in completed without a session.');
      }

      await _persistSession(session);
      await recordSession();
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Auth sign in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentType,
  }) async {
    if (!supabaseAvailable) {
      throw AppException('Cannot sign up while offline.');
    }
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: <String, String>{
          'full_name': fullName,
          'student_type': studentType,
        },
      );
      final session = response.session;

      if (session == null) {
        throw AppException('Check your email to confirm your account.');
      }

      await _persistSession(session);
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Auth sign up error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!supabaseAvailable) {
      await clearStoredTokens();
      _ref?.read(contentUpdateAvailableProvider.notifier).state = false;
      _ref?.read(sectionRegistryProvider.notifier).state = const {};
      return;
    }
    try {
      await Supabase.instance.client.auth.signOut();
      await clearStoredTokens();
      _ref?.read(contentUpdateAvailableProvider.notifier).state = false;
      _ref?.read(sectionRegistryProvider.notifier).state = const {};
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Auth sign out error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> _persistSession(Session session) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
  }

  Future<void> clearStoredTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Returns a stable per-device ID, generated once and persisted in
  /// secure storage. (package_info_plus exposes app version, not a device
  /// ID, so a UUID is generated and stored locally instead.)
  Future<String> get _deviceId async {
    final existing = await _secureStorage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = _generateDeviceId();
    await _secureStorage.write(key: _deviceIdKey, value: id);
    return id;
  }

  String _generateDeviceId() {
    final random = Random();
    final bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
      growable: false,
    );
    // Mark as a version-4 UUID.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .toList(growable: false);
    return '${hex.sublist(0, 4).join()}'
        '-${hex.sublist(4, 6).join()}'
        '-${hex.sublist(6, 8).join()}'
        '-${hex.sublist(8, 10).join()}'
        '-${hex.sublist(10, 16).join()}';
  }

  /// Records this device's session row after a successful sign-in, then
  /// prunes the oldest rows so the account stays within the cap.
  /// No-op when Supabase is unavailable or the user isn't signed in.
  Future<void> recordSession() async {
    if (!supabaseAvailable) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final deviceId = await _deviceId;
      final now = DateTime.now().toIso8601String();
      await Supabase.instance.client
          .from('active_sessions')
          .upsert(
            {
              'user_id': user.id,
              'device_id': deviceId,
              'created_at': now,
              'last_seen_at': now,
            },
            onConflict: 'user_id,device_id',
          );
      await _pruneSessions(user.id);
    } on PostgrestException catch (e) {
      debugPrint('Session record failed: ${e.message}');
    } catch (e) {
      debugPrint('Session record failed: $e');
    }
  }

  /// Periodic keep-alive: refreshes this device's last_seen_at and
  /// prunes both over-cap and stale rows. Called from MainShell's
  /// 30-minute timer.
  Future<void> refreshSessionHeartbeat() async {
    if (!supabaseAvailable) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final deviceId = await _deviceId;
      final now = DateTime.now().toIso8601String();
      await Supabase.instance.client
          .from('active_sessions')
          .update({'last_seen_at': now})
          .eq('user_id', user.id)
          .eq('device_id', deviceId);
      await _pruneSessions(user.id);
      await _pruneStaleSessions(user.id);
    } on PostgrestException catch (e) {
      debugPrint('Session heartbeat failed: ${e.message}');
    } catch (e) {
      debugPrint('Session heartbeat failed: $e');
    }
  }

  /// Keeps only the [_maxConcurrentSessions] most-recently-seen
  /// rows for [userId] by deleting the oldest-by-last_seen_at.
  Future<void> _pruneSessions(String userId) async {
    try {
      final rows = await Supabase.instance.client
          .from('active_sessions')
          .select('device_id, last_seen_at')
          .eq('user_id', userId)
          .order('last_seen_at', ascending: true);
      if (rows.length <= _maxConcurrentSessions) return;
      final toRemove = rows.sublist(0, rows.length - _maxConcurrentSessions);
      for (final row in toRemove) {
        final deviceId = row['device_id'] as String?;
        if (deviceId == null) continue;
        await Supabase.instance.client
            .from('active_sessions')
            .delete()
            .eq('user_id', userId)
            .eq('device_id', deviceId);
      }
    } on PostgrestException catch (e) {
      debugPrint('Session prune failed: ${e.message}');
    } catch (e) {
      debugPrint('Session prune failed: $e');
    }
  }

  /// Removes sessions idle longer than [_staleSessionCutoff] so
  /// abandoned devices don't permanently occupy the cap.
  Future<void> _pruneStaleSessions(String userId) async {
    try {
      final cutoff = DateTime.now()
          .subtract(_staleSessionCutoff)
          .toIso8601String();
      await Supabase.instance.client
          .from('active_sessions')
          .delete()
          .eq('user_id', userId)
          .lt('last_seen_at', cutoff);
    } on PostgrestException catch (e) {
      debugPrint('Stale session prune failed: ${e.message}');
    } catch (e) {
      debugPrint('Stale session prune failed: $e');
    }
  }

  String get supabaseUrl {
    return AppConfig.supabaseUrl;
  }
}

// Keys must stay as-is per AGENTS.md prohibition (no rename without explicit go-ahead)
const String _accessTokenKey = 'ethiomed_access_token';
const String _refreshTokenKey = 'ethiomed_refresh_token';

// Stable per-device ID for the active_sessions cap feature.
const String _deviceIdKey = 'wardready_device_id';

/// Max concurrent active sessions allowed per account (account-sharing cap).
const int _maxConcurrentSessions = 2;

/// Idle threshold after which a session row is pruned by the
/// periodic heartbeat, so abandoned devices don't clog the cap.
const Duration _staleSessionCutoff = Duration(days: 30);
