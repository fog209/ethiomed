# WardReady — DECISION_LOG.md

## Engineering Decisions Log

---

## 1. Flutter Architecture — Feature-Per-Folder

**Decision:** Organize code by feature (`features/quiz/`, `features/articles/`, etc.) with shared core

**Current Implementation:**
```
lib/
├── app/           # Navigation, routing, providers
├── core/          # Shared: database, services, widgets, errors
└── features/      # One folder per feature with presentation/data
```

**Alternatives Considered:**
- Pure layer-based (`data/`, `domain/`, `presentation/` at top level)
- Entity-based organization

**Why This Approach:**
- Features can be developed in isolation
- Clear ownership boundaries
- Easy to locate related files

**Trade-offs:**
- Some cross-feature providers duplicated in core
- Repository pattern mixed with Riverpod callbacks

**Long-term Implications:**
- Scales well for team development
- Feature removal is straightforward

**Reconsider?** NO — Working well

---

## 2. Riverpod for State Management

**Decision:** Use Riverpod exclusively for state management, no setState in business logic

**Current Implementation:**
- StreamProvider, FutureProvider, StateNotifierProvider, AsyncNotifierProvider.family
- All repositories receive callbacks to update state providers

**Alternatives Considered:**
- Bloc/Cubit
- Provider + ChangeNotifier
- setState (rejected per project rules)

**Why This Approach:**
- Compile-time safety with code generators
- Easy testing with override
- Composable providers

**Trade-offs:**
- Learning curve for new developers
- Overly broad providers cause unnecessary rebuilds
- Repository owning state notification creates tight coupling

**Long-term Implications:**
- Good migration path to Riverpod 3.0
- Provider cycles need monitoring as app grows

**Reconsider?** NO — Appropriate for app scale

---

## 3. Repository Pattern

**Decision:** Each feature has a repository that depends on Supabase and Drift

**Current Implementation:**
- `ArticleRepository`, `QuizRepository`, `AdminRepository`, `SubscriptionRepository`
- Repositories receive VoidCallback for error states
- Throws exceptions for caller to handle

**Alternatives Considered:**
- Clean Architecture with use cases
- Direct service calls from UI

**Why This Approach:**
- Single source of truth per entity
- Easy to mock for tests
- Error handling centralization

**Trade-offs:**
- Repositories call provider callbacks (inversion of control)
- Side effects in constructor callbacks
- No repository interface abstraction

**Long-term Implications:**
- Repositories may become too large as features grow
- Consider splitting for very large features

**Reconsider?** MAYBE — Consider pure use cases to reduce coupling

---

## 4. Dependency Injection Strategy

**Decision:** Riverpod providers for DI, no external DI framework

**Current Implementation:**
```dart
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(
    supabase: Supabase.instance.client,
    database: ref.watch(databaseProvider),
    ...
  );
});
```

**Alternatives Considered:**
- GetIt
- Injectable (with get_it)

**Why This Approach:**
- No additional dependencies
- Compile-time safety
- Automatic disposal

**Trade-offs:**
- Providers with side effects in callbacks
- Harder to inject non-provider dependencies

**Long-term Implications:**
- Simple for current scale
- May need refactoring for complex test fixtures

**Reconsider?** NO — Working well

---

## 5. Drift + SQLite

**Decision:** Use Drift ORM with SQLite for offline storage

**Current Implementation:**
- Drift database with 5 tables (articles, bookmarks, study_sessions, quiz_table, quiz_questions)
- Raw SQL for migrations and FTS5
- Schema version 9 with migration steps

**Alternatives Considered:**
- Moor (Drift predecessor)
- floor (SQLite ORM)
- Hive (NoSQL)

**Why This Approach:**
- Type-safe queries
- Migration support
- FTS5 integration for search

**Trade-offs:**
- Generated code (.g.dart) adds complexity
- Some operations use raw SQL instead of Drift
- No built-in encryption (SQLCipher add-on needed)

**Long-term Implications:**
- Migrations become risky at higher versions
- Performance tuning requires SQL knowledge

**Reconsider?** NO — Appropriate choice

---

## 6. Supabase Backend

**Decision:** Supabase for Auth, PostgreSQL, and soon Storage

**Current Implementation:**
- Auth with email/password
- Tables: articles, questions, profiles, subscriptions
- RLS policies for access control (403 handling)

**Alternatives Considered:**
- Firebase Auth + Firestore
- Custom REST API
- Appwrite

**Why This Approach:**
- Single vendor for auth + DB
- Real-time subscriptions
- PostgreSQL familiar to team

**Trade-offs:**
- Vendor lock-in
- Some edge cases with PostgrestException handling
- No built-in pagination helpers

**Long-term Implications:**
- Easy to self-host if needed
- May outgrow for massive scale

**Reconsider?** NO — Working well

---

## 7. Offline-First Synchronization

**Decision:** Cache-first with fallback, sync on foreground

**Current Implementation:**
- On fetch error: return local cache (not throw)
- Sync triggered on empty DB or manual FAB tap
- No background sync when app minimized

**Alternatives Considered:**
- Always sync first, then cache
- Workmanager background sync

**Why This Approach:**
- Users can study offline indefinitely
- No network required for core functions
- Simple implementation

**Trade-offs:**
- Stale data possible
- No conflict resolution
- Users may not know they're offline

**Long-term Implications:**
- Add last-synced timestamp
- Consider periodic background sync

**Reconsider?** NO — Core value proposition

---

## 8. GoRouter Navigation

**Decision:** Declarative routing with GoRouter

**Current Implementation:**
- Route definitions in main.dart
- Redirect for admin check
- `state.extra` for article object passing

**Alternatives Considered:**
- AutoRoute
- Beamer
- Flutter's built-in Navigator 1.0

**Why This Approach:**
- URL-based navigation
- Built-in redirect support
- Deep linking potential

**Trade-offs:**
- Redirect awaits without loading state causes delay
- Extra passing is fragile (type safety)
- No built-in transition animations

**Long-term Implications:**
- Easy to add web support
- Consider typed routing for safety

**Reconsider?** NO — Working well

---

## 9. SM-2 Scheduling

**Decision:** SM-2 algorithm for spaced repetition

**Current Implementation:**
- Custom implementation in SpacedRepetitionService
- Algorithm LOCKED per AGENTS.md
- Quality ratings: 0-5 (Again, Hard, Good, Easy)
- Fields: easeFactor, srInterval, repetitions, nextDueAt

**Alternatives Considered:**
- FSRS (package installed but unused)
- Simple time-based (day 1, 3, 7, 14, etc.)

**Why This Approach:**
- Proven algorithm (Anki uses it)
- Understood by target audience
- Simple to implement

**Trade-offs:**
- FSRS potentially more accurate
- SM-2 may be too aggressive
- Algorithm locked (cannot tune)

**Long-term Implications:**
- Consider FSRS-Next for v2
- Research shows improvements available

**Reconsider?** YES — FSRS may be worth investigating for v2

---

## 10. Local Notifications

**Decision:** flutter_local_notifications for daily reminders

**Current Implementation:**
- 8:00 AM daily via `matchDateTimeComponents: DateTimeComponents.time`
- Notification for due cards count
- Permission request in initialize()

**Alternatives Considered:**
- Android Alarm Manager directly
- Awesome Notifications

**Why This Approach:**
- Cross-platform
- Timezone support
- Exact timing possible

**Trade-offs:**
- Permission flow incomplete for Android 13+
- No notification channels customization
- No rescheduling on reboot (uses system)

**Long-term Implications:**
- Add reboot receiver for rescheduling
- Custom time picker

**Reconsider?** NO — Appropriate for use case

---

## 11. SharedPreferences Usage

**Decision:** SharedPreferences for simple preferences only

**Current Implementation:**
- Theme mode
- Onboarding/disclaimer flags
- Search history
- Last sync timestamps

**Alternatives Considered:**
- Hive for everything
- SecureStorage for all local

**Why This Approach:**
- Simple key-value storage
- No encryption needed
- No dependencies beyond Flutter

**Trade-offs:**
- Not encrypted (search history in plain)
- No type safety
- Limited size

**Long-term Implications:**
- Move sensitive data to SecureStorage
- Consider Hive for structured local data

**Reconsider?** NO — Appropriate for current use

---

## 12. Theme Architecture

**Decision:** StateProvider with Material 3 dark theme default

**Current Implementation:**
- `themeModeProvider` (StateProvider<ThemeMode>)
- Dark theme in `app_theme.dart`
- Light theme = ThemeData.light() (default Flutter)
- Saved to SharedPreferences

**Alternatives Considered:**
- dynamic_color for Android 12+ extraction
- ThemeProvider package

**Why This Approach:**
- Simple implementation
- Navy/Gold colors per brand
- No additional dependencies

**Trade-offs:**
- Light theme not customized
- No system theme following
- No theme variants

**Long-term Implications:**
- Add dynamic color support
- Custom light theme

**Reconsider?** NO — Working well

---

## 13. Search Architecture (FTS5)

**Decision:** SQLite FTS5 virtual table for full-text search

**Current Implementation:**
- `article_search_fts` virtual table
- Content + title + category indexed
- Tokenizer: unicode61 with diacritics removal
- Rebuild on corruption detection

**Alternatives Considered:**
- Algolia
- Elasticsearch
- In-memory search

**Why This Approach:**
- Offline-first requirement
- No external service costs
- Fast for moderate datasets

**Trade-offs:**
- Rebuild loop blocks UI (all articles)
- No fuzzy matching options
- FTS5 corruption requires manual rebuild

**Long-term Implications:**
- Add isolate for rebuild
- Consider FTS5 external tokenizer for Amharic

**Reconsider?** NO — Appropriate for offline-first

---

## 14. Database Schema Choices

**Decision:** Single quiz table with SM-2 columns, denormalized view history

**Current Implementation:**
- `quiz_table`: questions + scheduling fields
- `view_history`: article views denormalized
- `study_sessions`: daily aggregates

**Alternatives Considered:**
- Normalized: separate tables for questions, attempts, reviews
- JSONB for content

**Why This Approach:**
- Simple queries
- No joins for common operations
- Fast for mobile

**Trade-offs:**
- Redundancy in view_history
- No question history tracking
- Mixed Drift/raw SQL for same table

**Long-term Implications:**
- Denormalization may cause inconsistencies
- Consider proper relational structure for analytics

**Reconsider?** NO — Appropriate for mobile

---

## 15. Provider Organization

**Decision:** Feature providers co-located with feature, core providers in core/

**Current Implementation:**
- `lib/features/articles/article_providers.dart`
- `lib/core/providers/` for shared
- No provider registry

**Alternatives Considered:**
- All providers in one file
- Provider module per feature

**Why This Approach:**
- Easy to find related providers
- No circular imports
- Feature isolation

**Trade-offs:**
- Some providers duplicated across features
- No central provider oversight

**Long-term Implications:**
- Consider provider linting rules
- Extract shared patterns

**Reconsider?** NO — Working well

---

## 16. Error Handling Strategy

**Decision:** AppException for known errors, PostgrestException for backend

**Current Implementation:**
- `AppException`, `DiskFullException`, `SupabaseSessionExpiredException`, `SearchUnavailableException`
- Repository catches and throws/rethrows
- UI shows error states

**Alternatives Considered:**
- Result/Either pattern
- Exception-free architecture

**Why This Approach:**
- Simple for Flutter
- Error types extensible
- UI handles loading/error/data

**Trade-offs:**
- Some errors caught and logged but not surfaced
- Inconsistent error handling in settings

**Long-term Implications:**
- Consider sealed classes for error types
- Better error boundaries

**Reconsider?** NO — Adequate

---

## 17. Authentication Architecture

**Decision:** Supabase auth with secure storage for tokens

**Current Implementation:**
- Email/password sign in/up
- Access + refresh tokens in FlutterSecureStorage
- Session stream in authSessionProvider
- 30-minute idle timeout

**Alternatives Considered:**
- OAuth with Google/Apple sign-in
- Biometric auth
- JWT decode for UI hints

**Why This Approach:**
- Simple for MVP
- Secure storage prevents extraction
- Timeout for security

**Trade-offs:**
- No password recovery
- No biometric quick auth
- Session restore not implemented

**Long-term Implications:**
- Add biometric for returning users
- Social auth for easier onboarding

**Reconsider?** NO — Working well

---

## 18. Subscription Architecture

**Decision:** Admin-controlled subscriptions with grace period

**Current Implementation:**
- `SubscriptionRepository.checkSubscriptionStatus()`
- Admin users bypass payment check
- 30-day grace period offline
- Grace stored in SecureStorage

**Alternatives Considered:**
- In-app purchases
- Stripe integration
- Manual admin activation only

**Why This Approach:**
- Ethiopian payment methods (Telebirr) via manual
- Admin can verify students
- Grace for offline users

**Trade-offs:**
- No automated payments
- Manual process for admin
- Could be abused (admin always subscribed)

**Long-term Implications:**
- Add stripe_payment for international
- Automated admin approval workflow

**Reconsider?** NO — Appropriate for Ethiopian market

---

## 19. Admin Architecture

**Decision:** Simple admin dashboard with user list

**Current Implementation:**
- `/admin` route with redirect
- List all users with subscriptions
- Activate button for manual approval

**Alternatives Considered:**
- Role-based with permissions
- Admin UI library
- Pagination from start

**Why This Approach:**
- Simple for small user base
- Easy to understand
- Manual oversight

**Trade-offs:**
- Unpaginated user list
- No audit logs
- No bulk actions

**Long-term Implications:**
- Pagination required
- Stats dashboard
- Export functionality

**Reconsider?** NO — Scale issue only

---

## 20. Folder Organization

**Decision:** Top-level `core/`, `features/`, `app/` with feature subfolders

**Current Implementation:**
- core/: database, services, providers, widgets, errors
- features/: one folder per feature with presentation/data
- app/: navigation and shell

**Alternatives Considered:**
- Domain-driven structure
- State management separation

**Why This Approach:**
- Clear separation
- Easy to navigate
- Standard Flutter pattern

**Trade-offs:**
- Some folder names inconsistent
- quiz/data/quiz_sync_service.dart duplicates features/quiz/quiz_sync_service.dart

**Long-term Implications:**
- Remove duplicate file
- Consider feature-first for larger team

**Reconsider?** NO — Working well

---

## 21. Background Synchronization

**Decision:** Manual sync on FAB tap, auto-sync on empty DB

**Current Implementation:**
- CategoriesScreen FAB triggers sync
- Auto-sync if local DB empty on first launch
- No background sync

**Alternatives Considered:**
- Periodic background sync
- Workmanager
- Sync on app resume

**Why This Approach:**
- Data is static (medical articles)
- No real-time requirements
- Battery efficiency

**Trade-offs:**
- Users may have stale data
- No network awareness
- Manual action required

**Long-term Implications:**
- Add periodic sync for questions
- Sync on app resume

**Reconsider?** NO — Appropriate for content

---

## 22. Performance Decisions

**Decision:** IndexedStack for tabs, Paged queries for articles

**Current Implementation:**
- IndexedStack with 6 children preserves state
- Page size 20 for articles
- Shimmer loading states
- RepaintBoundary for heatmap

**Alternatives Considered:**
- AutomaticKeepAlive
- Separate page routes

**Why This Approach:**
- Fast tab switching
- Memory efficient
- Smooth UX

**Trade-offs:**
- All 6 screens loaded at once
- Exam mode loads 200 questions in memory

**Long-term Implications:**
- Consider lazy loading tabs
- Exam needs paging

**Reconsider?** MAYBE — Exam mode needs attention

---

## 23. Security Decisions

**Decision:** SecureStorage for tokens, FLAG_SECURE missing, default backup

**Current Implementation:**
- Auth tokens in FlutterSecureStorage
- No FLAG_SECURE
- allowBackup not set (default true)
- Database unencrypted

**Alternatives Considered:**
- SQLCipher
- EncryptedSharedPreferences
- FLAG_SECURE from start

**Why This Approach:**
- Tokens most sensitive
- Database is educational content
- MVP simplicity

**Trade-offs:**
- Screenshots allowed
- DB readable on rooted devices
- Cloud backup of local data

**Long-term Implications:**
- Add FLAG_SECURE before release
- Consider database encryption

**Reconsider?** YES — FLAG_SECURE and allowBackup must be fixed before release

---

## 24. Release Strategy

**Decision:** Manual signing via key.properties, no CI configured

**Current Implementation:**
- `android/app/build.gradle.kts:10-14` reads key.properties
- No template in repo
- Version: 1.0.0+1

**Alternatives Considered:**
- GitHub Actions signing
- Fastlane
- Play App Signing only

**Why This Approach:**
- Manual control for early releases
- No CI required yet

**Trade-offs:**
- Can't release from CI
- Key management manual
- No automated builds

**Long-term Implications:**
- Add CI/CD pipeline
- Versioned releases

**Reconsider?** NO — Planned for v2

---

# Decisions to Revisit

## 1. FSRS vs SM-2

**Current:** SM-2 used exclusively

**Evidence:** `pubspec.yaml:18` has `fsrs: ^2.0.0` installed but unused

**Reconsider:** YES — Research shows FSRS more accurate; evaluate for v2

## 2. env.dart Strategy

**Current:** String.fromEnvironment for Supabase keys with empty defaults

**Evidence:** Lines 2-8 in env.dart; no validation in main.dart

**Reconsider:** YES — Move to SecureStorage or fail loudly in release mode

## 3. Quiz Table Duplication

**Current:** `QuizQuestions` table declared but unused, data goes to `quiz_table`

**Evidence:** `app_database.dart:51-63,92` vs migration 4 dropping old table

**Reconsider:** YES — Remove unused table from schema

## 4. Sync Architecture

**Current:** Repository callbacks to providers for sync state

**Evidence:** `article_repository.dart:238-250` callbacks updating providers

**Reconsider:** MAYBE — Consider event bus or result pattern for cleaner separation

## 5. Provider Ownership

**Current:** Repositories directly call provider methods

**Evidence:** All repository providers call `syncStateProvider.notifier.method()`

**Reconsider:** YES — Consider one-way data flow; repositories shouldn't know about providers

## 6. Repository Boundaries

**Current:** Progress queries done in notifier, not repository

**Evidence:** `progress_notifier.dart` has direct Drift calls

**Reconsider:** YES — Consistent pattern would use ProgressRepository

## 7. Notification Architecture

**Current:** Permission requested only during scheduling

**Evidence:** `notification_service.dart:115` inside initialize()

**Reconsider:** YES — Must request permission before enabling toggle for Android 13+

## 8. Search Architecture

**Current:** FTS5 rebuild loop blocks main thread

**Evidence:** `article_search_provider.dart:279-298` loops all articles synchronously

**Reconsider:** YES — Move to background isolate for large datasets