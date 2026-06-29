# EXECUTION_FLOW_AUDIT.md

## WardReady - Runtime Execution Flow Analysis

**Audit Date:** June 28, 2026  
**Project:** WardReady (Offline-first Flutter Medical Education App)  
**Platform:** Android APK

---

## 1. Startup Sequence

```
main()                                                        lib/main.dart:35
  ↓
WidgetsFlutterBinding.ensureInitialized()                        lib/main.dart:36
  ↓
SharedPreferences.getInstance()                                  lib/main.dart:37
  ↓
_seenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false      lib/main.dart:38
_seenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false        lib/main.dart:39
  ↓
FlutterError.onError = (details) { debugPrint(...) }              lib/main.dart:41
PlatformDispatcher.instance.onError = (error, stack) { debugPrint(...) } lib/main.dart:46
  ↓
ErrorWidget.builder = (details) => Scaffold(...)                  lib/main.dart:53 (kReleaseMode only)
  ↓
Supabase.initialize(url, publishableKey)                          lib/main.dart:81
  ↓
themeIndex = prefs.getInt('themeMode') ?? ThemeMode.dark.index     lib/main.dart:93
runApp(ProviderScope(overrides: [...], child: MyApp()))              lib/main.dart:94
  ↓
MyApp.build()                                                     lib/main.dart:190
  ↓
MaterialApp.router(routerConfig: _router, themeMode: themeMode, ...) lib/main.dart:193
  ↓
GoRouter initialLocation: '/' → InitialFlowGate                   lib/main.dart:99-123
  ↓
InitialFlowGate.build()                                           lib/main.dart:171
  ↓
┌─────────────────────────────────────────────────────────────┐
│ if (!_seenOnboarding) → OnboardingScreen                   │
│ else if (!_seenDisclaimer) → DisclaimerScreen                │
│ else → AppEntrance                                            │
└─────────────────────────────────────────────────────────────┘
  ↓
AppEntrance.build()                                               lib/main.dart:247
  ↓
StreamBuilder<AuthState>(stream: auth.onAuthStateChange)          lib/main.dart:254
  ↓
session == null → LoginScreen                                     lib/main.dart:270-271
session != null → SubscriptionGuard                               lib/main.dart:274
  ↓
SubscriptionGuard.build()                                         lib/main.dart:281
  ↓
isSubscribed.when(data: active → MainShell, error → Scaffold)       lib/main.dart:288-299
```

### Critical Functions in Startup
- `WidgetsFlutterBinding.ensureInitialized()` - Required before async initialization
- `Supabase.initialize()` - Must succeed before any auth/database operations
- `SharedPreferences.getInstance()` - Used for theme persistence and onboarding state
- `ErrorWidget.builder` - Global error fallback in release mode

---

## 2. Dependency Initialization Order

| Service | Created By | Owner | Lifecycle | Initialization Timing |
|---------|-----------|-------|-----------|----------------------|
| **Database** | `databaseProvider` | Riverpod ProviderContainer | `ref.onDispose(db.close)` | Lazy - on first read |
| **Supabase** | `Supabase.initialize()` | Global singleton | App lifetime | main() before runApp() |
| **SharedPreferences** | Static method calls | Multiple | Cached internally | main() before runApp() |
| **ConnectivityNotifier** | `connectivityProvider` | Riverpod StateNotifier | Automatic disposal | App build (watched by MainShell) |
| **SessionTimeoutNotifier** | `sessionTimeoutProvider` | Riverpod StateNotifier | `ref.onDispose(_cleanup)` | App build (watched by MainShell) |
| **SyncStateNotifier** | `syncStateProvider` | Riverpod StateNotifier | Automatic disposal | On-demand via provider |
| **ArticleRepository** | `articleRepositoryProvider` | Riverpod Provider | Depends on parent | On first use (CategoriesScreen) |
| **QuizRepository** | `quizRepositoryProvider` | Riverpod Provider | Depends on parent | On first quiz screen access |
| **NotificationService** | `notificationServiceProvider` | Singleton via factory | Static instance | On first use (SpacedRepetitionService) |
| **SpacedRepetitionService** | `spacedRepetitionServiceProvider` | Riverpod Provider | Depends on parent | QuizNotifier.build() |
| **QuizSyncService** | `quizSyncServiceProvider` | Riverpod Provider | Depends on parent | QuizNotifier.build() |
| **SubscriptionRepository** | `subscriptionRepositoryProvider` | Riverpod Provider | Depends on parent | SubscriptionGuard.build() |
| **AuthService** | `authServiceProvider` | Riverpod Provider | Depends on parent | Auth screens, main.dart |
| **WeaknessService** | `weaknessServiceProvider` | Riverpod Provider | Depends on parent | ArticleDetailScreen.build() |
| **AdminRepository** | `adminRepositoryProvider` | Riverpod Provider | Depends on parent | AdminDashboardScreen.build() |

### Provider Initialization Flow
```
databaseProvider (LazyDatabase)
  → ArticleRepository (needs Supabase, Database)
    → allArticlesProvider (StreamProvider)
    → paginatedArticlesProvider (StreamProvider.family)
    → articlesCountInCategoryProvider (FutureProvider.family)
  → SubscriptionRepository (needs Supabase)
    → isSubscribedProvider (FutureProvider)
  → QuizRepository (needs Supabase, Database)
    → SpacedRepetitionService (needs Database, NotificationService)
      → NotificationService (singleton factory with database)
    → QuizSyncService (needs QuizRepository)
  → WeaknessService (needs Database)
  → AdminRepository (needs Supabase)
```

---

## 3. User Journey Maps

### 3.1 First Install Journey

```
Launch → main() → InitialFlowGate → OnboardingScreen (3 slides)
  ↓
_onboardingComplete → DisclaimerScreen
  ↓
_disclaimerAccept → AppEntrance → StreamBuilder<AuthState>
  ↓
Session null → LoginScreen
  ↓
_signIn → AuthService.signIn() → Supabase.auth.signInWithPassword()
  ↓
Session created → SubscriptionGuard
  ↓
checkSubscriptionStatus() → profiles table + subscriptions table
  ↓
Not subscribed → PaywallScreen
  ↓
Payment & telegram verification → Admin activates subscription
  ↓
SubscriptionGuard → MainShell (4 tabs)
```

**Providers Used:** `authControllerProvider`, `isSubscribedProvider`, `bottomNavIndexProvider`  
**Database Access:** None until after auth  
**Network Access:** Supabase auth, profile/subscription endpoints  
**Failure Points:** Network failure during sign-in (catches AuthException), Supabase unavailable (rethrows)

### 3.2 Returning User Journey

```
Launch → main() → _seenOnboarding=true, _seenDisclaimer=true
  ↓
InitialFlowGate → AppEntrance
  ↓
StreamBuilder<AuthState> → checks for cached session
  ↓
Session exists → SubscriptionGuard
  ↓
isSubscribedProvider.future → checkSubscriptionStatus()
  ↓
Subscription valid → MainShell
```

**Providers Used:** `authSessionProvider`, `isSubscribedProvider`, `syncStateProvider`  
**Database Access:** Cached articles available immediately  
**Network Access:** Subscription check (grace period fallback)  
**Failure Points:** Session expired → redirected to LoginScreen via grace period check

### 3.3 Offline Startup Journey

```
Launch → main() → Supabase.initialize() (succeeds or fails)
  ↓
CategoriesScreen → initState() → _performAutoSyncIfNeeded()
  ↓
localArticles.isEmpty → true (no cached data) OR false
  ↓
If empty: repo.syncInBackground() fails → SocketException
  ↓
_onServerUnreachable() → markOffline(), setServerUnreachable()
  ↓
OfflineBanner displayed in MainShell
```

**Providers Used:** `allArticlesProvider`, `categoryProgressProvider`, `syncStateProvider`  
**Database Access:** Local SQLite only  
**Network Access:** None (sync fails silently with fallback)  
**Failure Points:** No cached data available - empty state shown

### 3.4 Expired Login Journey

```
Launch → AppEntrance → StreamBuilder<AuthState>
  ↓
Session exists but invalid → Supabase.currentSession returns stale data
  ↓
SubscriptionGuard → isSubscribedProvider -> checkSubscriptionStatus()
  ↓
Expired subscription → returns false
  ↓
PaywallScreen shown with "I HAVE PAID - CHECK STATUS" button
```

**Providers Used:** `isSubscribedProvider`, `subscriptionRepositoryProvider`  
**Database Access:** None  
**Network Access:** Subscription endpoint  
**Failure Points:** Network error → grace period check (30 days), then returns false

### 3.5 Admin Login Journey

```
Launch → Auth → SubscriptionGuard
  ↓
Admin user has is_admin=true in profiles
  ↓
SettingsScreen → currentAdminProfileProvider
  ↓
Admin true → "Admin Dashboard" ListTile visible
  ↓
Navigation to /admin → GoRouter redirect validates admin
  ↓
AdminDashboardScreen → adminUsersProvider
  ↓
fetchAllUsers() → profiles table join subscriptions
```

**Providers Used:** `currentAdminProfileProvider`, `adminUsersProvider`  
**Database Access:** None (remote only)  
**Network Access:** Supabase profiles and subscriptions endpoints  
**Failure Points:** 403 RLS rejection throws AppException

### 3.6 Subscribed User Journey

```
Launch → Auth → SubscriptionGuard
  ↓
isSubscribedProvider → checkSubscriptionStatus()
  ↓
Profile query → is_admin==true OR subscription.status=='active'
  ↓
Expiry date check → expiryDate.isAfter(DateTime.now())
  ↓
MainShell → CategoriesScreen
  ↓
todayPlanProvider → quiz_table queries (due cards, weak fields)
  ↓
FloatingActionButton.sync → articleRepositoryProvider.syncInBackground()
```

**Providers Used:** All providers active  
**Database Access:** Full read/write access  
**Network Access:** Articles sync, quiz sync (on-demand)  
**Failure Points:** 403 RLS, 429 rate limit (30s backoff), 503/504 server error

### 3.7 Database Recovery Journey

```
Database corruption → MigrationErrorStore.value set
  ↓
MainShell failed → DatabaseRecoveryScreen shown
  ↓
User taps "Reset & Re-sync"
  ↓
_resetAndResync() → delete *.db, *.sqlite files
  ↓
exit(0) → app restarts
```

**Providers Used:** Isolated MaterialApp (no providers)  
**Database Access:** Direct file deletion  
**Network Access:** None  
**Failure Points:** User must manually restart

### 3.8 Migration Failure Journey

```
Schema upgrade from < 9 to 9 → migration.onUpgrade()
  ↓
_runMigrationStep() → catch migration exceptions
  ↓
setMigrationError() → MigrationErrorStore.value
  ↓
SettingsScreen shows warning banner
```

**Providers Used:** None (direct DB access)  
**Database Access:** ALTER TABLE statements in _ensureStudySessionsTable, _ensureQuizTableSm2Columns  
**Network Access:** None  
**Failure Points:** Migration step failure is logged but continues

---

## 4. Feature Execution Flows

### 4.1 Categories Feature

```
CategoriesScreen.build()
  ↓
streakNotifierProvider.watch() → StreakNotifier.build() → _loadStats()
  ↓
todayPlanProvider.watch() → Custom SQL: quiz_table due cards + weak fields
  ↓
_AutoSync→ ArticleRepository.fetchAndSyncArticles()
  ↓
Supabase.from('articles').select() → Drift insertOnConflictUpdate
  ↓
categoryProgressProvider.watch(name) → AppDatabase.countReadCategories, countArticlesByCategory
```

**Major Classes:** CategoriesScreen, StreakNotifier, ArticleRepository, AppDatabase  
**Database Calls:** `SELECT COUNT` on quiz_table, articles table count queries  
**Providers:** `streakNotifierProvider`, `todayPlanProvider`, `categoryProgressProvider`

### 4.2 Article Opening Feature

```
CategoryTile.onTap → context.push('/article-detail', extra: article)
  ↓
ArticleDetailScreen.initState()
  ↓
_streakNotifier.recordArticleRead() → AppDatabase.recordArticleView()
  ↓
_recordViewHistory() → INSERT INTO view_history
  ↓
_weakFieldsProvider.watch(article.id) → WeaknessService.getWeakFields()
  ↓
StreamBuilder<List<Bookmark>> → SELECT bookmarks WHERE article_id
```

**Major Classes:** ArticleDetailScreen, StreakNotifier, WeaknessService, ArticleRepository  
**Database Calls:** INSERT study_sessions, INSERT view_history, SELECT bookmarks  
**Providers:** `streakNotifierProvider`, `weakFieldsProvider`, `highYieldModeProvider`

### 4.3 Search Feature

```
ArticleSearchScreen.onChanged → _debounceTimer
  ↓
_debounceTimer callback → ArticleSearchController.updateQuery()
  ↓
_runSearch() → ArticleSearchRepository.searchArticles()
  ↓
_ensureSearchIndex() → CREATE VIRTUAL TABLE article_search_fts
  ↓
_searchWithMatch() → FTS5 MATCH query → JOIN articles
```

**Major Classes:** ArticleSearchScreen, ArticleSearchController, ArticleSearchRepository  
**Database Calls:** FTS5 virtual table search, article count queries  
**Providers:** `articleSearchControllerProvider` (autoDispose), `articleSearchRepositoryProvider`  
**Timing:** 300ms debounce between keystrokes

### 4.4 Bookmark Feature

```
ArticleDetailScreen → StreamBuilder<List<Bookmark>>
  ↓
SELECT bookmarks JOIN articles ON article_id
  ↓
IconButton.onPressed → INSERT/DELETE bookmarks
  ↓
BookmarksScreen → SELECT articles JOIN bookmarks
```

**Major Classes:** ArticleDetailScreen, BookmarksScreen  
**Database Calls:** INSERT/DELETE bookmarks table, SELECT with JOIN  
**Providers:** Direct database access via `databaseProvider`

### 4.5 Quiz Feature

```
QuizScreen.build() → quizNotifierProvider(_defaultQuizCategory).watch()
  ↓
QuizNotifier.build(category) → _loadLocalQuestions(category)
  ↓
SpacedRepetitionService.getDueCards() → SELECT quiz_table WHERE next_due_at
  ↓
QuizRepository.getLocalQuestions() → SELECT quiz_table WHERE category
  ↓
Option tap → QuizNotifier.selectOption() → _showExplanation=true
  ↓
SM-2 Button → _recordReviewAndAdvance()
  ↓
QuizNotifier.recordReview(id, quality) → SpacedRepetitionService.recordReview()
  ↓
Drift transaction → UPDATE quiz_table (ease_factor, sr_interval, next_due_at)
  ↓
NotificationService.scheduleDueReminder() → FlutterLocalNotificationsPlugin.zonedSchedule()
```

**Major Classes:** QuizScreen, QuizNotifier, SpacedRepetitionService, QuizRepository, QuizSyncService  
**Database Calls:** SELECT/UPDATE quiz_table within transaction  
**Providers:** `quizNotifierProvider`, `quizRepositoryProvider`, `quizSyncServiceProvider`, `spacedRepetitionServiceProvider`, `streakNotifierProvider`

### 4.6 Progress Feature

```
ProgressScreen.build() → progressNotifierProvider.watch()
  ↓
ProgressNotifier.build() → 
  1. streakNotifierProvider.future → StreakNotifier._loadStats()
  2. _loadHeatmap() → SELECT study_sessions date, articles_read
  3. _loadCategoryProgress() → SELECT distinct categories + count queries
  4. _loadQuizAccuracyByCategory() → SELECT quiz_table GROUP BY category
```

**Major Classes:** ProgressScreen, ProgressNotifier, StreakNotifier  
**Database Calls:** Multiple aggregate queries on study_sessions, articles, quiz_table  
**Providers:** `progressNotifierProvider`, `streakNotifierProvider`

### 4.7 Settings Feature

```
SettingsScreen.build() →
  1. currentAdminProfileProvider.watch() → profiles SELECT is_admin
  2. dailyStudyRemindersEnabledProvider.watch() → SharedPreferences read
  3. themeModeProvider.watch() → StateProvider for theme
  ↓
Switch toggles →
  - NotificationService.setDailyRemindersEnabled()
  - saveThemeMode() → SharedPreferences
Logout → AuthService.signOut() → Supabase.auth.signOut() + clear tokens
```

**Major Classes:** SettingsScreen, NotificationService, AuthService  
**Database Calls:** None  
**Providers:** `currentAdminProfileProvider`, `dailyStudyRemindersEnabledProvider`, `themeModeProvider`

### 4.8 Theme Switch Feature

```
SettingsScreen.darkMode switch → saveThemeMode(ThemeMode mode)
  ↓
SharedPreferences.getInstance() → setInt('themeMode')
  ↓
themeModeProvider.notifier.state = newMode
  ↓
MyApp.build() → ref.watch(themeModeProvider) → MaterialApp.themeMode update
```

**Major Classes:** SettingsScreen, MyApp (main.dart)  
**Database Calls:** None  
**Providers:** `themeModeProvider`

### 4.9 Notification Scheduling Feature

```
SpacedRepetitionService.recordReview() →
  1. Drift transaction → UPDATE quiz_table
  2. _countDueCardsForDate() → SELECT COUNT WHERE next_due_at
  3. _notificationService.scheduleDueReminder(dueAt, dueCount)
  ↓
NotificationService.scheduleDueReminder() →
  1. initialize() → tz.initializeTimeZones(), FlutterLocalNotificationsPlugin.initialize()
  2. _scheduleDailyReminder() → zonedSchedule(8:00 AM daily)
```

**Major Classes:** SpacedRepetitionService, NotificationService  
**Database Calls:** COUNT query on quiz_table  
**Providers:** `notificationServiceProvider`, `spacedRepetitionServiceProvider`

### 4.10 Admin Dashboard Feature

```
SettingsScreen → ListTile "Admin Dashboard"
  ↓
context.push('/admin') → GoRouter redirect
  ↓
_redirect → currentAdminProfileProvider.future → SELECT profiles is_admin
  ↓
AdminDashboardScreen → adminUsersProvider.watch()
  ↓
AdminRepository.fetchAllUsers() → profiles LEFT JOIN subscriptions
  ↓
ListTile trailing "ACTIVATE" → AdminRepository.activateUser() → subscriptions.upsert()
```

**Major Classes:** AdminDashboardScreen, AdminRepository  
**Database Calls:** SELECT with JOIN on profiles, subscriptions; UPSERT subscriptions  
**Providers:** `adminUsersProvider`, `currentAdminProfileProvider`

### 4.11 Subscription Validation Feature

```
SubscriptionGuard.build() → isSubscribedProvider.watch()
  ↓
SubscriptionRepository.checkSubscriptionStatus() →
  1. profiles SELECT is_admin for current user
  2. subscriptions SELECT status, expiry_date
  ↓
Expiry logic: expiryDate.isAfter(DateTime.now().toUtc())
  ↓
_onNetworkError → _hasGracePeriod() → FlutterSecureStorage timestamp check
```

**Major Classes:** SubscriptionGuard, SubscriptionRepository  
**Database Calls:** None (Supabase only)  
**Providers:** `isSubscribedProvider`, `subscriptionRepositoryProvider`

---

## 5. Database Access Flow

### 5.1 Article Reads

| Location | Query | Frequency | Notes |
|----------|-------|-----------|-------|
| `CategoriesScreen._performAutoSyncIfNeeded()` | `allArticlesProvider.future` | Once per screen init | Triggers sync if empty |
| `ArticleListScreen._buildArticleList()` | `paginatedArticlesProvider` stream | Per scroll/pagination | Uses LIMIT/OFFSET |
| `Bookmark` queries | `SELECT bookmarks JOIN articles` | On article detail + bookmarks screen | Stream for real-time updates |
| `_recordViewHistory()` | `INSERT INTO view_history` | Per article open | No transaction wrapper |

### 5.2 Article Writes

| Location | Operation | Transaction | Notes |
|----------|-----------|-------------|-------|
| `ArticleRepository.fetchAndSyncArticles()` | `insertOnConflictUpdate` | Yes (Drift transaction) | Batch insert all articles |
| `_recordViewHistory()` | `INSERT INTO view_history` | No | Should be wrapped |

### 5.3 Quiz Reads

| Location | Query | Notes |
|----------|-------|-------|
| `SpacedRepetitionService.getDueCards()` | `SELECT * FROM quiz_table WHERE next_due_at IS NULL OR <= now` | ORDER BY due date |
| `QuizRepository.getLocalQuestions()` | `SELECT quiz_table WHERE category` | All questions for category |
| `ProgressNotifier._loadQuizAccuracyByCategory()` | `SELECT category, SUM(last_quality>=3), COUNT(*) GROUP BY category` | Accuracy calculation |

### 5.4 Quiz Writes

| Location | Operation | Transaction | Notes |
|----------|-----------|-------------|-------|
| `SpacedRepetitionService.recordReview()` | `UPDATE quiz_table SET ease_factor, sr_interval, next_due_at, last_quality` | Yes (Drift transaction) | SM-2 algorithm |
| `QuizRepository.upsertQuestions()` | `INSERT ... ON CONFLICT DO UPDATE` | Yes (Drift transaction) | Batch sync |

### 5.5 Study Session Writes

| Location | Operation | Notes |
|----------|-----------|-------|
| `AppDatabase.recordArticleView()` | `INSERT study_sessions ON CONFLICT DO UPDATE articles_viewed_count+1` | No transaction (single statement) |
| `StreakNotifier.recordQuizResult()` | `INSERT study_sessions ON CONFLICT DO UPDATE quizzes_completed, quiz_correct` | No transaction |

### 5.6 Redundant Queries Identified

1. **Multiple category progress queries:** Each category tile triggers separate `categoryProgressProvider` FutureProvider call, causing N+1 queries for N categories
2. **Duplicate streak loading:** Both `ProgressNotifier` and `CategoriesScreen` independently call `_loadStats()` which queries the same study_sessions table
3. **No caching for counts:** `articlesCountInCategoryProvider` and `articlesCountInCategoryAndSubcategoryProvider` don't cache across multiple reads

---

## 6. Provider Execution

### 6.1 Provider Creation and Dependencies

```
ProviderGraph (simplified):
themeModeProvider (StateProvider)
  → no dependencies

databaseProvider (Provider)
  → lazy initialization, onDispose cleanup, keepAlive

syncStateProvider (StateNotifierProvider)
  → SyncStateNotifier, no deps

serverUnreachableProvider (StateNotifierProvider)
  → ServerUnreachableNotifier, no deps

connectivityProvider (StateNotifierProvider)
  → ConnectivityNotifier, Timer every 30s

sessionTimeoutProvider (StateNotifierProvider)
  → SessionTimeoutNotifier, Supabase singleton

streakNotifierProvider (AsyncNotifierProvider)
  → StreakNotifier
    → databaseProvider (watch)

highYieldModeProvider (StateProvider)
  → no deps

subcategoryFilterProvider (StateProvider)
  → no deps

articleRepositoryProvider (Provider)
  → ArticleRepository
    → Supabase.instance.client (global)
    → databaseProvider (watch)
    → callbacks to syncStateProvider, connectivityProvider (read)

allArticlesProvider (StreamProvider)
  → articleRepositoryProvider (watch)
  → highYieldModeProvider (watch)
  → watchLocalArticles() stream

articlesCountInCategoryProvider (FutureProvider.family)
  → articleRepositoryProvider (watch)
  → highYieldModeProvider (watch)

quizRepositoryProvider (Provider)
  → QuizRepository
    → Supabase.instance.client (global)
    → databaseProvider (watch)

spacedRepetitionServiceProvider (Provider)
  → SpacedRepetitionService
    → databaseProvider (watch)
    → NotificationService

quizSyncServiceProvider (Provider)
  → QuizSyncService
    → quizRepositoryProvider (watch)

quizNotifierProvider (AsyncNotifierProvider.family)
  → QuizNotifier
    → quizRepositoryProvider (watch)
    → quizSyncServiceProvider (watch)
    → spacedRepetitionServiceProvider (watch)

notificationServiceProvider (Provider)
  → NotificationService (singleton)

isSubscribedProvider (FutureProvider)
  → subscriptionRepositoryProvider (watch)

subscriptionRepositoryProvider (Provider)
  → SubscriptionRepository
    → Supabase.instance.client (global)

authServiceProvider (Provider)
  → AuthService (no deps)

authSessionProvider (StreamProvider)
  → authServiceProvider (watch)
  → authStateStream

authControllerProvider (StateNotifierProvider)
  → AuthController
    → authServiceProvider (watch)

currentAdminProfileProvider (FutureProvider)
  → Supabase direct query (no repository abstraction)

adminUsersProvider (FutureProvider)
  → adminRepositoryProvider (watch)

weaknessServiceProvider (Provider)
  → WeaknessService
    → databaseProvider (watch)

weakFieldsProvider (FutureProvider.family)
  → weaknessServiceProvider (watch)

progressNotifierProvider (AsyncNotifierProvider)
  → ProgressNotifier
    → databaseProvider (watch)
    → streakNotifierProvider (watch)

categoryProgressProvider (FutureProvider.family)
  → databaseProvider (watch)

articleSearchControllerProvider (StateNotifierProvider.autoDispose)
  → ArticleSearchController
    → articleSearchRepositoryProvider (watch)

articleSearchRepositoryProvider (Provider)
  → ArticleSearchRepository
    → databaseProvider (watch)
```

### 6.2 Provider Listener Invalidation Triggers

| Provider | Invalidated By | Triggers Rebuild Of |
|----------|--------------|---------------------|
| `allArticlesProvider` | `highYieldModeProvider` change | CategoriesScreen, ArticleSearchScreen |
| `categoryProgressProvider(:category)` | `StreakNotifier.recordArticleRead()` | CategoriesScreen `_CategoryTile` |
| `streakNotifierProvider` | None automatic | CategoriesScreen, ProgressScreen |
| `articleSearchControllerProvider` | Query/category changes via debounce | ArticleSearchScreen |
| `quizNotifierProvider(:category)` | None automatic | QuizScreen |
| `isSubscribedProvider` | Manual `ref.refresh()` in PaywallScreen | SubscriptionGuard |
| `adminUsersProvider` | `activateUser()` success | AdminDashboardScreen |

### 6.3 Provider Disposal

| Provider | Disposal Trigger | Cleanup Action |
|----------|-----------------|----------------|
| `databaseProvider` | ProviderContainer dispose | `db.close()` |
| `ConnectivityNotifier` | StateNotifier dispose | `_timer?.cancel()` |
| `SyncStateNotifier` | StateNotifier dispose | `_rateLimitTimer?.cancel()` |
| `SessionTimeoutNotifier` | StateNotifier dispose | `_timer?.cancel()`, `_cleanup()` |
| `NotificationService` | Singleton (never) | N/A |
| `ExamSessionNotifier` | StateNotifier dispose | `_timer?.cancel()` |
| `ArticleSearchController` | autoDispose (route change) | `_debounceTimer?.cancel()` |

---

## 7. Network Flow

### 7.1 Supabase Request Endpoints

| Endpoint | Caller | Error Handling | Retry Logic | Offline Fallback |
|----------|--------|----------------|-------------|------------------|
| `auth.signInWithPassword` | `AuthService.signIn()` | `on AuthException` rethrow | None | None |
| `auth.signUp` | `AuthService.signUp()` | `on AuthException` rethrow | None | None |
| `auth.signOut` | `AuthService.signOut()` | `on AuthException` rethrow | None | None |
| `auth.refreshSession` | `AuthService.restoreSession()` | `on AuthException, PostgrestException` rethrow | None | None |
| `auth.onAuthStateChange` | `AuthService.authStateStream` | Stream transform | Continuous | N/A |
| `from('articles').select()` | `ArticleRepository.fetchAndSyncArticles()` | PostgrestException: 401→throw, 403→local cache, 429→rateLimited, 503/504→serverUnreachable, SocketException→offline | None | Return local articles |
| `from('questions').select()` | `QuizRepository.fetchQuestions()` | Same as articles | None | Return local questions |
| `from('profiles').select('is_admin')` | `SubscriptionRepository.checkSubscriptionStatus()` | 401/403 throw, network error→grace period | None | 30-day grace period check |
| `from('profiles').select(...)` | `AdminRepository.fetchAllUsers()` | 403→AppException | None | None |
| `from('subscriptions').upsert()` | `AdminRepository.activateUser()` | 403→AppException | None | None |

### 7.2 Error Handling Patterns

All repository methods follow this pattern:
```dart
try {
  final response = await _supabase.from(...).select();
  await _db.transaction(() { /* cache locally */ });
  _onSuccessfulSync();
} on PostgrestException catch (e) {
  final status = postgrestStatus(e);
  if (status == 401) throw SupabaseSessionExpiredException();
  if (status == 403) return local cache; // RLS fallback
  if (status == 429) _onRateLimited(); return local cache;
  if (status == 503 || status == 504) _onServerUnreachable(); return local cache;
} on SocketException {
  _onServerUnreachable();
  return local cache;
}
```

### 7.3 Cached Fallback Behavior

| Provider/Flow | Local Source | Validity |
|---------------|--------------|----------|
| Articles empty sync | `allArticlesProvider` stream | Drift `SELECT articles` |
| Quiz questions offline | `QuizRepository.getLocalQuestions()` | Drift `SELECT quiz_table` |
| Subscription network error | `SubscriptionRepository._hasGracePeriod()` | 30-day timestamp check |

---

## 8. Error Propagation

### 8.1 Exception Origins

| Exception Type | Origin Location | Caught By | Recovery |
|---------------|-----------------|-----------|----------|
| `PostgrestException` | Supabase HTTP responses | Repository methods | Local cache, grace period, or rethrow |
| `SocketException` | Network layer | Repository methods | Local cache fallback |
| `SqliteException` | Drift native DB | Repository methods | DiskFullException for disk errors, else rethrow |
| `DioException` | HTTP client | QuizRepository | Local cache fallback |
| `AuthException` | Supabase auth | AuthService | Rethrow, clear tokens |
| `DiskFullException` | Repository internal | UI layer | Shown as error in SnackBar |
| `SupabaseSessionExpiredException` | 401 responses | UI layer | No explicit handling |
| `AppException` | Custom throws | UI layer | Display message to user |
| `FlutterError` | Framework errors | `FlutterError.onError` | Debug print, release ErrorWidget |
| Platform errors | Dart VM | `PlatformDispatcher.onError` | Debug print, return true (handled) |

### 8.2 Error Display Locations

| Error Type | Display Method |
|------------|---------------|
| Sync error in category tile | Card with `Icons.sync_problem`, "Could not sync. Showing cached data." + Retry button |
| Quiz error | "Unable to load quiz questions." + Try Again button |
| Progress error | "Unable to load progress." + Retry button |
| Auth error | `AuthUiState.status = error`, message displayed in form |
| Search error | "Search temporarily unavailable" or "Search failed." |

### 8.3 Silent Failures

1. **`WeaknessService.getWeakFields()`** catches all errors and returns empty set `{}`
2. **`StreakNotifier.build()`** catches errors and returns `(0, 0, 0.0)` silently
3. **Notification scheduling** catches errors with debugPrint only, no UI feedback
4. **ArticleDetailScreen._recordViewHistory()** catches errors silently

---

## 9. State Lifecycle

### 9.1 Authentication State

| Event | State Change | Location |
|-------|-------------|----------|
| App launch | `_seenOnboarding` check | main.dart:38 |
| Login success | `auth.onAuthStateChange` stream emits | AuthService.signIn() |
| Token refresh | `auth.onAuthStateChange` | AuthService.restoreSession() |
| Logout | `auth.onAuthStateChange` stream emits null | AuthService.signOut() |
| Session timeout (30 min) | SessionTimeoutNotifier sets state=true | SessionTimeoutNotifier.resetTimer() |
| Timeout handled | Navigation to `/login`, state consumed | MainShell listener |

### 9.2 Theme State

| Event | State Change | Storage |
|-------|-------------|---------|
| App launch | `prefs.getInt('themeMode')` | SharedPreferences |
| Toggle in Settings | `saveThemeMode()` + provider state | SharedPreferences + provider |

### 9.3 Navigation State

| Provider | Purpose | Lifecycle |
|----------|---------|-----------|
| `bottomNavIndexProvider` | 0-5 for 6 tabs | StateProvider, manual set |
| `GoRouter` | Path-based navigation | Global, `context.go()`, `context.push()` |

### 9.4 Quiz State

| State Variable | Purpose | Reset Trigger |
|----------------|---------|---------------|
| `_currentIndex` | Current question index | `reset()`, `loadQuestionsByIds()` |
| `_selectedOption` | Selected answer | `_resetCurrentQuestionState()` |
| `_showExplanation` | Answer revealed | Same as selectedOption |
| `_correctCount` | Session correct count | `reset()` |
| `_totalThisSession` | Questions answered | `reset()` |
| `_wrongQuestionIds` | IDs for retry review | `reset()`, retry screen |

### 9.5 Sync State

| State | Meaning | Cleared By |
|-------|---------|-----------|
| `serverUnreachable` | 503/504 error occurred | `markReachable()` on successful sync |
| `rateLimited` | 429 received | Auto after 30s in `_rateLimitTimer` |
| `syncIncomplete` | Sync partially failed | Next successful sync |

### 9.6 Progress State

| Source | Data | Refresh Trigger |
|--------|------|-----------------|
| `study_sessions` table | Streak, articles read, quiz accuracy | `StreakNotifier.recordArticleRead()`, `recordQuizResult()` |
| `quiz_table` | Due dates, ease factors, quality scores | `SpacedRepetitionService.recordReview()` |

### 9.7 Subscription State

| State | Trigger | Cache |
|-------|---------|-------|
| `checkSubscriptionStatus()` | Provider build, manual refresh | Secure storage timestamp (30 day grace) |

### 9.8 Connectivity State

| State | Detection Method | Poll Interval |
|-------|-----------------|-------------|
| `true` (online) | `InternetAddress.lookup('example.com')` | Every 30 seconds |
| `false` (offline) | SocketException | Continuous via timer |

---

## 10. Async Analysis

### 10.1 Futures

| Future | Location | Awaiting Context |
|--------|----------|------------------|
| `SharedPreferences.getInstance()` | main.dart:37, multiple locations | Before runApp, on-demand |
| `Supabase.initialize()` | main.dart:81 | Before runApp, blocking |
| `auth.signInWithPassword()` | AuthService.signIn() | Async in AuthController |
| `auth.refreshSession()` | AuthService.restoreSession() | Async on app start |
| `repo.syncInBackground()` | Multiple locations | Auto-sync, manual sync button |
| `StreakNotifier.recordQuizResult()` | QuizScreen callback | After review submission |
| `NotificationService.scheduleDueReminder()` | SpacedRepetitionService | Within transaction |

### 10.2 Streams

| Stream | Location | Listener |
|--------|----------|----------|
| `auth.onAuthStateChange` | AppEntrance.build(), AuthService | StreamBuilder in UI |
| `allArticlesProvider` | CategoriesScreen, ArticleSearchScreen | StreamProvider.watch |
| `bookmarks watch` | ArticleDetailScreen | StreamBuilder |
| `WeaknessService` queries | ArticleDetailScreen | FutureProvider.watch |

### 10.3 Timers

| Timer | Owner | Callback |
|-------|-------|----------|
| Connectivity check | `ConnectivityNotifier` | Every 30s `_checkConnectivity()` |
| Session timeout | `SessionTimeoutNotifier` | 30 min idle → auto logout |
| Rate limit clear | `SyncStateNotifier` | 30s after rate limit |
| Exam timer | `ExamSessionNotifier` | Every second for 3-hour exam |

### 10.4 Debounce

| Debounced Operation | Duration | Location |
|---------------------|----------|----------|
| Search query input | 300ms | ArticleSearchController.updateQuery() |

### 10.5 Post-Frame Callbacks

| Callback | Purpose | Location |
|----------|---------|----------|
| `Future.microtask()` | Deferred state init | CategoriesScreen.initState(), ArticleSearchScreen.initState() |
| `WidgetsBinding.instance.addPostFrameCallback()` | Navigation fallback | ArticleDetailScreen.initState() |

### 10.6 Race Conditions Identified

1. **`CategoriesScreen._performAutoSyncIfNeeded()`** - `_didAutoSync` flag prevents multiple sync calls, but `allArticlesProvider.future` and sync race if both check emptiness
2. **`ArticleListScreen._listenToPaginationChanges()`** - Uses `Future.microtask()` to update state after async data arrives, potential for stale updates if user navigates quickly
3. **`QuizScreen._recordReviewAndAdvance()`** - Sequential `await` calls for review recording and streak update; if second fails, first side-effect remains
4. **`StreakNotifier.recordQuizResult()`** - Sets state to loading then data, but `_loadStats()` does multiple queries that could be stale

---

## 11. Threading Analysis

### 11.1 UI Isolate Operations

| Operation | blocking? | Notes |
|-----------|-----------|-------|
| `FlutterError.onError` | No | Error handler |
| `GoRouter` navigation | No | Event-driven |
| All `build()` methods | No | Reactive |
| `StreamBuilder` rebuilds | No | Stream-driven |
| `Timer` callbacks | No | Event loop |

### 11.2 Async Operations

| Operation | Thread | Notes |
|-----------|--------|-------|
| `Supabase.initialize()` | Native async | Before UI |
| `SharedPreferences.getInstance()` | Native async | Internal caching |
| Drift `customSelect()` | Native SQLite | Async by default |
| Drift `transaction()` | Native SQLite | Serializes writes |
| `InternetAddress.lookup()` | IO thread | Async |
| `FlutterLocalNotificationsPlugin` | Native platform | Async, permission dialogs |

### 11.3 Potentially Blocking Operations

1. **`AppDatabase._ensureStudySessionsTable()`** - Multiple `customStatement` calls in sequence during migration could block if table is large
2. **`ArticleSearchRepository._ensureSearchIndex()`** - Creates FTS5 index and rebuilds on first run; iterates through all articles
3. **`ExamSessionNotifier._selectWeighted200Questions()`** - Multiple sequential queries to select questions per domain

---

## 12. Startup Performance

### 12.1 Critical Path

```
main() [blocking]
  ↓
Supabase.initialize() [network, blocking]
  ↓
SharedPreferences.getInstance() [disk, fast]
  ↓
runApp() [UI render begins]
  ↓
GoRouter route '/' → InitialFlowGate
  ↓
_onSeen checks → Onboarding/Disclaimer skip
  ↓
AppEntrance → StreamBuilder waiting for auth
  ↓
SubscriptionGuard → isSubscribedProvider.future [network]
  ↓
MainShell → StateNotifier initialization
  ↓
Connectivity timer starts
  ↓
Subscription check timer starts (30 min)
```

### 12.2 Unnecessary Work

1. **Supabase initialization always runs** - Even if user starts offline, must attempt network connection
2. **ErrorWidget.builder in release mode** - Adds overhead even when no errors occur
3. **Multiple SharedPreferences reads** - Onboarding flow reads same prefs multiple times

### 12.3 Parallelizable Work

1. **`StreakNotifier._loadStats()`** makes 3 separate queries sequentially - could be parallelized
2. **`ProgressNotifier.build()`** - 4 async operations sequential, could use `Future.wait()` for heatmap+category+quiz
3. **Database initialization** - `_ensureStudySessionsTable`, `_ensureQuizTableSm2Columns` run on-demand, could preload

### 12.4 Lazy Initialization Opportunities

1. **NotificationService.initialize()** - Only called when reminders enabled or on first schedule
2. **ArticleSearchRepository._ensureSearchIndex()** - Could be deferred until first search
3. **WeaknessService._ensureLastQualityColumn()** - Could be part of main DB migration

---

## 13. Sequence Diagrams

### 13.1 Launch Sequence

```
title App Launch Sequence
participant main.dart
participant SharedPreferences
participant Supabase
participant GoRouter
participant InitialFlowGate
participant OnboardingScreen

main.dart->SharedPreferences: getBool('hasSeenOnboarding')
main.dart->Supabase: initialize(url, key)
main.dart->GoRouter: route '/'
GoRouter->InitialFlowGate: builder()
InitialFlowGate->OnboardingScreen: if !_seenOnboarding
OnboardingScreen->SharedPreferences: setBool(_hasSeenOnboardingKey, true)
InitialFlowGate->DisclaimerScreen: if !_seenDisclaimer
DisclaimerScreen->SharedPreferences: setBool('hasSeenDisclaimer', true)
InitialFlowGate->AppEntrance: else
```

### 13.2 Sync Sequence

```
title Sync Sequence
participant CategoriesScreen
participant ArticleRepository
participant Supabase
participant AppDatabase

CategoriesScreen->_performAutoSyncIfNeeded: Future.microtask
ArticleRepository->Supabase: from('articles').select()
Supabase-->ArticleRepository: response with articles
ArticleRepository->AppDatabase: transaction { insertOnConflictUpdate }
AppDatabase-->ArticleRepository: success
ArticleRepository->ConnectivityProvider: markOffline/notify
ArticleRepository-->CategoriesScreen: Future completes
CategoriesScreen->categoryProgressProvider: invalidate()
```

### 13.3 Quiz Sequence

```
title Quiz Question Flow
participant QuizScreen
participant QuizNotifier
participant SpacedRepetitionService
participant QuizRepository
participant NotificationService

QuizScreen->QuizNotifier: build()
QuizNotifier->SpacedRepetitionService: getDueCards()
QuizNotifier->QuizRepository: getLocalQuestions()
QuizNotifier-->QuizScreen: AsyncData<List<QuizTableData>>
QuizScreen->QuizNotifier: selectOption(QuizOption.a)
QuizNotifier->_showExplanation = true
QuizScreen->_buildSm2Buttons(): show "Again/Hard/Good/Easy"
QuizScreen->_recordReviewAndAdvance()
QuizNotifier->SpacedRepetitionService: recordReview(id, quality)
SpacedRepetitionService->AppDatabase: transaction { UPDATE quiz_table }
SpacedRepetitionService->NotificationService: scheduleDueReminder()
SpacedRepetitionService-->QuizNotifier: interval
QuizNotifier->StreakNotifier: recordQuizResult(isCorrect)
StreakNotifier->AppDatabase: INSERT study_sessions
QuizNotifier->QuizNotifier: nextQuestion() or reset()
QuizNotifier-->QuizScreen: AsyncData with new state
```

### 13.4 Search Sequence

```
title Search Sequence
participant ArticleSearchScreen
participant ArticleSearchController
participant ArticleSearchRepository
participant AppDatabase

ArticleSearchScreen->_controller.onChanged: value
ArticleSearchController->Timer: debounce 300ms
Timer->_runSearch(query, category)
ArticleSearchRepository->_ensureSearchIndex(): CREATE VIRTUAL TABLE IF NOT EXISTS
ArticleSearchRepository->AppDatabase: customSelect FTS5 MATCH
AppDatabase-->ArticleSearchRepository: results
ArticleSearchRepository->ArticleSearchScreen: state = ready
```

### 13.5 Notification Scheduling

```
title Notification Scheduling
participant SpacedRepetitionService
participant NotificationService
participant AppDatabase
participant FlutterLocalNotificationsPlugin

SpacedRepetitionService->AppDatabase: COUNT due cards for date
SpacedRepetitionService->NotificationService: scheduleDueReminder(dueAt, count)
NotificationService->FlutterLocalNotificationsPlugin: initialize()
NotificationService->FlutterLocalNotificationsPlugin: zonedSchedule(id, 8:00 AM, body)
```

### 13.6 Login Sequence

```
title Login Sequence
participant LoginScreen
participant AuthController
participant AuthService
participant Supabase

LoginScreen->_submit()
AuthController->AuthService: signIn(email, password)
AuthService->Supabase: signInWithPassword()
Supabase-->AuthService: response with session
AuthService->_persistSession(): FlutterSecureStorage
AuthController-->LoginScreen: state = success
LoginScreen->context: go('/home')
```

### 13.7 Theme Switching

```
title Theme Switch Sequence
participant SettingsScreen
participant themeModeProvider
participant MyApp

SettingsScreen->SwitchListTile: onChanged(true)
SettingsScreen->saveThemeMode(ThemeMode.dark)
SettingsScreen->themeModeProvider: state = dark
MyApp->themeModeProvider: watch()
MyApp->MaterialApp: themeMode = dark
```

---

## 14. Hidden Runtime Risks

### 14.1 Dead Execution Paths

1. **`_DisclaimerGateState`** (main.dart:204-245) - Class exists but never used in routing; `InitialFlowGate` handles disclaimer flow instead
2. **`articleOffsetProvider`, `articleLoadedArticlesProvider`, etc.** in `article_list_screen.dart` - Only used locally, not connected to pagination controller
3. **Unused `QuizQuestionLocal` table** in `app_database.dart` - Created in schema but no code references it; `QuizTable` is used instead

### 14.2 Unreachable Code

1. **`ArticleDetailScreen._buildShowLowYieldButton()`** - Only rendered when `highYieldMode && isLowYield && !_showLowYieldSections && key == 'definition'` - May never show if content empty
2. **`QuizScreen._buildNextReviewLabel()`** - Shows `_formatNextReview(interval)` but if `lastReviewInterval` is null, shows "—"

### 14.3 Unexpected Loops

1. **`StreakNotifier.recordArticleRead()`** sets state to loading then data, which could trigger other listeners that also call `invalidate()` causing loops
2. **`QuizSyncService.syncQuestions()`** catches and rethrows but doesn't propagate error to UI - `QuizNotifier.syncQuestions()` does

### 14.4 Recursive Paths

None identified. All async operations properly use mounted checks.

### 14.5 Duplicate Initialization

1. **`NotificationService` singleton** - Factory creates singleton, but `spacedRepetitionServiceProvider` creates new `NotificationService` instance each time (though factory caches)
2. **`WeaknessService._ensureLastQualityColumn()`** - Could run multiple times if called concurrently before index exists

### 14.6 Double Subscriptions/Listeners

1. **`ConnectivityNotifier`** - Timer starts in constructor AND `_checkConnectivity()` called immediately, 30-second duplicate checks
2. **`SessionTimeoutNotifier`** - Timer and listener set in `MainShell.initState()`, also called from `AppEntrance` on session change

### 14.7 Race Conditions

1. **`SubscriptionGuard`** - `isSubscribedProvider.future` resolves before `sessionTimeoutProvider.resetTimer()` is called in `AppEntrance`
2. **`ArticleDetailScreen`** - Multiple async operations (`recordArticleRead`, `_recordViewHistory`, invalidate) in microtask without ordering guarantees
3. **`QuizNotifier.loadQuestionsByIds()`** - Sets state to loading, fetches questions, sets AsyncData - intermediate state could be observed by UI

### 14.8 Ordering Bugs

1. **`main.dart`** - `themeModeProvider.overrideWith()` used before `runApp()`, but SharedPreferences already read - potential for race if theme changed by another isolate
2. **`SpacedRepetitionService._calculateSchedule()`** - Called inside transaction, but `_countDueCardsForDate()` and `scheduleDueReminder()` are sequential not parallel

---

## 15. Final Runtime Assessment

### 15.1 Scores (1-5, 5 = best)

| Category | Score | Rationale |
|----------|-------|-----------|
| **Startup** | 4 | Fast, minimal blocking, but Supabase init always required |
| **Initialization** | 4 | Lazy providers, good dependency order, some duplicate init |
| **Navigation** | 5 | Clean GoRouter setup, proper back handling |
| **Async Safety** | 4 | Good mounted checks, some silent failures |
| **Provider Lifecycle** | 4 | Mostly correct disposal, some autoDispose missed opportunities |
| **Database Flow** | 3 | Transactions used, but N+1 queries and redundant writes |
| **Network Flow** | 4 | Consistent error handling, graceful offline fallback |
| **Error Recovery** | 3 | Some silent failures, no retry mechanism on sync failure |
| **Overall Design** | 4 | Solid offline-first architecture, minor improvements needed |

### 15.2 Optimization Priorities

**If I had to optimize runtime behavior before release, these are the first ten changes I would make:**

1. **Parallelize `StreakNotifier._loadStats()`** - Use `Future.wait([_loadCurrentStreak(), _loadTotalArticles(), _loadAccuracy()])` to reduce startup wait time

2. **Fix N+1 query in category progress** - Cache category list and use single query with GROUP BY instead of N queries for N categories

3. **Wrap `_recordViewHistory()` in transaction** - Currently separate from article view recording, should be atomic

4. **Remove unused `QuizQuestionLocal` table** - Dead code increases schema complexity and migration time

5. **Remove unused `_DisclaimerGate` class** - Duplicate logic with `InitialFlowGate`, delete to reduce confusion

6. **Add retry mechanism for sync failures** - Exponential backoff for network errors instead of immediate failure

7. **Fix duplicate connectivity check** - Remove immediate `_checkConnectivity()` call from constructor (timer handles it)

8. **Use `Future.wait()` in `ProgressNotifier.build()`** - Parallelize heatmap, category progress, and quiz accuracy queries

9. **Add explicit handling for `SupabaseSessionExpiredException`** - Currently rethrown but no navigation to login on 401

10. **Pre-warm FTS5 search index** - Run `_ensureSearchIndex()` during splash instead of on first search keystroke