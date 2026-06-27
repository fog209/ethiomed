# WardReady — Provider Reference

## Auth Providers

### authServiceProvider
- **File:** `lib/features/auth/data/auth_service.dart:9-11`
- **Type:** `Provider<AuthService>`
- **Purpose:** Singleton for Supabase/auth operations
- **Dependencies:** `Supabase.instance.client`
- **Consumers:** `AuthController`, `quizRepositoryProvider` callbacks
- **Issues:** `initialize()` method exists but never called (session restore missing)

### authSessionProvider
- **File:** `lib/features/auth/data/auth_service.dart:13-15`
- **Type:** `StreamProvider<Session?>`
- **Purpose:** Reactive session stream
- **Dependencies:** `authServiceProvider`
- **Consumers:** `AppEntrance.build`
- **Lifecycle:** Active while app running

### authControllerProvider
- **File:** `lib/features/auth/data/auth_service.dart:103-106`
- **Type:** `StateNotifierProvider<AuthController, AuthUiState>`
- **Purpose:** Login/signup UI state
- **Dependencies:** `authServiceProvider`
- **Consumers:** `LoginScreen`, `SignupScreen`
- **Lifecycle:** Created on screen open

---

## Database Providers

### databaseProvider
- **File:** `lib/core/database/app_database.dart:440-445`
- **Type:** `Provider<AppDatabase>`
- **Purpose:** Singleton Drift database instance
- **Dependencies:** `LazyDatabase` → `NativeDatabase`
- **Consumers:** 25+ providers (all data features)
- **Issues:** Must call `build_runner` after schema changes

---

## Navigation Providers

### bottomNavIndexProvider
- **File:** `lib/app/nav_provider.dart:3`
- **Type:** `StateProvider<int>`
- **Purpose:** Selected tab index (0-5)
- **Dependencies:** None
- **Consumers:** `MainShell`
- **Default:** 0

---

## Theme Providers

### themeModeProvider
- **File:** `lib/main.dart:28`
- **Type:** `StateProvider<ThemeMode>`
- **Purpose:** Dark/light theme toggle
- **Dependencies:** None
- **Consumers:** `MyApp`, `SettingsScreen`
- **Default:** `ThemeMode.dark`

---

## Connectivity Providers

### connectivityProvider
- **File:** `lib/core/providers/connectivity_notifier.dart:8-10`
- **Type:** `StateNotifierProvider<ConnectivityNotifier, bool>`
- **Purpose:** Network status (polls every 30s)
- **Dependencies:** None
- **Consumers:** `MainShell` (offline banner)
- **Default:** true (assumes online)
- **Issues:** Timer starts immediately, potential race on disposal

### serverUnreachableProvider
- **File:** `lib/core/providers/connectivity_notifier.dart:14-17`
- **Type:** `StateNotifierProvider<ServerUnreachableNotifier, bool>`
- **Purpose:** Track if Supabase was unreachable
- **Dependencies:** None
- **Consumers:** `MainShell` (retry banner)
- **Issues:** Auto-clears on next sync, no persistence

---

## Sync State Providers

### syncStateProvider
- **File:** `lib/core/providers/sync_state_provider.dart:5-7`
- **Type:** `StateNotifierProvider<SyncStateNotifier, SyncState>`
- **Purpose:** Track sync progress/errors
- **Fields:** `serverUnreachable`, `rateLimited`, `syncIncomplete`, `diskFull`
- **Consumers:** Repository callbacks (article, quiz)
- **Issues:** `rateLimited` timer may race on slow devices

---

## Article Providers

### articleRepositoryProvider
- **File:** `lib/features/articles/data/article_repository.dart:234-251`
- **Type:** `Provider<ArticleRepository>`
- **Purpose:** Article data operations
- **Dependencies:** `Supabase.instance.client`, `databaseProvider`

### allArticlesProvider
- **File:** `lib/features/articles/data/article_repository.dart:253-260`
- **Type:** `StreamProvider<List<ArticleLocal>>`
- **Purpose:** Stream all articles with optional high-yield filter
- **Dependencies:** `articleRepositoryProvider`, `highYieldModeProvider`

### paginatedArticlesProvider
- **File:** `lib/features/articles/data/article_repository.dart:293-305`
- **Type:** `StreamProvider.family<List<ArticleLocal>, ArticlePageQuery>`
- **Purpose:** Paginated article list

### articleListControllerProvider
- **File:** `lib/features/articles/data/article_repository.dart:474-477`
- **Type:** `StateNotifierProvider<ArticleListController, ArticleListState>`
- **Purpose:** Pagination state management

---

## Quiz Providers

### quizRepositoryProvider
- **File:** `lib/features/quiz/quiz_repository.dart:230-243`
- **Type:** `Provider<QuizRepository>`
- **Purpose:** Quiz data operations with callbacks

### quizNotifierProvider
- **File:** `lib/features/quiz/quiz_notifier.dart:11-14`
- **Type:** `AsyncNotifierProvider.family<QuizNotifier, List<QuizTableData>, String>`
- **Purpose:** Quiz session state per category
- **Dependencies:** `quizRepositoryProvider`, `quizSyncServiceProvider`, `spacedRepetitionServiceProvider`
- **Issues:** Tight coupling to 3 services — refactoring target

### quizSyncServiceProvider
- **File:** `lib/features/quiz/quiz_sync_service.dart:32-34`
- **Type:** `Provider<QuizSyncService>`
- **Purpose:** Wraps quiz repository for sync

### spacedRepetitionServiceProvider
- **File:** `lib/features/quiz/spaced_repetition_service.dart:215-222`
- **Type:** `Provider<SpacedRepetitionService>`
- **Purpose:** SM-2 algorithm
- **Dependencies:** `databaseProvider`, `notificationServiceProvider`

### weaknessServiceProvider
- **File:** `lib/features/quiz/weakness_service.dart:51-53`
- **Type:** `Provider<WeaknessService>`
- **Purpose:** Identify weak question fields

### weakFieldsProvider
- **File:** `lib/features/quiz/weakness_service.dart:55-60`
- **Type:** `FutureProvider.family<Set<String>, String>`
- **Purpose:** Fields needing review per article

### examSessionProvider
- **File:** `lib/features/quiz/exam_session_notifier.dart:49-53`
- **Type:** `StateNotifierProvider<ExamSessionNotifier, ExamSessionState>`
- **Purpose:** EHPLE exam session state
- **Issue:** No route defined in GoRouter

---

## Progress Providers

### streakNotifierProvider
- **File:** `lib/features/progress/streak_notifier.dart:13-14`
- **Type:** `AsyncNotifierProvider<StreakNotifier, StudyStreakStats>`
- **Purpose:** Streak calculation
- **Dependencies:** `databaseProvider`

### progressNotifierProvider
- **File:** `lib/features/progress/progress_notifier.dart:32-33`
- **Type:** `AsyncNotifierProvider<ProgressNotifier, ProgressData>`
- **Purpose:** Aggregate progress data
- **Dependencies:** `streakNotifierProvider`, `databaseProvider`

### categoryProgressProvider
- **File:** `lib/features/progress/category_progress_provider.dart`
- **Type:** `FutureProvider.family<CategoryProgress, String>`
- **Purpose:** Per-category progress percentage

---

## Subscription Providers

### subscriptionRepositoryProvider
- **File:** `lib/features/subscription/data/subscription_repository.dart:118-120`
- **Type:** `Provider<SubscriptionRepository>`

### isSubscribedProvider
- **File:** `lib/features/subscription/data/subscription_repository.dart:122-129`
- **Type:** `FutureProvider<bool>`
- **Purpose:** Subscription status check
- **Dependencies:** `subscriptionRepositoryProvider`
- **Note:** Admin users always return true

---

## Search Providers

### articleSearchRepositoryProvider
- **File:** `lib/features/articles/data/article_search_provider.dart:16-20`
- **Type:** `Provider<ArticleSearchRepository>`

### articleSearchControllerProvider
- **File:** `lib/features/articles/data/article_search_provider.dart:22-30`
- **Type:** `StateNotifierProvider.autoDispose<ArticleSearchController, ArticleSearchState>`
- **Purpose:** Search state with 300ms debounce

---

## Notification Providers

### notificationServiceProvider
- **File:** `lib/core/services/notification_service.dart:14-16`
- **Type:** `Provider<NotificationService>`
- **Purpose:** Notification scheduling

### dailyStudyRemindersEnabledProvider
- **File:** `lib/core/services/notification_service.dart:18-23`
- **Type:** `StateNotifierProvider<NotificationReminderNotifier, bool>`
- **Purpose:** Reminder toggle state
- **Issue:** No Android 13+ permission check

---

## Admin Providers

### adminRepositoryProvider
- **File:** `lib/features/admin/data/admin_repository.dart:113-115`
- **Type:** `Provider<AdminRepository>`

### adminUsersProvider
- **File:** `lib/features/admin/data/admin_repository.dart:117-119`
- **Type:** `FutureProvider<List<AdminUser>>`
- **Purpose:** All users list (unpaginated)

### currentAdminProfileProvider
- **File:** `lib/features/admin/data/admin_repository.dart:121-145`
- **Type:** `FutureProvider<bool>`
- **Purpose:** Is current user admin
- **Used by:** GoRouter redirect at `/admin`
- **Issue:** Redirect awaits without loading state