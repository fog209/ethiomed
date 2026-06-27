# WardReady — PROJECT_EVOLUTION_AUDIT.md

## Executive Summary

This repository shows evidence of **6 distinct evolutionary phases** spanning approximately 2-3 years of development. The codebase evolved from a simple article viewer to a full offline-first medical education platform with subscription gating, SM-2 spaced repetition, and admin controls.

**Evolution Score: 78/100**

The architecture largely holds together despite accumulated technical debt. Key strengths include consistent offline patterns, unified error handling, and Riverpod state management. Critical weaknesses include duplicate search screens, orphaned database tables, and hardcoded configuration.

---

## Repository Evolution Timeline

Based on evidence from file structure, naming patterns, and migration artifacts:

### Phase 1: Initial MVP (Earliest)
**Evidence:** `disclaimer_screen.dart`, hard-coded colors, simple navigation
- Basic article display with offline cache
- Simple disclaimer flow
- No authentication (later grafted on)
- Colors hardcoded as `_navy = Color(0xFF1A237E)` throughout

### Phase 2: Authentication + Supabase Integration
**Evidence:** `auth_service.dart`, `app_config.dart`, migration step 1-2 in `app_database.dart`
- Added user accounts and sign-up flow
- Supabase integration for remote articles
- `session_timeout_provider.dart` added for security

### Phase 3: Quiz System
**Evidence:** `quiz_repository.dart`, `quiz_notifier.dart`, migration step 3-5 in `app_database.dart`
- Initial quiz questions table created (migration step 3)
- Later dropped and replaced with SM-2 enabled table (migration step 4)
- Added `srInterval`, `repetitions`, `nextDueAt`, `easeFactor` columns

### Phase 4: Subscription + Admin
**Evidence:** `subscription_repository.dart`, `admin_repository.dart`, `paywall_screen.dart`
- Premium subscription gating added
- Admin dashboard for user activation
- Subscription status tracking in Supabase

### Phase 5: Search + FTS5
**Evidence:** `article_search_provider.dart`, search screens
- Full-text search added via FTS5 virtual table
- Search history via SharedPreferences
- **Evidence of duplicate creation:** `search_screen.dart` vs `article_search_screen.dart`

### Phase 6: SM-2 Spaced Repetition + Notifications
**Evidence:** `spaced_repetition_service.dart`, `notification_service.dart`, `weakness_service.dart`
- SM-2 algorithm implementation
- Daily notification scheduling
- Weakness tracking (Learning Radar)
- Category progress bars

### Phase 7: Recent Additions
**Evidence:** `progress_screen.dart` (study heatmap), `onboarding_screen.dart`, `terms_screen.dart`, `privacy_screen.dart`
- 5th tab: Progress dashboard with heatmap
- Onboarding flow added late ("v3" key for search history)

---

## Legacy Components

### Database Tables

| Table | Status | Evidence |
|-------|--------|----------|
| `QuizQuestions` | **ORPHANED** | Defined in `app_database.dart:50-63` but never used. Active table is `QuizTable` (lines 67-89) |
| Migration step 3 | **OBVIOUS** | Creates old quiz table, immediately dropped in step 4 |
| `study_sessions` columns | **LEGACY** | `session_date` column (line 230) kept for backward compatibility but superseded by `date` |

### Providers

| Provider | Status | Evidence |
|----------|--------|----------|
| `selectedCategoryProvider` | **DUPLICATE** | Defined in `search_screen.dart:9` but unused; search handled by `articleSearchControllerProvider` |
| `fsrs` package | **UNUSED** | Declared in pubspec.yaml but never imported |
| `google_fonts` | **UNUSED** | Declared in pubspec.yaml but never imported |

### Code Structure

| Artifact | Status | Evidence |
|----------|--------|----------|
| `lib/features/search/` folder | **DUPLICATE** | Contains full `search_screen.dart` duplicate of `article_search_screen.dart` in `articles/presentation/` |
| `lib/features/quiz/data/quiz_sync_service.dart` | **REDUNDANT** | Single-line re-export of `../quiz_sync_service.dart` |
| `ArticleContent` class | **UNUSED** | `article_model.dart` defines content model but only used internally, never imported elsewhere |

### Naming Inconsistencies

| Pattern | Evidence |
|---------|----------|
| Project name confusion | `disclaimer_screen.dart` says "WardReady" but `signup_screen.dart:73` says "EthioMed" — brand renamed mid-project |
| Old search system | `search_screen.dart` implements different search than `article_search_screen.dart` |
| Legacy search key | `search_history_service.dart:8` uses key `'wardready_v3'` indicating previous versions v1 and v2 existed |

---

## Migration Artifacts

### Incomplete Schema Migration

| File | Evidence | Risk |
|------|----------|------|
| `app_database.dart:92` | `QuizQuestions` still in `@DriftDatabase(tables: [...])` despite being unused | Storage waste, maintenance confusion |

### Duplicate Implementations

| Old | New | Artifact |
|-----|-----|----------|
| Simple quiz table | SM-2 quiz table with ease/due tracking | Migration step 4 drops old, creates new |
| `article_search_screen.dart` | `search_screen.dart` | **Confusion** — both implement full search UI |
| Hardcoded colors | Theme-based colors | Color constants still hardcoded in many files |

### Legacy Settings

| Artifact | Evidence |
|----------|----------|
| Session timeout in UI | `session_timeout_provider.dart` listens to auth stream changes in UI layer instead of background service |
| Sync notifications | `sync_state_provider.dart` implements state machine for rate limiting but `connectivity_notifier.dart` has parallel connectivity tracking |

---

## Architecture Drift

### Repository Pattern Evolution

**Early pattern** (article_repository.dart):
- Direct Supabase calls with inline error handling
- Callback-based event notification (`onServerUnreachable`, `onRateLimited`, etc.)

**Current pattern** (quiz_repository.dart):
- Same callback-based notification
- Identical error handling structure
- Both use raw SQL alongside Drift ORM

**Assessment:** Repository pattern is **consistent across features**, not drifted. Good.

### Provider Pattern Evolution

**Early pattern** (simple state):
```dart
final someProvider = StateProvider<int>((ref) => 0);
```

**Current pattern** (family + autoDispose):
```dart
StateNotifierProvider.autoDispose<ArticleSearchController, ArticleSearchState>
StateNotifierProvider.family<QuizNotifier, List<QuizTableData>, String>
```

**Evidence of drift:**
- Pagination providers (lines 12-20 in `article_list_screen.dart`) missed `autoDispose` while search got it
- Inconsistent use of `autoDispose` across similar state

### Naming Convention Drift

| Feature | Style |
|---------|-------|
| Quiz | `QuizNotifier`, `QuizOption`, `QuizScreen` |
| Articles | `ArticleRepository`, `ArticleLocal`, `ArticleSearchRepository` |
| Admin | `AdminRepository`, `AdminUser`, `AdminDashboardScreen` |
| Subscription | `SubscriptionRepository`, `isSubscribedProvider` |

**Assessment:** Naming conventions are **consistent**.

### Database Access Evolution

**Early:** Raw SQL in repository methods
**Now:** Mix of Drift ORM and raw SQL

**Drift:**
```dart
// Good: Drift query
_db.select(_db.articles)..where((table) => table.category.equals(category))

// Legacy: Raw SQL still dominant
customSelect("SELECT * FROM quiz_table WHERE category = ?...")
```

**Assessment:** **Partial drift** — Drift ORM was adopted but raw SQL remains for complex queries and FTS5.

---

## Technical Debt Timeline

### Early Technical Debt (Phase 1-2)

| Debt | File | Likely Reason |
|------|------|---------------|
| Hardcoded colors | Multiple screens | Pre-Material 3 theming |
| No autoDispose on early providers | `article_list_screen.dart` | autoDispose pattern adopted later |
| `String.fromEnvironment` for secrets | `env.dart` | Quick setup before secure config |

### Middle Technical Debt (Phase 3-4)

| Debt | File | Likely Reason |
|------|------|---------------|
| Orphaned `QuizQuestions` table | `app_database.dart:50-63` | Migration incomplete — table not removed from annotation |
| Search duplication | `search_screen.dart` vs `article_search_screen.dart` | Search feature added to wrong folder first, then duplicated |
| QuizSyncService wrapper | `lib/features/quiz/quiz_sync_service.dart` | Attempted abstraction but redundant |

### Late Technical Debt (Phase 5-7)

| Debt | File | Likely Reason |
|------|------|---------------|
| Unused `fsrs` package | `pubspec.yaml` | Attempted integration but kept SM-2 instead |
| Unused `google_fonts` | `pubspec.yaml` | Added for theming but not used |
| Auth `initialize()` never called | `auth_service.dart:129-139` | Missed integration during session timeout work |
| Missing Android 13+ notification permission | `notification_service.dart:111-115` | Added target but not runtime permission flow |

---

## Refactoring Roadmap

### Small Refactors (Hours)

| Priority | Refactors | Risk | Benefit |
|----------|-----------|------|---------|
| HIGH | Remove `QuizQuestions` table from schema | Low | Storage savings, schema clarity |
| HIGH | Delete `search_screen.dart` and `search/` folder | Low | Reduced confusion |
| HIGH | Delete `lib/features/quiz/data/quiz_sync_service.dart` | Low | Reduced confusion |
| HIGH | Delete `article_model.dart` (`ArticleContent` class) | Low | Reduced dead code |
| MEDIUM | Add `autoDispose` to pagination providers | Medium | Prevent stale state |
| MEDIUM | Call `AuthService.initialize()` in main() | Low | Session restore works |

### Medium Refactors (Days)

| Priority | Refactors | Risk | Benefit |
|----------|-----------|------|---------|
| HIGH | Consolidate search into single implementation | Medium | Single source of truth |
| HIGH | Move QuizNotifier service init to constructor | Medium | Better Riverpod pattern |
| MEDIUM | Extract shimmer widgets to shared components | Low | Code reuse |
| MEDIUM | Remove unused packages from pubspec.yaml | Low | Smaller APK |

### Large Refactors (Weeks)

| Priority | Refactors | Risk | Benefit |
|----------|-----------|------|---------|
| LOW | Move raw SQL to Drift DAOs | High | Better type safety |
| LOW | Extract color constants to theme | Medium | Consistency |
| LOW | Consolidate duplicate timer logic | Medium | Simpler maintenance |

---

## Scalability Assessment

### What Scales Well

| Component | Evidence |
|-----------|----------|
| Riverpod state management | Consistent `AsyncNotifier` pattern across features |
| Pagination | Smooth ListView.builder with offset-based loading |
| Offline-first | All repos return cached data on network failure |
| Schema versioning | Drift migrations handle evolution cleanly |

### What Breaks First (100K users)

| Component | Evidence | Failure Mode |
|-----------|----------|--------------|
| Search FTS5 | `article_search_provider.dart:262-298` rebuilds entire FTS5 index on mismatch | Performance degrades with 20K+ articles |
| Category progress queries | `category_progress_provider.dart:100-108` sequential queries per category | 200+ categories = 200+ DB queries |
| Exam question selection | `exam_session_notifier.dart:128-208` 17 sequential queries | Network latency compounds for large datasets |
| Subscriber list in admin | `admin_repository.dart:54-63` loads all users at once | Memory pressure with thousands of users |

### What Needs Redesign

| Component | Reason |
|-----------|--------|
| `currentAdminProfileProvider` | Should cache and refresh on auth change, not refetch every build |
| Exam question selection | N+1 query pattern needs batching or denormalization |
| FTS5 index rebuild | Should be incremental, not full rebuild on mismatch |

---

## Maintainability Scorecard

| Category | Score (0-10) | Evidence |
|----------|--------------|----------|
| Architecture | 8 | Clean feature separation, consistent patterns |
| Testing | 6 | No test files found in lib/, tests likely in `test/` only |
| Offline Strategy | 9 | Excellent fallback-to-cache everywhere |
| State Management | 8 | Riverpod with good async patterns |
| Database Design | 6 | Mix of ORM and raw SQL, some schema artifacts |
| Dependency Management | 5 | Unused packages, locked stack |
| Feature Modularity | 7 | Good separation but cross-feature coupling in sync |
| Security | 6 | Secure storage for tokens, no FLAG_SECURE |
| Release Readiness | 7 | Passes analyze, but missing Android 13 permission flow |
| Documentation | 4 | No inline docs, README likely minimal |

---

## Five-Year Outlook

### Assumptions
- 100,000 users
- 100 categories
- 20,000 articles
- Thousands of quiz questions
- Multiple authors
- Subscription growth
- Offline sync expansion

### What Scales Well

| Component | Why |
|-----------|-----|
| Drift pagination | Limit/offset pattern scales |
| Riverpod providers | Scoped caching works at scale |
| Article content model | 10-field schema is complete |
| SM-2 algorithm | Stateless algorithm, scales infinitely |

### What Breaks First

| Component | Why | Fix |
|-----------|-----|-----|
| Admin dashboard | Loads all users at once | Paginate users, virtual scrolling |
| Search FTS5 rebuild | Full rebuild on mismatch | Incremental indexing |
| Category progress | Sequential per-category queries | Batch queries or materialized view |
| Quiz N+1 queries | Sequential category queries | Pre-computed weights or caching |

### What Needs Redesign

| Component | Why |
|-----------|-----|
| `main.dart` | Central routing + auth + error handling | Split into modular bootstrapping |
| Repository callbacks | Tight coupling to providers | Event bus or state-only returns |
| Notification scheduling | Single daily reminder | Per-category personalization |

### What Surprisingly Survives

| Component | Why |
|-----------|-----|
| `disclaimer_screen.dart` | Simple, focused, no dependencies | Works forever |
| `EmptyState` widget | Pure presentational, no logic | Perfect as-is |
| Session timeout pattern | Simple state machine | Scales to any user count |

---

## Final Verdict

**Repository Maturity: Production-Ready with Technical Debt**

The codebase demonstrates **evolutionary architecture** — features were added incrementally without major rewrites. The core patterns (offline-first, Riverpod, Drift) are sound and scalable. However, the price of evolution is:

1. **Redundant code** — duplicate search screens, re-export files
2. **Orphaned schema** — `QuizQuestions` table wasting storage
3. **Missed integration** — auth initialization, Android 13 permissions
4. **Unused dependencies** — fsrs and google_fonts packages

**Cleanup Priority:**
1. Remove unused code (highest ROI, lowest risk)
2. Fix session restoration (user impact)
3. Address performance bottlenecks (scale preparation)

The project is in better shape than most repositories of similar age. The offline-first discipline and consistent error handling patterns will serve it well through the next phase of growth.