# CODEBASE AUDIT — WardReady (EthioMed)

**Date:** 2026-06-22  
**Auditor:** AI Agent (READ-ONLY pass)  
**Commit:** fcb703eaa66dc47bfd0d485956754f22ac1cc034  

All 49 Dart source files in `lib/` were read in full. Generated files (`*.g.dart`) were not modified or analyzed for violations. No code changes were made.

---

## SECTION 1 — ARCHITECTURE VIOLATIONS

### 1. setState() inside a business logic class (not a Widget/State)

**None found.** All `setState()` calls occur inside `State`/`ConsumerState` subclasses.

### 2. Direct SQLite usage not going through Drift

| FILE | LINE | VIOLATION | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/core/database/app_database.dart` | 221–228 | Raw `CREATE TABLE IF NOT EXISTS study_sessions` via `customStatement()` instead of a Drift table definition | **HIGH** | Define `StudySessions` as a proper Drift table with all columns and use migration instead of raw SQL |
| `lib/core/database/app_database.dart` | 323–341 | Raw `CREATE TABLE IF NOT EXISTS view_history` and column additions via `customStatement()` instead of a Drift table | **HIGH** | Define a `ViewHistory` Drift table and add it to the database definition |
| `lib/features/quiz/weakness_service.dart` | 39–41 | Raw `ALTER TABLE quiz_table` via `customStatement()` to add `last_quality` column | **MEDIUM** | Add `last_quality` as a proper Drift column in QuizTable and run migration |
| `lib/database/app_database.dart` | 231–288 | Multiple raw `PRAGMA table_info`, `UPDATE`, `CREATE UNIQUE INDEX` statements that should be managed by Drift migrations | **MEDIUM** | Consolidate all study_sessions management into the Drift migration strategy |

### 3. print() instead of debugPrint()

**None found.** All files use `debugPrint()` or no print statements.

### 4. Hardcoded color not using Color(0xFF1A237E) or Color(0xFFF9A825)

| FILE | LINE | VIOLATION | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/features/articles/presentation/article_detail_screen.dart` | 18 | `const _wardReadyGold = Color(0xFFF9A825)` defined as local constant — should be shared from a theme or AppConfig | LOW | Extract shared color constants into a single `AppColors` class |
| `lib/features/articles/presentation/article_detail_screen.dart` | 307 | `Color(0xFFE8EAF6)`, `Color(0xFF1A237E)` — 16 hardcoded section colors repeated per-section | LOW | These are section-specific design colors but 16 hex codes inline is excessive; consider a centralized palette |
| `lib/features/articles/presentation/article_detail_screen.dart` | 349 | `Color(0xFFFFEBEE)`, `Color(0xFFD32F2F)` — red flag colors | LOW | Consider theme-based colors |
| `lib/features/quiz/quiz_screen.dart` | 231 | `Color(0xFFD32F2F)` — SM-2 "Again" button red | LOW | Extract to shared constants |
| `lib/features/quiz/quiz_screen.dart` | 242 | `Color(0xFFF57C00)` — SM-2 "Hard" button orange | LOW | Extract to shared constants |
| `lib/features/presentation/admin_dashboard_screen.dart` | 59 | `Color(0xFF2E7D32)` — green for subscribed status | LOW | Extract to shared constants |

**Note:** Many hardcoded colors are legitimate design choices (theme-based section colors, status indicators). Only flagging those that are repeated across files without a shared constant.

### 5. http package usage instead of dio

**None found.** All HTTP goes through Supabase client or `dio`. The `http` package is not imported anywhere.

### 6. Supabase call missing PostgrestException catch

**None found.** Every Supabase call is wrapped with proper `PostgrestException` handling.

### 7. Navigator.push/pop that conflicts with GoRouter

**None found.** All navigation uses `context.go()`, `context.push()`, or `context.pop()` from GoRouter.

### 8. TODO or FIXME comment in production code

| FILE | LINE | VIOLATION | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/features/subscription/presentation/paywall_screen.dart` | 10 | `// CHANGE THIS TO YOUR REAL TELEBIRR NUMBER` | **MEDIUM** | Replace placeholder with the real Telebirr number or read from config; this is production code with a placeholder |
| `lib/features/subscription/presentation/paywall_screen.dart` | 11 | `static const String telegramAdmin = "https://t.me/WardReadyAdmin"` — URL hardcoded | LOW | Extract to AppConfig |

### 9. Magic numbers (hardcoded ints/doubles that should be constants)

| FILE | LINE | VIOLATION | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/features/home/presentation/categories_screen.dart` | 65 | `minHeight: 3` — LinearProgressIndicator height | LOW | Extract as const |
| `lib/features/home/presentation/categories_screen.dart` | 38 | `BorderRadius.circular(15)` — repeated in GridView cards | LOW | Extract as const |
| `lib/features/quiz/quiz_screen.dart` | 431 | `borderWidth: 2` in option button | LOW | Extract as const |
| `lib/core/providers/sync_state_provider.dart` | 81, 94 | `Duration(seconds: 30)` and `Duration(seconds: 60)` — rate limit timers | LOW | These are reasonable but could be named constants |

### 10. ref.read() or ref.watch() inside dispose()

**None found.** All `dispose()` overrides only cancel timers and call `super.dispose()`.

### 11. context used after await without context.mounted check

| FILE | LINE | VIOLATION | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/features/articles/presentation/article_detail_screen.dart` | 52–69 | `initState` calls `Future.microtask` then calls `ref.read(databaseProvider)` synchronously inside initState — `ref.read()` before the widget tree is built is risky | **MEDIUM** | Move database access to `build()` or use `ref.watch()` via a late field with `didChangeDependencies` |
| `lib/features/settings/presentation/settings_screen.dart` | 140–147 | After `await Share.share(...)`, accesses `context.mounted` but only uses it for early return — access to `box` before the await binds context that could become stale | LOW | The `if (!context.mounted) return` guard is present; safe |
| `lib/features/articles/presentation/article_list_screen.dart` | 248–327 | `_listenToPaginationChanges` receives `context` as parameter and uses it in listener callbacks that fire after async operations — several have `if (!mounted) return` guards | LOW | Guards are present but passing context to long-lived listeners is risky |

### 12. .when() call missing error: handler

**None found.** All `.when()` calls include `error:` handler.

### 13. ! null assertion on a value that could realistically be null

| FILE | LINE | CODE SNIPPET | SEVERITY | FIX |
|---|---|---|---|---|
| `lib/features/admin/data/admin_repository.dart` | 34 | `subsData.first as Map<String, dynamic>` — `as` cast on dynamic data from Supabase could throw if first element is not a Map | **HIGH** | Use `Map<String, dynamic>?` cast with `as?` and null check |
| `lib/features/admin/data/admin_repository.dart` | 35 | `subsData as Map<String, dynamic>` — same issue with dynamic Supabase response | **HIGH** | Use safe cast with `as?` |
| `lib/core/services/postgrest_status_helper.dart` | 12 | `match.group(0)!` — safe because regex already matched, but still a `!` | LOW | Use `match.group(0) ?? ''` for defensive safety |

---

## SECTION 2 — DEAD CODE

### Unused Files (entire files never imported)

| FILE | TYPE | NAME | NOTES |
|---|---|---|---|
| `lib/features/search/search_screen.dart` | Widget | `ArticleSearchScreen` | Duplicate search screen with simple string matching. Never imported by any other file. `MainShell` imports `features/articles/presentation/article_search_screen.dart` instead. |
| `lib/features/search/search_history_service.dart` | Notifier/Services | `SearchHistoryNotifier`, `searchHistoryProvider` | Only imported by the dead `search_screen.dart`. Not used anywhere else. |

### Unused Imports

| FILE | LINE | PACKAGE/FILE |
|---|---|---|
| `lib/features/articles/data/article_repository.dart` | 3 | `dart:io` — `SocketException` reference is via Supabase, `dart:io` not needed explicitly |
| `lib/features/articles/data/article_repository.dart` | 9 | `package:sqlite3/sqlite3.dart` — only used for `SqliteException` type catch; could be replaced with Drift's own exception type |
| `lib/features/quiz/quiz_repository.dart` | 8 | `package:sqlite3/sqlite3.dart` — same pattern; used only for `SqliteException` type check |
| `lib/features/search/search_screen.dart` | 6 | `package:ethiomed/features/articles/data/article_repository.dart` — importing via absolute package path (should use relative) |

**Note:** The `ignore: depend_on_referenced_packages` comments on `sqlite3` imports indicate these were intentionally added, but they add unnecessary coupling.

### Unused Variables / Methods

| FILE | LINE | TYPE | NAME |
|---|---|---|---|
| `lib/features/quiz/quiz_notifier.dart` | 9 | typedef | `QuizTableData` — defined as alias for `QuizQuestionEntity` but never used as alias (`QuizQuestionEntity` used directly) |
| `lib/features/quiz/quiz_notifier.dart` | 137 | method param | `int quality` in `recordReview` — always called with `0` at line 124 |

### Potential Dead Code: Unused Fields

| FILE | FIELD | NOTES |
|---|---|---|
| `lib/core/database/app_database.dart` — `StudySessions` table | `articles_viewed_count` | Only column defined in Drift, but the raw SQL extension adds 5 more columns not in the Drift definition |

---

## SECTION 3 — DUPLICATE LOGIC

### Duplicate 1: `_isDiskFull` method

| ASPECT | DETAILS |
|---|---|
| **FILES** | `lib/features/articles/data/article_repository.dart` (lines 111–116), `lib/features/quiz/quiz_repository.dart` (lines 101–106) |
| **DESCRIPTION** | Both files define an identical private method that checks if a `SqliteException` message contains "disk", "full", or "sqlite_full" |
| **RECOMMENDATION** | Extract to a utility function in `lib/core/services/` or as a static method on `DiskFullException` |

### Duplicate 2: `_countDueCardsForDate` / `countDueCardsForDate`

| ASPECT | DETAILS |
|---|---|
| **FILES** | `lib/core/services/notification_service.dart` (lines 198–219), `lib/features/quiz/spaced_repetition_service.dart` (lines 125–141) |
| **DESCRIPTION** | Both files define an identical method that counts quiz_table rows where `next_due_at IS NULL OR (next_due_at >= ? AND next_due_at < ?)` for a given date |
| **RECOMMENDATION** | Extract to a single method on `SpacedRepetitionService` (or a shared repository) and call it from `NotificationService` |

### Duplicate 3: `_dateKey` functionality

| ASPECT | DETAILS |
|---|---|
| **FILES** | `lib/core/database/app_database.dart` (lines 345–348), `lib/features/progress/streak_notifier.dart` (lines 119–122) |
| **DESCRIPTION** | Both define a method that takes a DateTime, zeros the time components, and returns ISO-8601 date substring (e.g., "2026-06-22") |
| **RECOMMENDATION** | Extract to a `DateUtils` extension method on `DateTime` in `lib/core/utils/` |

### Duplicate 4: FTS5 Search Index management

| ASPECT | DETAILS |
|---|---|
| **FILE** | `lib/features/articles/data/article_search_provider.dart` — `_rebuildSearchIndex()`, `_ensureSearchIndex()`, `_getIndexedCount()` |
| **DESCRIPTION** | The entire FTS5 virtual table management (create, rebuild, count) only exists in one file — but is ~100 lines of complex logic that would be duplicated if any other feature needed FTS5 |
| **RECOMMENDATION** | Extract FTS5 index management into a dedicated `Fts5Service` or `SearchIndexService` |

### Duplicate 5: `subcategoryFilterProvider` redefinition

| ASPECT | DETAILS |
|---|---|
| **FILES** | `lib/features/articles/article_providers.dart` (line 5), `lib/features/home/presentation/article_list_screen.dart` (line 20) |
| **DESCRIPTION** | BOTH files define `final subcategoryFilterProvider = StateProvider<String?>((ref) => null)`. The one in `article_list_screen.dart` shadows the import from `article_providers.dart`. They should be the SAME provider to share state across screens. |
| **SEVERITY** | **HIGH — This is a runtime bug.** The `article_list_screen.dart` version and the `article_providers.dart` version are separate pieces of state. Filter changes in one won't reflect in the other. |

### Duplicate 6: Supabase SupabaseClient acquisition pattern

| ASPECT | DETAILS |
|---|---|
| **FILES** | `admin_repository.dart`, `article_repository.dart`, `quiz_repository.dart`, `subscription_repository.dart`, `auth_service.dart` |
| **DESCRIPTION** | Every repository calls `Supabase.instance.client` to get the client. The pattern is identical across 5+ files. |
| **RECOMMENDATION** | Create a single `supabaseClientProvider` using Riverpod to centralize access |

---

## SECTION 4 — INCONSISTENT ERROR HANDLING

| FILE | METHOD | ISSUE |
|---|---|---|
| `lib/features/quiz/quiz_sync_service.dart` | `syncQuestions()` | Catches `SocketException` and `DioException` but silently absorbs them (logs "Offline: serving from local cache" but DOES NOT rethrow). The caller (`quiz_notifier.dart` line 156) expects errors to propagate — silent catch means the UI may show stale data without indication. |
| `lib/features/quiz/spaced_repetition_service.dart` | `recordReview()` | Lines 104–112: Catches notification scheduling error with `debugPrint` but continues execution. This is acceptable since notification failure shouldn't break the review. Consistency: OK. |
| `lib/features/articles/presentation/article_detail_screen.dart` | `_recordViewHistory()` | Line 92: Catches all errors with `debugPrint` only — no user feedback. Other screens show SnackBars on errors. Inconsistent. |
| `lib/core/database/app_database.dart` | `_runMigrationStep()` | Catches exception, logs it, sets a global `MigrationErrorStore`. No user-facing feedback until Settings screen reads `MigrationErrorStore.value`. If migration fails silently, data may be in a partially migrated state. |
| `lib/features/articles/data/article_search_provider.dart` | `_ensureSearchIndex()` | Line 299: Catches error, logs it, then `rethrow`. The caller `_searchWithMatch` doesn't catch it — the `catch` in `_runSearch` handles it generically. The `SearchUnavailableException` is only used for FTS5 corruption, not failures. |
| `lib/features/quiz/quiz_notifier.dart` | `_loadLocalQuestions()` | Sets `state = AsyncError(error, stackTrace)` on error and rethrows. The QuizScreen shows "Unable to load quiz questions." But no retry button is shown on the error state — the user must manually trigger sync. |
| `lib/features/quiz/quiz_notifier.dart` | `loadNextPage()` in `article_list_screen.dart` (line 452) | Error caught, logs "Unable to load article page: $error", sets error state. But the UI in `article_list_screen.dart` only shows the error if `loadedArticles.isEmpty` — otherwise it silently shows stale data with no indicator. |

---

## SECTION 5 — NULL SAFETY RISKS

| FILE | LINE | CODE SNIPPET | RISK |
|---|---|---|---|
| `lib/features/admin/data/admin_repository.dart` | 34 | `subsData.first as Map<String, dynamic>` | `subsData` is `dynamic` from Supabase JSON. If `first` is not a `Map`, throws `_CastError` at runtime. |
| `lib/features/admin/data/admin_repository.dart` | 35 | `subsData as Map<String, dynamic>` | Same risk — `subsData` could be any type from Supabase response. |
| `lib/features/articles/domain/models/article.dart` | 21 | `json['title'] as String?` | Safe because `as String?` returns null if not a string. |
| `lib/core/services/postgrest_status_helper.dart` | 12 | `match.group(0)!` | Safe because regex already matched, but `!` is unnecessary — `match.group(0) ?? ''` would be safer. |
| `lib/features/admin/presentation/admin_dashboard_screen.dart` | 120–121 | `Colors.grey[300]!`, `Colors.grey[100]!` | Safe — these indices are always present in the Material `Colors.grey` swatch. |
| `lib/features/articles/presentation/article_detail_screen.dart` | 246–247 | `Colors.grey[300]!`, `Colors.grey[100]!` | Same pattern — safe. |
| `lib/features/quiz/quiz_repository.dart` | 82 | `e.response?.statusCode == 503` | Safe — `?.` handles null, `==` comparison works with null. |

---

## SECTION 6 — CURRENT STATE SNAPSHOT

### SCREENS (Route Path → Widget)

| Route Path | Widget | File |
|---|---|---|
| `/` | `AppEntrance` → `DisclaimerGate` → `LoginScreen` or `SubscriptionGuard` → `MainShell` or `PaywallScreen` | `lib/main.dart` |
| `/login` | `LoginScreen` | `lib/features/auth/presentation/login_screen.dart` |
| `/signup` | `SignupScreen` | `lib/features/auth/presentation/signup_screen.dart` |
| `/home` | `AppEntrance` (same as `/`) | `lib/main.dart` |
| `/article-list/:category` | `ArticleListScreen` | `lib/features/home/presentation/article_list_screen.dart` |
| `/article-detail` | `ArticleDetailScreen` | `lib/features/articles/presentation/article_detail_screen.dart` |
| `/admin` | `AdminDashboardScreen` | `lib/features/admin/presentation/admin_dashboard_screen.dart` |
| (Bottom Nav Tab 0) | `CategoriesScreen` | `lib/features/home/presentation/categories_screen.dart` |
| (Bottom Nav Tab 1) | `ArticleSearchScreen` (FTS5) | `lib/features/articles/presentation/article_search_screen.dart` |
| (Bottom Nav Tab 2) | `BookmarksScreen` | `lib/features/bookmarks/presentation/bookmarks_screen.dart` |
| (Bottom Nav Tab 3) | `SettingsScreen` | `lib/features/settings/presentation/settings_screen.dart` |
| (Bottom Nav Tab 4) | `QuizScreen` | `lib/features/quiz/quiz_screen.dart` |

### DRIFT TABLES (Generated from `app_database.dart`)

#### `articles` (Data Class: `ArticleLocal`)
| Column | Type | Constraints |
|---|---|---|
| `id` | `TEXT` | PRIMARY KEY |
| `title` | `TEXT` | NOT NULL |
| `category` | `TEXT` | NULLABLE |
| `content` | `TEXT` | NULLABLE |
| `image_url` | `TEXT` | NULLABLE |
| `video_url` | `TEXT` | NULLABLE |
| `subcategory` | `TEXT` | NULLABLE |
| `is_high_yield` | `BOOLEAN` | DEFAULT false |

#### `bookmarks`
| Column | Type | Constraints |
|---|---|---|
| `id` | `INTEGER` | AUTOINCREMENT, PRIMARY KEY |
| `article_id` | `TEXT` | FK → articles.id |

#### `study_sessions` (Drift definition)
| Column | Type | Constraints |
|---|---|---|
| `date` | `DATETIME` | PRIMARY KEY |
| `articles_viewed_count` | `INTEGER` | DEFAULT 0 |

**Note:** Raw `customStatement` adds these extra columns at runtime: `session_date TEXT`, `articles_read INTEGER DEFAULT 0`, `quizzes_completed INTEGER DEFAULT 0`, `quiz_correct INTEGER DEFAULT 0`.

#### `quiz_questions` (Data Class: `QuizQuestionLocal`)
| Column | Type | Constraints |
|---|---|---|
| `id` | `INTEGER` | AUTOINCREMENT, PRIMARY KEY |
| `article_id` | `TEXT` | NULLABLE |
| `stem` | `TEXT` | NOT NULL |
| `option_a` | `TEXT` | NOT NULL |
| `option_b` | `TEXT` | NOT NULL |
| `option_c` | `TEXT` | NOT NULL |
| `option_d` | `TEXT` | NOT NULL |
| `correct_option` | `TEXT` | len(1) |
| `explanation` | `TEXT` | NULLABLE |
| `category` | `TEXT` | NULLABLE |
| `difficulty` | `TEXT` | NULLABLE |

#### `quiz_table` (Data Class: `QuizQuestionEntity`) — INDEX: `idx_quiz_table_category(category)`
| Column | Type | Constraints |
|---|---|---|
| `id` | `INTEGER` | AUTOINCREMENT, PRIMARY KEY |
| `remote_id` | `TEXT` | UNIQUE |
| `article_id` | `TEXT` | NOT NULL |
| `stem` | `TEXT` | NOT NULL |
| `option_a` | `TEXT` | NOT NULL |
| `option_b` | `TEXT` | NOT NULL |
| `option_c` | `TEXT` | NOT NULL |
| `option_d` | `TEXT` | NOT NULL |
| `correct_option` | `TEXT` | len(1) |
| `explanation` | `TEXT` | NOT NULL |
| `category` | `TEXT` | NOT NULL |
| `difficulty` | `TEXT` | DEFAULT 'medium' |
| `tested_field` | `TEXT` | DEFAULT 'clinicalFeatures' |
| `wrong_count` | `INTEGER` | DEFAULT 0 |
| `last_attempted_at` | `DATETIME` | NULLABLE |
| `sr_interval` | `INTEGER` | NULLABLE |
| `repetitions` | `INTEGER` | NULLABLE |
| `next_due_at` | `DATETIME` | NULLABLE |

**Note:** Raw `customStatement` adds `last_quality INTEGER` at runtime via `weakness_service.dart`.

### RAW SQL TABLES (Not defined in Drift)

| Table | Created By | Columns |
|---|---|---|
| `view_history` | `app_database.dart:_ensureViewHistoryTable()` | `id INTEGER PK AUTOINCREMENT`, `article_id TEXT NOT NULL`, `article_title TEXT?`, `category TEXT?`, `viewed_at TEXT NOT NULL DEFAULT ''` |
| `article_search_fts` | `article_search_provider.dart:_ensureSearchIndex()` | FTS5 virtual table: `article_id UNINDEXED`, `title`, `content`, `category` |

### RIVERPOD PROVIDERS (Complete List)

| Provider Name | Type | Provides | File |
|---|---|---|---|
| `databaseProvider` | `Provider<AppDatabase>` | Database instance | `app_database.dart` |
| `migrationErrorProvider` | `StateProvider<String?>` | Migration error string | `app_database.dart` |
| `connectivityProvider` | `StateNotifierProvider<ConnectivityNotifier, bool>` | Online/offline status | `connectivity_notifier.dart` |
| `syncStateProvider` | `StateNotifierProvider<SyncStateNotifier, SyncState>` | Sync state flags | `sync_state_provider.dart` |
| `bottomNavIndexProvider` | `StateProvider<int>` | Bottom nav tab index | `nav_provider.dart` |
| `notificationServiceProvider` | `Provider<NotificationService>` | Notification service | `notification_service.dart` |
| `dailyStudyRemindersEnabledProvider` | `StateNotifierProvider<NotificationReminderNotifier, bool>` | Reminders toggle | `notification_service.dart` |
| `highYieldModeProvider` | `StateProvider<bool>` | High-yield toggle | `article_providers.dart` |
| `subcategoryFilterProvider` | `StateProvider<String?>` | Subcategory filter | `article_providers.dart` AND `article_list_screen.dart` (DUPLICATE!) |
| `articleRepositoryProvider` | `Provider<ArticleRepository>` | Article repository | `article_repository.dart` |
| `allArticlesProvider` | `StreamProvider<List<ArticleLocal>>` | All local articles stream | `article_repository.dart` |
| `articlesProvider` | alias for `allArticlesProvider` | — | `article_repository.dart` |
| `paginatedArticlesProvider` | `StreamProvider.family<List<ArticleLocal>, ArticlePageQuery>` | Paginated articles stream | `article_repository.dart` |
| `articlesCountInCategoryProvider` | `FutureProvider.family<int, String>` | Article count per category | `article_repository.dart` |
| `articlesCountInCategoryAndSubcategoryProvider` | `FutureProvider.family<int, ArticleCountQuery>` | Article count per category+subcategory | `article_repository.dart` |
| `articleListControllerProvider` | `StateNotifierProvider<ArticleListController, ArticleListState>` | Pagination state controller | `article_repository.dart` |
| `articleSearchRepositoryProvider` | `Provider<ArticleSearchRepository>` | Search repository | `article_search_provider.dart` |
| `articleSearchControllerProvider` | `StateNotifierProvider.autoDispose<ArticleSearchController, ArticleSearchState>` | Search state | `article_search_provider.dart` |
| `authServiceProvider` | `Provider<AuthService>` | Auth service | `auth_service.dart` |
| `authSessionProvider` | `StreamProvider<Session?>` | Auth session stream | `auth_service.dart` |
| `authControllerProvider` | `StateNotifierProvider<AuthController, AuthUiState>` | Auth UI state | `auth_service.dart` |
| `adminRepositoryProvider` | `Provider<AdminRepository>` | Admin repo | `admin_repository.dart` |
| `adminUsersProvider` | `FutureProvider<List<AdminUser>>` | All users (admin) | `admin_repository.dart` |
| `currentAdminProfileProvider` | `FutureProvider<bool>` | Is current user admin? | `admin_repository.dart` |
| `quizRepositoryProvider` | `Provider<QuizRepository>` | Quiz repository | `quiz_repository.dart` |
| `quizNotifierProvider` | `AsyncNotifierProvider.family<QuizNotifier, List<QuizTableData>, String>` | Quiz questions by category | `quiz_notifier.dart` |
| `quizSyncServiceProvider` | `Provider<QuizSyncService>` | Quiz sync service | `quiz_sync_service.dart` |
| `spacedRepetitionServiceProvider` | `Provider<SpacedRepetitionService>` | SR service | `spaced_repetition_service.dart` |
| `weaknessServiceProvider` | `Provider<WeaknessService>` | Weakness tracking | `weakness_service.dart` |
| `weakFieldsProvider` | `FutureProvider.family<Set<String>, String>` | Weak fields by article ID | `weakness_service.dart` |
| `categoryProgressProvider` | `FutureProvider.family<CategoryProgress, String>` | Read/total per category | `category_progress_provider.dart` |
| `streakNotifierProvider` | `AsyncNotifierProvider<StreakNotifier, StudyStreakStats>` | Streak stats | `streak_notifier.dart` |
| `subscriptionRepositoryProvider` | `Provider<SubscriptionRepository>` | Subscription repo | `subscription_repository.dart` |
| `isSubscribedProvider` | `FutureProvider<bool>` | Subscription status | `subscription_repository.dart` |
| `searchHistoryProvider` | `StateNotifierProvider<SearchHistoryNotifier, List<String>>` | Search history (DEAD CODE) | `search_history_service.dart` |
| `articleOffsetProvider` | `StateProvider<int>` | Pagination offset | `article_list_screen.dart` |
| `articleRequestIdProvider` | `StateProvider<int>` | Pagination request ID | `article_list_screen.dart` |
| `articleLoadedArticlesProvider` | `StateProvider<List<ArticleLocal>>` | Loaded articles cache | `article_list_screen.dart` |
| `articleHasMoreProvider` | `StateProvider<bool>` | Has more pages? | `article_list_screen.dart` |
| `articleIsLoadingMoreProvider` | `StateProvider<bool>` | Is loading more? | `article_list_screen.dart` |
| `articleCurrentCategoryProvider` | `StateProvider<String?>` | Current category | `article_list_screen.dart` |

### FEATURES COMPLETENESS

#### ✅ Complete (working with all core functionality)
| Feature | Key File(s) |
|---|---|
| Auth (Login/Signup) | `lib/features/auth/data/auth_service.dart`, `login_screen.dart`, `signup_screen.dart` |
| Articles (view, search FTS5) | `lib/features/articles/presentation/article_detail_screen.dart`, `article_search_screen.dart`, `article_repository.dart` |
| Bookmarks | `lib/features/bookmarks/presentation/bookmarks_screen.dart` |
| Home / Categories | `lib/features/home/presentation/categories_screen.dart`, `article_list_screen.dart` |
| Quiz (SM-2 spaced repetition) | `lib/features/quiz/quiz_screen.dart`, `quiz_notifier.dart`, `quiz_repository.dart`, `spaced_repetition_service.dart` |
| Subscription/Paywall | `lib/features/subscription/presentation/paywall_screen.dart` |
| Admin Dashboard | `lib/features/admin/presentation/admin_dashboard_screen.dart` |
| Settings | `lib/features/settings/presentation/settings_screen.dart` |
| Notifications | `lib/core/services/notification_service.dart` |

#### ⚠️ Partial (has implementation but issues noted)
| Feature | Key File(s) | What's Missing / Issue |
|---|---|---|
| Search | `lib/features/articles/presentation/article_search_screen.dart` | Works with FTS5. But **dead duplicate** exists at `lib/features/search/search_screen.dart` with simple string filtering. |
| Progress / Streak | `lib/features/progress/streak_notifier.dart` | Works. But uses raw SQL on `study_sessions` table. Some fields like `accuracy` may be unreliable if Drift schema and raw SQL schema diverge. |
| Error Banners | `lib/core/widgets/error_banners.dart` | Has `showDiskFullBanner` but it's never called anywhere in the codebase. |

#### ❌ Not Started / Empty
| Feature | Notes |
|---|---|
| Chapa payment integration | Subscription is manual (TeleBirr → Telegram screenshot → Admin activates). No Chapa SDK calls anywhere. |

---

## SECTION 7 — SUMMARY

### VIOLATIONS FOUND

| Category | Count |
|---|---|
| Rule 2: Direct SQLite not through Drift | 4 violations (2 HIGH) |
| Rule 4: Hardcoded colors | 6 violations (all LOW) |
| Rule 8: TODO/placeholder in production | 1 violation (MEDIUM) |
| Rule 9: Magic numbers | 4 violations (all LOW) |
| Rule 11: context after await without mounted check | 3 violations (1 MEDIUM) |
| Rule 13: Unsafe `!` or `as` cast | 4 violations (2 HIGH) |
| **TOTAL ARCHITECTURE VIOLATIONS** | **22** |

| Severity | Count |
|---|---|
| **HIGH** | 4 |
| **MEDIUM** | 2 |
| **LOW** | 16 |

### OTHER FINDINGS

| Category | Count |
|---|---|
| Dead code files | 2 |
| Duplicate logic instances | 6 |
| Inconsistent error handling issues | 4 |
| Null safety risks | 4 |

### TOP 5 MOST URGENT FIXES (ranked by crash risk)

1. **`as` casts on dynamic Supabase data** (`admin_repository.dart:34-35`) — `_CastError` at runtime if Supabase returns unexpected data shape. **CRASH RISK: HIGH**
2. **`subcategoryFilterProvider` duplicate definition** (`article_providers.dart:5` vs `article_list_screen.dart:20`) — Two separate providers with the same name cause state fragmentation. Filtering in article list won't sync with search screen. **DATA INTEGRITY RISK: HIGH**
3. **Raw SQL tables not managed by Drift** (`app_database.dart` — `study_sessions` and `view_history` created via `customStatement`/`CREATE TABLE IF NOT EXISTS`) — Schema drift between Drift schema versions and raw SQL tables. **DATA LOSS RISK: HIGH**
4. **Dead duplicate `ArticleSearchScreen`** (`lib/features/search/search_screen.dart`) — At 221 lines of code, this file is imported by nothing. A developer maintaining the codebase could waste time fixing bugs in the wrong file. **MAINTENANCE BURDEN: MEDIUM**
5. **`initState` calling `ref.read(databaseProvider)` before widget tree is fully built** (`article_detail_screen.dart:52`) — While it works currently, this contradicts Riverpod best practices and could break if providers are refactored. **RUNTIME RISK: MEDIUM**

### ESTIMATED HEALTH SCORE: **6/10**

The app has solid architecture fundamentals (Riverpod, Drift, GoRouter, secure storage, proper error boundaries on Supabase calls) but is undermined by 2 critical `as` cast crashes waiting to happen, a duplicate provider bug that corrupts filtering state, and raw SQL tables that bypass Drift's schema management — any one of which could cause a production crash or data loss.