# WardReady — RELEASE_BLOCKERS

## MUST FIX BEFORE BETA (Prevents app functionality)

| # | Issue | File | Effort | Risk |
|---|-------|------|--------|------|
| 1 | Supabase key validation missing | `lib/app/env.dart`, `lib/main.dart` | 30m | CRITICAL — App builds but cannot connect |
| 2 | Notification permission flow for Android 13+ | `lib/core/services/notification_service.dart` | 2h | CRITICAL — Notifications fail silently |
| 3 | Session restore not called | `lib/features/auth/data/auth_service.dart:129-139` | 15m | HIGH — Users re-login on every restart |

## MUST FIX BEFORE PRODUCTION (Scale/features)

| # | Issue | File | Effort | Risk |
|---|-------|------|--------|------|
| 4 | FLAG_SECURE for medical content | `android/app/src/main/AndroidManifest.xml` | 15m | HIGH — Play Store policy violation |
| 5 | EHPLE Exam Mode UI missing | `lib/features/quiz/exam_session_notifier.dart` | 8h | HIGH — Feature incomplete |
| 6 | Admin list pagination needed | `lib/features/admin/data/admin_repository.dart:54-64` | 4h | HIGH (scale) — OOM at 10k+ users |

## SHOULD FIX BEFORE RELEASE (UX/stability)

| # | Issue | File | Effort | Risk |
|---|-------|------|--------|------|
| 7 | Database recovery exit(0) | `lib/core/screens/database_recovery_screen.dart:63` | 30m | MEDIUM — Poor UX |
| 8 | Quiz question selection performance | `lib/features/quiz/exam_session_notifier.dart:128-207` | 3h | MEDIUM — Slow exam start |
| 9 | Category progress invalidation storm | `lib/features/home/presentation/categories_screen.dart:120-143` | 2h | MEDIUM — UI jank |

## NICE TO HAVE (Can release with known issues)

| # | Issue | File | Effort | Risk |
|---|-------|------|--------|------|
| 10 | Unused dependencies (fsrs, google_fonts) | `pubspec.yaml:18,20` | 15m | LOW — APK bloat |
| 11 | Colors.grey[]! null assertions | Multiple files | 1h | LOW — Potential rendering issue |
| 12 | Quiz table schema mismatch | `lib/core/database/app_database.dart` | 30m | LOW — Tech debt |

## Ready for Release

- Offline-first strategy verified
- Authentication flow works
- Search with FTS5 recovery implemented
- Quiz SM-2 algorithm tested
- Theming complete
- Legal screens present
- Subscription gating functional