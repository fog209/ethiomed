# WardReady — LIFECYCLE_AUDIT.md

## Executive Summary

**Lifecycle Safety Score: 75/100**

The codebase demonstrates solid lifecycle management in most areas with proper mounted checks, controller disposal, and timer cancellation. However, there are several critical and high-risk issues that need attention.

---

## Critical Lifecycle Bugs

### 1. Unused `QuizQuestions` Table in Drift Schema

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/core/database/app_database.dart:50-63` | `QuizQuestions` table defined but never referenced | **Storage leak** — orphaned table consumes disk space | CRITICAL

The `QuizQuestions` table (lines 50-63) is registered in `@DriftDatabase(tables: [...])` but no code references it. The active table is `QuizTable` (lines 65-89). The schema has evolved but old table was never removed.

**Evidence:**
- `QuizTable` used throughout: `quiz_notifier.dart`, `quiz_repository.dart`, `spaced_repetition_service.dart`
- `QuizQuestions` never appears in queries or inserts
- Migration step 4 (line 124-128) drops and recreates but schema still includes the table

### 2. Auth `initialize()` Never Called

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/features/auth/data/auth_service.dart:129-139` | `initialize()` method exists but never invoked | **Session restore broken** — users must re-login on app restart | HIGH

The `initialize()` method attempts to restore session from secure storage but `main.dart` never calls it. Supabase session restoration on app restart is currently non-functional.

### 3. Duplicate Quiz Sync Service File

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/features/quiz/data/quiz_sync_service.dart` | Re-exports `quiz_sync_service.dart` | **Maintenance confusion** — redundant file | MEDIUM

The file in `data/` is a simple re-export. It adds confusion without value.

---

## High-Risk Async Hazards

### Missing Mounted Guards After Async Operations

| File | Line | Issue |
|------|------|-------|
| `lib/features/search/search_screen.dart:155-159` | `context.push()` called after `Future.microtask` without mounted check |
| `lib/features/search/search_screen.dart:118-122` | `setState()` called after async work without mounted check |
| `lib/features/search/search_screen.dart:62-66` | `ref.read(searchHistoryProvider.notifier).saveSearch()` without mounted check |
| `lib/features/search/search_screen.dart:102-106` | `ref.read(searchHistoryProvider.notifier).clearHistory()` without mounted check |

### QuizNotifier Service Initialization in build()

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/quiz_notifier.dart:31-34` | Services (`_repository`, `_syncService`, `_spacedRepetitionService`) obtained in `build()` instead of constructor |

This is an anti-pattern. Services should be initialized in the notifier constructor or via provider dependency injection, not in `build()`. If `build()` is called multiple times before the async future completes, services could be re-assigned.

### Navigation After Potential Disposal

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/quiz_screen.dart:329` | `_resetQuizAndPop(context)` called after `await notifier.nextQuestion()` |
| `lib/features/quiz/exam_session_notifier.dart:233-236` | State mutations in `answerQuestion()` without async safety |

---

## Resource Leaks

### Controllers (All Properly Disposed)

| File | Controller | Disposed | Status |
|------|------------|----------|--------|
| `lib/features/onboarding/onboarding_screen.dart:13` | PageController | Line 20 | VERIFIED |
| `lib/features/home/presentation/article_list_screen.dart:36` | ScrollController | Lines 58-59 | VERIFIED |
| `lib/features/auth/presentation/login_screen.dart:19-20` | TextEditingController (x2) | Lines 23-26 | VERIFIED |
| `lib/features/auth/presentation/signup_screen.dart:18-21` | TextEditingController (x4) | Lines 24-28 | VERIFIED |
| `lib/features/search/search_screen.dart:20` | TextEditingController | Line 36 | VERIFIED |
| `lib/features/articles/presentation/article_search_screen.dart:19` | TextEditingController | Line 43 | VERIFIED |

### Timers (All Properly Cancelled)

| File | Timer | Cancelled | Status |
|------|-------|-----------|--------|
| `lib/core/providers/connectivity_notifier.dart:34-36` | `_timer` Timer.periodic | Lines 61-64 | VERIFIED |
| `lib/core/providers/sync_state_provider.dart:81-85` | `_rateLimitTimer` | Lines 119-122 | VERIFIED |
| `lib/app/main_shell.dart:37-38` | `_subscriptionTimer` | Lines 73-74 | VERIFIED |
| `lib/features/quiz/exam_session_notifier.dart:71` | `_timer` (unused) | Lines 275-280 | VERIFIED |
| `lib/features/articles/data/article_search_provider.dart:84-90` | `_debounceTimer` | Lines 155-158 | VERIFIED |

### Streams

No manual `StreamSubscription` management found. Drift streams (watch methods) are handled via Riverpod `ref.watch()` which auto-disposes.

---

## Riverpod Lifecycle Issues

### Providers Missing autoDispose

| Provider | File | Issue | Risk |
|----------|------|-------|------|
| `articleOffsetProvider` | `article_list_screen.dart:12` | Screen-scoped but global persistence | MEDIUM |
| `articleLoadedArticlesProvider` | `article_list_screen.dart:14` | Holds loaded articles after screen dispose | MEDIUM |
| `articleHasMoreProvider` | `article_list_screen.dart:17` | Pagination state leaks | MEDIUM |
| `articleIsLoadingMoreProvider` | `article_list_screen.dart:18` | Loading state leaks | MEDIUM |
| `articleCurrentCategoryProvider` | `article_list_screen.dart:19` | Category state leaks | MEDIUM |
| `articleRequestIdProvider` | `article_list_screen.dart:13` | Request tracking state leaks | MEDIUM |

These pagination-related providers should use `autoDispose` since they track transient UI state for `ArticleListScreen`. When users navigate away and back, stale state may persist.

### Database Provider Lifecycle

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/database/app_database.dart:440-444` | `databaseProvider` uses `ref.keepAlive()` and `ref.onDispose(db.close)` |

**Correct:** The database is a singleton managed properly with cleanup on provider disposal.

### Notification Service Singleton Pattern

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/services/notification_service.dart:45-63` | Factory constructor with static `_instance` but provider creates new each time |

The static singleton pattern is bypassed by the Riverpod provider. Each provider watch creates a new instance, potentially duplicating notification channels. However, `_isInitialized` flag prevents double-initialization.

---

## Navigation Lifecycle

### Context Navigation After Async Without Guard

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/quiz_screen.dart:329` | `_resetQuizAndPop(context)` after `await` — has guard at line 339 | NEEDS VERIFICATION |
| `lib/features/articles/presentation/article_search_screen.dart:74-78` | `_runAfterBuild()` calls provider read without mounted check | LOW |

Navigation guards are generally present. `quiz_screen.dart` has proper guards.

---

## Database Lifecycle

### Transaction Safety

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/database/app_database.dart:69-103` | Drift transactions in `_runMigrationStep` | VERIFIED |
| `lib/features/quiz/spaced_repetition_service.dart:69-119` | Transaction in `recordReview()` | VERIFIED |
| `lib/features/quiz/quiz_repository.dart:108-134` | Transaction in `upsertQuestions()` | VERIFIED |

All database transactions are properly wrapped.

### Watch() Lifecycle

No explicit `StreamSubscription.cancel()` calls found. Drift `.watch()` streams are observed via Riverpod which handles cancellation.

---

## Notification Lifecycle

| File | Lines | Status |
|------|-------|--------|
| `lib/core/services/notification_service.dart:86-122` | `initialize()` called lazily with `_isInitialized` flag | VERIFIED |
| `lib/core/services/notification_service.dart:222-230` | `cancelDueReminders()` | VERIFIED |
| `lib/core/services/notification_service.dart:232-240` | `cancelAllScheduledNotifications()` | VERIFIED |

**Gap:** No explicit handling for app lifecycle state changes (background/foreground) for notification rescheduling.

---

## Connectivity Lifecycle

| File | Lines | Status |
|------|-------|--------|
| `lib/core/providers/connectivity_notifier.dart:34-36` | Timer starts in constructor | NEEDS VERIFICATION |
| `lib/core/providers/connectivity_notifier.dart:61-65` | Timer cancelled in dispose | VERIFIED |

**Concern:** Timer starts immediately when provider is created (constructor), not lazily. If provider fails before any widget reads it, timer won't be cleaned up.

---

## Animation Lifecycle

No `AnimationController` usage found that requires explicit disposal. The only animation is `AnimatedContainer` in `onboarding_screen.dart:47-55` which is stateless and managed by Flutter.

---

## Search Lifecycle

| File | Lines | Status |
|------|-------|--------|
| `lib/features/articles/data/article_search_provider.dart:84-158` | Debounce timer properly cancelled | VERIFIED |
| `lib/features/search/search_screen.dart` | Uses `_runAfterBuild` pattern without mounted guard | NEEDS VERIFICATION |

---

## Session Lifecycle

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/providers/session_timeout_provider.dart:14-27` | Timer resets on `resetTimer()` call | CORRECT |
| `lib/core/providers/session_timeout_provider.dart:35-37` | Cleanup on provider dispose | VERIFIED |
| `lib/features/auth/data/auth_service.dart:231-244` | `signOut()` clears tokens | CORRECT |

Session timeout is properly implemented with mounted guards in calling code.

---

## Error Recovery Lifecycle

| File | Lines | Status |
|------|-------|--------|
| `lib/core/database/app_database.dart:100-181` | Migration errors caught and stored via `MigrationErrorStore` | VERIFIED |
| `lib/core/screens/database_recovery_screen.dart:37-64` | Recovery flow with mounted guard | VERIFIED |
| `lib/features/articles/data/article_repository.dart:42-110` | All error paths return cached data | VERIFIED |
| `lib/features/quiz/quiz_repository.dart:42-99` | All error paths return cached data | VERIFIED |

Error recovery paths are solid with fallback to cached data.

---

## False Positives

| Finding | Evidence | Resolution |
|---------|----------|------------|
| Timer in ConnectivityNotifier constructor | `connectivity_notifier.dart:34` | Timer is cancelled in `dispose()`, safe |
| QuizSyncService in data/ folder | `lib/features/quiz/data/quiz_sync_service.dart:1` | Just a re-export, no runtime impact |
| `article_search_screen.dart` missing initState mounted guard | `article_search_screen.dart:34-38` | Uses `Future.microtask` immediately after state init, safe |
| Exam timer unused | `exam_session_notifier.dart:71` | Timer declared but never used, no impact |

---

## Recommended Fixes

### Critical (Effort: 30m)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Remove `QuizQuestions` table from Drift schema | `lib/core/database/app_database.dart:50-63,92` | 30m | Removes dead storage and schema complexity |

### High (Effort: 1-2h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Add `autoDispose` to pagination providers | `article_list_screen.dart:12-20` | 30m | Prevents stale UI state on navigation |
| Call `AuthService.initialize()` on app start | `main.dart` | 15m | Enables session restoration |
| Add mounted guards in search_screen.dart callbacks | `lib/features/search/search_screen.dart:57-66,102-106,117-122` | 20m | Prevents potential errors after dispose |
| Delete duplicate quiz_sync_service re-export | `lib/features/quiz/data/quiz_sync_service.dart` | 5m | Reduces confusion |

### Medium (Effort: 2-4h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Move QuizNotifier service init to constructor | `quiz_notifier.dart:17-19` | 4h | Better Riverpod pattern |
| Add Android 13+ notification permission handling | `notification_service.dart` | 2h | Required for Android 13+ |
| Lazy-start connectivity timer | `connectivity_notifier.dart:34` | 30m | Only start on first read |

### Low (Effort: 1-2h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Add `onDispose` cleanup to NotificationReminderNotifier | `notification_service.dart:26` | 15m | Consistency with other providers |
| Review NotificationService singleton pattern | `notification_service.dart:57-63` | 1h | Consider if singleton is needed |

---

## Final Verdict

**Rating: Good with Critical Gaps**

The lifecycle management is generally robust with proper mounted checks, controller disposal, and timer cancellation. The codebase follows Riverpod patterns correctly with `ref.onDispose()` usage.

**Critical Issues:**
1. **Dead table in schema** - `QuizQuestions` consumes storage unnecessarily
2. **Broken session restore** - `AuthService.initialize()` exists but is never called

**High-Risk Issues:**
1. **Missing autoDispose** on pagination providers
2. **Potential navigation after dispose** in `search_screen.dart`

These issues should be addressed before production release. The 75/100 score reflects good overall hygiene but critical gaps in session management and schema cleanup.