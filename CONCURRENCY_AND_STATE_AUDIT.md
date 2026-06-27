# WardReady — CONCURRENCY_AND_STATE_AUDIT.md

## Executive Summary

**State Consistency Score: 68/100**

The repository shows moderate risk for race conditions. Key strengths include proper transaction usage and mounted guards. Critical weaknesses include unawaited operations, lack of synchronization for concurrent writes, and potential double-sync issues.

---

## Critical Race Conditions

### 1. Unawaited Sync Operations

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/features/home/presentation/categories_screen.dart:133` | Auto-sync on empty articles with `unawaited()` | **Double sync risk** — sync may be cancelled mid-flight | CRITICAL |
| `lib/features/home/presentation/categories_screen.dart:171` | FAB sync with `unawaited()` | **No completion tracking** — user may navigate away | HIGH |

**Scenario:** User opens app, auto-sync starts. User taps FAB sync immediately. Both run in parallel, potentially causing duplicate inserts or rate limiting hits.

### 2. Notification Reminder Notifier Initialization Race

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/core/services/notification_service.dart:27` | `unawaited(_load())` in constructor | **State desync** — notification enabled before load completes | MEDIUM |

**Scenario:** User taps switch before `_load()` completes. State shows enabled but underlying storage doesn't reflect change.

### 3. QuizSyncService Error Handling Race

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/features/quiz/quiz_sync_service.dart:15-28` | Swallows exceptions differently than repository | **Inconsistent state** — repository throws, sync service returns void | HIGH |

**Scenario:** `syncQuestions()` catches and swallows `SocketException`, repository throws. Callers may expect different error behavior.

---

## High-Risk Ordering Bugs

### Stale State in QuizNotifier

| File | Lines | Issue | Risk |
|------|-------|-------|------|
| `lib/features/quiz/quiz_notifier.dart:140-149` | `AsyncData(state.value ?? [])` in recordReview finally block | **Stale state clobber** — if state changed during review, new value lost | HIGH |

**Problem:** The finally block resets state to `state.value ?? []` which ignores any updates that occurred during the `try` block. If another operation modified state concurrently, that change is wiped.

### Search Debounce Race

| File | Lines | Issue | Risk |
|------|-------|------|------|
| `lib/features/articles/data/article_search_provider.dart:84-111` | Debounce timer allows overlapping searches | **Result confusion** — fast typing yields wrong results | MEDIUM |

**Scenario:** User types "cardio" quickly. Searches for "ca", "car", "card" all fire. Last one to complete shows "card" results even if "ca" completes last.

### Pagination Invalidation Race

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/home/presentation/article_list_screen.dart:67-79` | `_resetPagination()` invalidates multiple providers sequentially |

Multiple `ref.read().state = ...` calls without synchronization. If user scrolls during this, inconsistent state.

---

## Duplicate Async Operations

### Article Sync Paths

| Path 1 | Path 2 | Issue |
|--------|--------|-------|
| `CategoriesScreen.initState` → `syncInBackground()` | `ArticleListScreen` → repository sync | Potential double fetch on app start if sync already in progress |

Both paths can trigger sync. No guard against concurrent syncs.

### Notification Scheduling

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/services/notification_service.dart:124-170` | `rescheduleDueReminders()` and `scheduleDueReminder()` both initialize | Notification might be scheduled twice |

Both methods call `initialize()` independently. Could create duplicate channels or schedules.

---

## Provider Consistency Issues

### Pagination Providers Missing autoDispose

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/home/presentation/article_list_screen.dart:12-20` | 6 providers without autoDispose | Stale state after navigation |

When user navigates between categories, old pagination state persists.

### Session Timeout Provider Initialization

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/providers/session_timeout_provider.dart:7-42` | `_isInitialized` flag set in `resetTimer()` | Timer cleanup via `onDispose` only, not when no session exists |

If no session exists, timer is still created and disposed, wasting cycles.

### Database Provider Lifecycle

| File | Lines | Status |
|------|-------|--------|
| `lib/core/database/app_database.dart:440-444` | Uses `keepAlive` correctly | CORRECT |

Database singleton is properly managed.

---

## Repository Synchronization Issues

### Article Sync Concurrent Access

| File | Lines | Issue |
|------|-------|-------|-------|
| `lib/features/articles/data/article_repository.dart:42-110` | No guard against concurrent sync | Multiple callers can trigger overlapping sync |

**Evidence:** No `Mutex` or `isSyncing` flag. `syncInBackground()` is identical to `fetchAndSyncArticles()`.

### Quiz Sync Concurrent Modification

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/quiz_repository.dart:108-134` | `upsertQuestions()` in transaction but callers not synchronized | Race condition if two syncs run simultaneously |

---

## Database Consistency Issues

### FTS5 Index Race

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/articles/data/article_search_provider.dart:278-298` | FTS5 rebuild deletes all then reinserts | **Window of inconsistency** — search fails during rebuild |

If articles are inserted during the 200ms between delete and insert, they're lost from search index.

### Quiz Table N+1 Query Race

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/exam_session_notifier.dart:93-102,137-166` | Sequential queries in loop with no transaction | **Inconsistent question sets** — articles added/removed during exam start |

Each category query is independent. If data changes mid-execution, exam uses partial dataset.

### Migration Error Handling

| File | Lines | Status |
|------|-------|--------|
| `lib/core/database/app_database.dart:100-109` | Catches migration errors, sets store value | CORRECT — errors logged, not silent failures |

Migration errors are captured and displayed to user. Good pattern.

---

## Supabase Synchronization Issues

### Auth State Redirect Race

| File | Lines | Issue |
|------|-------|-------|
| `lib/main.dart:252-276` | StreamBuilder for auth changes triggers navigation | **Navigation during route transition** — user may be mid-action |

Auth state change triggers immediate navigation without checking current route.

### Subscription Check Double-Refresh

| File | Lines | Issue |
|------|-------|-------|
| `lib/app/main_shell.dart:37-69` | Periodic subscription check + manual refresh | Both can fire simultaneously |

Timer check every 30 minutes and user pressing "I HAVE PAID" can overlap.

---

## Connectivity Issues

### Sync Storm on Reconnection

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/providers/connectivity_notifier.dart:49-58` | Connectivity check fires every 30s | Multiple connectivity events trigger sync attempts |

No debounce or guard. If offline for 5 minutes, 10 sync attempts queued.

---

## Navigation Races

### Logout During Quiz Session

| File | Lines | Status |
|------|-------|--------|
| `lib/features/settings/presentation/settings_screen.dart:210-212` | Logout with mounted guard | CORRECT |

Navigation guarded properly.

### Admin Redirects During Auth

| File | Lines | Status |
|------|-------|--------|
| `lib/main.dart:151-159` | Admin route has proper redirect | CORRECT |

Guard checks admin status before allowing access.

---

## Authentication Consistency

### Session Restore Missing

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/auth/data/auth_service.dart:129-139` | `initialize()` exists, never called | Session not restored on cold start |

Users must re-authenticate on app restart.

### Multiple Login Race

| File | Lines | Status |
|------|-------|--------|
| `lib/features/auth/presentation/login_screen.dart:29-51` | Form validates once before async | CORRECT — button disabled during loading |

Login button disabled during request, prevents double submit.

---

## Notification Scheduling Issues

### Duplicate Initialization

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/services/notification_service.dart:57-63` | Factory creates new each time, but `_isInitialized` prevents double-init | Redundant object creation |

Each Riverpod watch creates new service instance, but initialization is idempotent.

### Missing Cancel Before Schedule

| File | Lines | Issue |
|------|-------|-------|
| `lib/core/services/notification_service.dart:124-139` | `scheduleDueReminder` doesn't cancel existing | **Duplicate notifications** if called twice for same date |

No `cancelDueReminders()` before `_scheduleDailyReminder()` in `scheduleDueReminder()`.

---

## Theme State Issues

### Startup Race

| File | Lines | Status |
|------|-------|--------|
| `lib/main.dart:93-96` | Theme loaded from prefs before runApp | CORRECT |

No race condition — theme read synchronously before widget tree builds.

---

## Search Consistency Issues

### Result Clobber in Debounce

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/articles/data/article_search_provider.dart:121-132` | State overwrite without checking if search is stale | **Wrong results shown** if search completes out of order |

No tracking of "current search" ID to ignore stale results.

---

## Progress Consistency Issues

### Stats Update Race

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/progress/streak_notifier.dart:30-40,42-74` | Multiple async operations update same stats | **Partial updates** possible |

If `recordArticleRead` and `recordQuizResult` fire for same day, second may overwrite first's changes.

---

## Admin Consistency Issues

### Stale Dashboard After Activation

| File | Lines | Status |
|------|-------|--------|
| `lib/features/admin/presentation/admin_dashboard_screen.dart:80` | `invalidate(adminUsersProvider)` after activation | CORRECT |

Refreshes after mutation. Good.

---

## Error Recovery Issues

### Retry Without Backoff

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/home/presentation/categories_screen.dart:97` | Retry invalidates without backoff | **Retry storm** if server stays down |

Manual retry has no rate limiting. User spamming retry triggers repeated failures.

---

## False Positives

| Finding | Evidence | Resolution |
|---------|----------|------------|
| Double notification schedule | `notification_service.dart:124` | `initialize()` is idempotent, safe |
| Quiz table race | `exam_session_notifier.dart:128` | Exam starts once on button press, no concurrent calls |
| Search microtask race | `search_screen.dart:31` | Microtask executes before next frame, safe |

---

## Recommended Fixes

### Critical (Effort: 2-4h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Add sync guard mutex | `article_repository.dart` | 2h | Prevent concurrent syncs |
| Add search request ID | `article_search_provider.dart` | 2h | Ignore stale search results |
| Call AuthService.initialize() | `main.dart` | 30m | Enable session restore |

### High (Effort: 4-8h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Fix QuizNotifier state clobber | `quiz_notifier.dart:140-149` | 4h | Preserve concurrent state updates |
| Add notification cancel-before-schedule | `notification_service.dart` | 2h | Prevent duplicates |
| Add autoDispose to pagination | `article_list_screen.dart:12-20` | 1h | Prevent stale state |

### Medium (Effort: 8-16h)

| Fix | File | Effort | Rationale |
|-----|------|--------|-----------|
| Consolidate sync paths | Multiple repositories | 8h | Single source of truth |
| Add debounce to connectivity | `connectivity_notifier.dart` | 2h | Prevent sync storms |

---

## Final Verdict

**Rating: Moderate Risk**

The repository has **moderate concurrency risk** (68/100). Core issues:

1. **Race-prone sync operations** - no mutex guarding
2. **Unawaited async** - fire-and-forget increases inconsistency risk  
3. **State clobber in QuizNotifier** - finally block overwrites updates
4. **Search result ordering** - no stale-result detection

**Strengths:**
- Transactions used correctly in repositories
- Mounted guards prevent most widget races
- Database singleton properly managed
- Error handling returns cached data

**Immediate actions needed:**
1. Guard concurrent sync operations
2. Ignore stale search results
3. Fix QuizNotifier state management
4. Call AuthService.initialize() in main()