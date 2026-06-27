# WardReady — TECHNICAL_DEBT_V2

## Critical Debt (Breaks feature or blocks release)

| Issue | File | Lines | Risk | Effort to Fix |
|-------|------|-------|------|---------------|
| QuizNotifier tri-service coupling | `lib/features/quiz/quiz_notifier.dart` | 17-34 | HIGH | Refactoring quiz breaks everything | 4h |
| EHPLE Exam Mode no UI route | `lib/features/quiz/exam_session_notifier.dart` | 49-53 | HIGH | Feature inaccessible | 8h |
| Supabase key validation missing | `lib/app/env.dart` | 2-8 | CRITICAL | App non-functional without flags | 30m |

## High Debt (Will cause issues at scale or in production)

| Issue | File | Lines | Risk | Effort to Fix |
|-------|------|-------|------|---------------|
| Admin list unpaginated | `lib/features/admin/data/admin_repository.dart` | 54-64 | HIGH | OOM at 10k+ users | 4h |
| Exam N+1 queries | `lib/features/quiz/exam_session_notifier.dart` | 128-207 | HIGH | Slow exam start | 3h |
| Notification permission missing | `lib/core/services/notification_service.dart` | 115 | CRITICAL | Android 13+ broken | 2h |
| FLAG_SECURE missing | `android/app/src/main/AndroidManifest.xml` | - | HIGH | Policy violation | 15m |
| Session restore not called | `lib/features/auth/data/auth_service.dart` | 129-139 | HIGH | Re-login every restart | 15m |
| Category progress invalidation storm | `lib/features/home/presentation/categories_screen.dart` | 120-143 | MEDIUM | UI jank | 2h |

## Medium Debt (Maintenance burden, some user impact)

| Issue | File | Lines | Risk | Effort to Fix |
|-------|------|-------|------|---------------|
| Quiz table schema mismatch | `lib/core/database/app_database.dart` | 67-89,89-90 | MEDIUM | lastQuality used but not declared | 30m |
| Unused QuizQuestions table | `lib/core/database/app_database.dart` | 51-63,92 | MEDIUM | Dead schema | 15m |
| Unused fsrs/google_fonts deps | `pubspec.yaml` | 18,20 | MEDIUM | APK bloat | 15m |
| Database recovery exit(0) | `lib/core/screens/database_recovery_screen.dart` | 63 | MEDIUM | Poor UX | 30m |
| Provider invalidation storm | `lib/features/home/presentation/categories_screen.dart` | 120-143 | MEDIUM | 25+ DB queries | 2h |
| Search FTS5 fallback full scan | `lib/features/articles/data/article_search_provider.dart` | 191-201 | MEDIUM | Slow on error | 1h |
| No index on next_due_at | `lib/features/quiz/spaced_repetition_service.dart` | 41-65 | MEDIUM | Slow due card queries | 30m |

## Low Debt (Cosmetic or minor)

| Issue | File | Lines | Risk | Effort to Fix |
|-------|------|-------|------|---------------|
| Colors.grey[]! null assertions | Multiple files | Various | LOW | Potential crash | 1h |
| Shimmer duplication | Multiple files | Various | LOW | Code duplication | 30m |
| Search history no error handling | `lib/features/search/search_history_service.dart` | 10-25 | LOW | Silent failures | 30m |
| lastAttemptedAt type mismatch | `lib/features/quiz/quiz_repository.dart` | 130-142 | LOW | Unused field | 15m |
| session_date legacy column | `lib/core/database/app_database.dart` | 230 | LOW | Migration confusion | 30m |

## Architectural Debt

| Issue | Description | Fix |
|-------|-------------|-----|
| Repository owns state notification | Repositories call sync state providers directly | Use event bus or mediator pattern |
| Missing central auth provider | Auth checks duplicated across services | Create AuthNotifier with session state |
| Schema migration in UI path | WeaknessService migrates during read | Move to database initialization |
| No repository for progress | Direct Drift calls in multiple places | Create ProgressRepository |

## Dependencies to Remove

| Package | Reason | Removal Risk |
|---------|--------|--------------|
| fsrs | Installed but unused (not imported anywhere) | None |
| google_fonts | Installed but unused (not imported anywhere) | None |

## Recommendations

1. **Immediate:** Fix critical blockers before any release
2. **Soon:** Address exam mode and admin pagination for production
3. **Future:** Refactor QuizNotifier architecture
4. **Tech Debt Sprint:** Clean up unused code, add missing indexes