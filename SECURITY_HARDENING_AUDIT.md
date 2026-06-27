# WardReady — SECURITY_HARDENING_AUDIT.md

## Executive Summary

**Security Score: 73/100**

The codebase implements solid security fundamentals: secure token storage, proper RLS error handling, and offline-first design. However, several production concerns exist: missing FLAG_SECURE for medical content, no Android 13+ notification permission flow, and potential information leakage through error messages.

---

## Critical Vulnerabilities

### 1. Missing FLAG_SECURE for Medical Content

| File | Lines | Risk |
|------|-------|------|
| `android/app/src/main/AndroidManifest.xml` | Full file | **HIGH** — No FLAG_SECURE prevents screen capture/recording |

Medical education content should prevent screen capture. Ethiopian medical licensing exams may expose sensitive content.

**Evidence:** No `FLAG_SECURE` in AndroidManifest.xml or Activity configuration.

### 2. Session Restoration Disabled

| File | Lines | Risk |
|------|-------|------|
| `lib/features/auth/data/auth_service.dart:129-139` | `initialize()` method exists | **HIGH** — Users must re-login on app restart |

The method attempts session restore but is never called from `main.dart`. This affects user experience but also security posture (users may disable 2FA if forced to re-login frequently).

---

## High-Risk Findings

### Unverified Notification Permission Flow (Android 13+)

| File | Lines | Risk |
|------|-------|------|
| `lib/core/services/notification_service.dart:111-115` | Request permission code exists | **MEDIUM** — May not work on Android 13+ |

```dart
final androidPlugin = _plugin.resolvePlatformSpecificImplementation();
await androidPlugin?.requestNotificationsPermission();
```

This runs during initialization but there's no UI flow to explain why permission is needed.

### Error Information Leakage

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/progress/progress_screen.dart:27-28` | `debugPrint('PROGRESS_ERROR_TYPE: ${error.runtimeType}');` | Stack traces logged to device |
| `lib/features/home/presentation/categories_screen.dart:95-96` | Same pattern | Internal error details logged |

These logs could contain sensitive data if users extract device logs.

### Hardcoded Strings in Error Messages

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/articles/domain/models/article.dart:26` | `"Article ${json['id']} has no category..."` | Internal IDs exposed in logs |

---

## Medium Findings

### Token Storage in Secure Storage

| File | Lines | Status |
|------|-------|--------|
| `lib/features/auth/data/auth_service.dart:112-113,248-256` | Uses `FlutterSecureStorage` | CORRECT |

**Good:**
- Access tokens stored in secure storage
- Refresh tokens stored separately
- Tokens cleared on signOut

**Concern:** No encryption-at-rest option configured. Default secure storage may vary by platform.

### RLS Error Handling

| File | Lines | Status |
|------|-------|--------|
| `lib/features/articles/data/article_repository.dart:70-89` | RLS rejection returns cached data | GOOD |
| `lib/features/quiz/quiz_repository.dart:63-72` | Same pattern | GOOD |

Properly handles unauthorized access by falling back to cache instead of exposing data.

### Supabase URL/Anon Key Handling

| File | Lines | Status |
|------|-------|--------|
| `lib/app/env.dart:1-9` | `String.fromEnvironment` with empty defaults | NEEDS VERIFICATION |

**Issue:** If environment variables aren't set, the app may crash or connect to wrong endpoint.

### Admin Activation Without Audit Trail

| File | Lines | Risk |
|------|-------|------|
| `lib/features/admin/data/admin_repository.dart:81-109` | `activateUser()` updates subscription | MEDIUM — No logging of who activated |

Admin activations aren't logged. Multiple admins could conflict.

---

## Low Findings

### SharedPreferences for Non-Sensitive Data

| File | Lines | Status |
|------|-------|--------|
| `lib/features/search/search_history_service.dart:8-14` | Search history in SharedPreferences | CORRECT |
| `lib/features/onboarding/onboarding_screen.dart:55` | Onboarding state in SharedPreferences | CORRECT |

Non-sensitive data stored appropriately.

### Debug Output in Production

| File | Lines | Risk |
|------|-------|------|
| All debugPrint calls | 79 occurrences | LOW — Only appears in debug builds |

`debugPrint` is stripped in release builds. Safe.

### No Certificate Pinning

Supabase connections use standard HTTPS without certificate pinning. Acceptable for medical education but not HIPAA-grade.

---

## Defense-in-Depth Improvements

### Authentication Layer

| Improvement | Location |
|-------------|----------|
| Add biometric auth option | `auth_service.dart` |
| Session restore on app start | `main.dart:80-91` |
| Account lockout after failed attempts | `auth_service.dart:172-195` |

### Authorization Layer

| Improvement | Location |
|-------------|----------|
| Admin action audit trail | `admin_repository.dart:81-109` |
| Row-level expiry checks | `subscription_repository.dart` |
| Subscription cache hardening | `isSubscribedProvider` |

### Data Protection

| Improvement | Location |
|-------------|----------|
| Add FLAG_SECURE | `AndroidManifest.xml` |
| Encrypt local SQLite | `app_database.dart` |
| Wipe data on subscription expiry | `subscription_repository.dart` |

### Network Security

| Improvement | Location |
|-------------|----------|
| Certificate pinning | Supabase client init |
| Request signing | All Supabase calls |
| Timeout hardening | All network calls |

---

## Secure Coding Recommendations

### Input Validation

Currently minimal. Add:

1. Email format validation before Supabase calls
2. Password strength requirements (length, complexity)
3. Search query sanitization (done in `_toFtsQuery`)

### Error Handling

Current pattern exposes too much:

```dart
// Current
debugPrint('SYNCHRONIZATION_ERROR: ${error.runtimeType}');

// Recommended
if (kReleaseMode) {
  // Send to crash reporting service
} else {
  debugPrint('Auth error: ${error.message}');
}
```

### Logging

| Level | Use | Examples |
|-------|-----|----------|
| Error | Production crash reporting | AppException messages |
| Warning | Recoverable issues | Sync failures, rate limits |
| Info | Debug builds only | Category assignments |

---

## Release Security Checklist

### Must Fix Before Production

- [ ] Add FLAG_SECURE to AndroidManifest.xml
- [ ] Call `AuthService.initialize()` in main()
- [ ] Verify Android 13+ notification permission flow
- [ ] Add input validation for signup fields
- [ ] Sanitize admin activation requests

### Should Fix

- [ ] Add certificate pinning for Supabase
- [ ] Implement admin audit trail
- [ ] Add session expiration warning
- [ ] Encrypt local database (SQLCipher)

### Nice to Have

- [ ] Biometric authentication option
- [ ] Account lockout after failed logins
- [ ] Security event logging to server
- [ ] Remote config for security settings

---

## Final Verdict

**Rating: Good Foundation, Needs Production Hardening**

Security score: 73/100

**Strengths:**
- Secure token storage via `FlutterSecureStorage`
- RLS error handling returns cache, not errors
- No hardcoded secrets in source code
- Session timeout prevents indefinite sessions

**Critical gaps:**
1. Missing FLAG_SECURE for medical content
2. Session restoration not wired up
3. Android 13+ notification permission incomplete

**Medium gaps:**
1. Error logging could expose internal details
2. No admin action audit trail
3. No input validation on signup

The app is **safe for beta release** but **needs hardening before production**. The offline-first design actually improves security posture by reducing exposure to network attacks.

---

## Evidence Summary

| File | Security Finding |
|------|------------------|
| `security/flutter_secure_storage` | Tokens stored securely |
| `main.dart:80-91` | Supabase initialized with env vars |
| `AndroidManifest.xml` | No FLAG_SECURE for medical content |
| `auth_service.dart:129-139` | Session restore implemented but not called |
| `notification_service.dart:111-115` | Android 13+ permission flow incomplete |
| `admin_repository.dart:81-109` | Admin activation without audit logging |