import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/config/app_config.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authSessionProvider = StreamProvider<Session?>((ref) {
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
  AuthController(this._authService) : super(const AuthUiState());

  final AuthService _authService;

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthUiState(status: AuthUiStatus.loading);

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
      return AuthController(ref.watch(authServiceProvider));
    });

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'ethiomed_access_token';
  static const String _refreshTokenKey = 'ethiomed_refresh_token';

  SupabaseClient get supabase {
    return _supabase;
  }

  Stream<Session?> get authStateStream {
    return _supabase.auth.onAuthStateChange.map((event) {
      return event.session;
    });
  }

  Session? get currentSession {
    return _supabase.auth.currentSession;
  }

  Future<void> initialize() async {
    try {
      final restored = await restoreSession();
      if (!restored) {
        await clearStoredTokens();
      }
    } catch (error) {
      debugPrint('Auth initialization failed: $error');
      await clearStoredTokens();
    }
  }

  Future<bool> restoreSession() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        return false;
      }

      final response = await _supabase.auth.refreshSession(refreshToken);
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
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session;

      if (session == null) {
        throw AppException('Sign in completed without a session.');
      }

      await _persistSession(session);
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
    try {
      final response = await _supabase.auth.signUp(
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
    try {
      await _supabase.auth.signOut();
      await clearStoredTokens();
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

  String get supabaseUrl {
    return AppConfig.supabaseUrl;
  }
}
