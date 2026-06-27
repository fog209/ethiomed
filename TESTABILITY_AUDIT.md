# WardReady — TESTABILITY_AUDIT.md

## Executive Summary

**Testability Score: 62/100**

The codebase has moderate testability with significant barriers. Strengths include Riverpod dependency injection and pure business logic in some services. Weaknesses include static singletons, DateTime.now() calls, Random() usage, and SharedPreferences/Supabase direct access.

---

## Critical Testability Issues

### 1. Static Singletons Hard to Mock

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/auth/data/auth_service.dart:109-110` | `Supabase.instance` and `FlutterSecureStorage` created in constructor |
| `lib/features/admin/data/admin_repository.dart:114` | `Supabase.instance.client` in provider |
| `lib/features/quiz/quiz_repository.dart:232` | `Supabase.instance.client` in provider |
| `lib/features/subscription/data/subscription_repository.dart:119` | `Supabase.instance.client` in provider |

**Problem:** No interface abstraction. Cannot inject mock Supabase client for testing.

### 2. Time Dependencies Everywhere

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/quiz/spaced_repetition_service.dart:43,210` | `DateTime.now()` used directly in SM-2 calculations |
| `lib/features/quiz/exam_session_notifier.dart:131` | `Random()` created in method |
| `lib/features/quiz/quiz_screen.dart:368` | `DateTime.now().add()` in display |
| `lib/features/subscription/data/subscription_repository.dart:47,79,85` | Multiple `DateTime.now()` calls |
| `lib/core/database/app_database.dart:168,200` | `DateTime.now()` in streak calculations |
| `lib/core/services/notification_service.dart:256,281,305` | Multiple time zone/time calls |

**Problem:** Tests cannot control time. SM-2 algorithm behavior cannot be unit tested with specific dates.

### 3. SharedPreferences Direct Access

| File | Lines | Issue |
|------|-------|-------|
| `lib/features/search/search_history_service.dart:11,18,25` | Direct `SharedPreferences.getInstance()` calls |
| `lib/features/onboarding/onboarding_screen.dart:25` | Direct in widget |
| `lib/features/legal/disclaimer_screen.dart:55` | Direct in widget |
| `lib/main.dart:31,37` | Direct in main() |
| `lib/core/services/notification_service.dart:174,190` | Direct in service |

**Problem:** Tests cannot mock preferences. Theme and onboarding state hard to test.

---

## High-Value Refactors

### Extract Time Provider

| Current Problem | Solution | Effort |
|-----------------|----------|--------|
| `DateTime.now()` scattered | Create `clockProvider` with `Clock` abstraction | 3-4h |
| `Random()` in exam | Inject `Random` via provider | 1h |
| Time zone handling | Extract to `TimeZoneHelper` | 2h |

### Repository Abstraction

| Current Problem | Solution | Effort |
|-----------------|----------|--------|
| Supabase singleton | Create `SupabaseClient` interface with `SupabaseClientAdapter` | 8h |
| No repository interfaces | Create abstract base classes | 4h |
| Callback-based events | Use event bus or return-only pattern | 6h |

### SharedPreferences Abstraction

| Current Problem | Solution | Effort |
|-----------------|----------|--------|
| Direct getInstance() calls | Create `PreferencesStorage` interface | 4h |
| Multiple access points | Single abstraction for all prefs | 3h |

---

## Components Easy to Test

| Component | Evidence | Test Points |
|-----------|----------|-------------|
| `ArticleSearchRepository` | Pure methods, injectable database | Search queries, FTS5 rebuild logic |
| `ProgressNotifier` | AsyncNotifier pattern, mockable DB | Streak calculation, heatmap load |
| `StreakNotifier` | Mockable database, clear methods | Stats load, record operations |
| `QuizOption` enum | Pure data | All states, parsing |
| `EmptyState` widget | No business logic | Render, styling |
| `OfflineBanner` widget | Static UI | Display |
| `QuizOption` model | Pure enum | Value access |

---

## Components Difficult to Test

| Component | Evidence | Issue |
|-----------|----------|-------|
| `AuthService` | `Supabase.instance`, `FlutterSecureStorage` static | No way to inject mock auth |
| `ArticleRepository` | Supabase singleton in provider | Integration only |
| `QuizRepository` | Supabase singleton, callback pattern | Hard to isolate |
| `SubscriptionRepository` | Direct SecureStorage, DateTime.now() | Time-based logic untestable |
| `NotificationService` | Plugin singleton, DateTime.now() | Side effects, time dependency |
| `SpacedRepetitionService` | DateTime.now(), DB operations | Need time + DB mocks |
| `ExamSessionNotifier` | Random(), DateTime.now(), N+1 queries | Complex state setup |
| `ArticleDetailScreen` | initState async, DB operations | Widget integration only |
| `QuizScreen` | initState async, multiple providers | Large widget tree |

---

## Mocking Strategy

### Current Approach (Limited)

```dart
// Providers can be overridden but singleton dependencies cannot
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(
    supabase: Supabase.instance.client, // Cannot mock
    database: ref.watch(databaseProvider), // Can mock
  );
});
```

### Recommended Approach

```dart
abstract class SupabaseClient {
  StreamAuthStateChange get auth;
  SupabaseQueryBuilder from(String table);
}

class SupabaseClientAdapter implements SupabaseClient {
  final SupabaseClient _client;
  // adapter methods
}
```

---

## Recommended Test Pyramid

| Layer | Files | Estimated Tests | Current Coverage |
|-------|-------|-----------------|-----------------|
| Unit | Services (6 files) | 50-70 | 30% |
| Unit | Notifiers (5 files) | 40-60 | 20% |
| Widget | Screens (10 files) | 30-50 | 10% |
| Integration | Full flows | 15-25 | 5% |

**Total recommended:** 150-200 tests

---

## Suggested Testing Roadmap

### Phase 1 (Week 1): Easy Wins
- `ArticleSearchRepository` unit tests
- `EmptyState`, `OfflineBanner` widget tests
- `QuizOption` enum tests
- Progress calculation logic

### Phase 2 (Week 2): Medium Complexity
- `StreakNotifier` unit tests (mock DB)
- `QuizNotifier` unit tests (mock DB, inject clock)
- `ArticleRepository` with DB mock

### Phase 3 (Week 3): Hard Cases
- Extract time provider, then test `SpacedRepetitionService`
- Test `ExamSessionNotifier` with controlled Random
- Auth flow integration tests

### Phase 4 (Week 4): Integration
- Full app flows with mock Supabase
- Offline/online transitions
- Subscription check + renewal flows

---

## Final Verdict

**Rating: Poor**

The codebase is **difficult to test** (62/100). Main barriers:

1. **Static singletons** — `Supabase.instance`, `FlutterSecureStorage` cannot be mocked
2. **Time dependencies** — `DateTime.now()` everywhere prevents deterministic tests
3. **SharedPreferences** scattered across widgets and services
4. **No repository interfaces** — tight coupling to implementations

**Refactoring needed before effective testing:**
1. Extract `Clock` abstraction for `DateTime.now()`
2. Create `SupabaseClient` interface
3. Create `PreferencesStorage` abstraction
4. Inject `Random` for exam session

The Riverpod architecture helps significantly — providers can be overridden. But the singleton dependencies at construction time prevent effective mocking. Without these abstractions, tests will require substantial integration setup with real services.