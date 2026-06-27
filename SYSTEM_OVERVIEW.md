# WardReady — System Overview

## Overview

WardReady is an offline-first Flutter Android application for Ethiopian medical education. It provides 441 clinical articles, 2,000+ MCQs, SM-2 spaced repetition, and subscription-gated access via Supabase authentication.

## Architecture

### Layer Pattern

```
UI Layer (Screens/Widgets)
    ↓
Riverpod Providers (State Management)
    ↓
Repository Layer (Data Operations)
    ↓
Drift Database (Local SQLite)
    ↓
Supabase (Remote PostgreSQL/Auth)
```

### Application Lifecycle

**Startup Sequence (`lib/main.dart`):**

1. `main()` called → `WidgetsFlutterBinding.ensureInitialized()`
2. SharedPreferences read for `hasSeenOnboarding` and `hasSeenDisclaimer`
3. Flutter error handlers installed (lines 41-50)
4. Supabase.initialize() with keys from `lib/app/env.dart` (lines 81-91)
5. Theme mode restored from SharedPreferences (line 93)
6. `ProviderScope` created with theme override (lines 94-97)
7. GoRouter configured with 10 routes (lines 99-162)

**Initial Flow Gate (`lib/main.dart:164-184`):**

- If `!hasSeenOnboarding` → show OnboardingScreen
- Else if `!hasSeenDisclaimer` → show DisclaimerScreen
- Else → show MainShell (subscription check happens in `SubscriptionGuard`)

### Dependency Graph

```
main.dart
  ├── Supabase.initialize (env.dart provides keys)
  ├── ProviderScope
  │     ├── databaseProvider (LazyDatabase → NativeDatabase)
  │     ├── themeModeProvider (StateProvider<ThemeMode>)
  │     └── all feature providers
  └── MyApp (MaterialApp.router)

Providers depend on:
  ├── databaseProvider
  ├── Supabase.instance.client
  └── Other feature providers
```

### Feature Interactions

| Feature | Interacts With | Purpose |
|---------|--------------|---------|
| Auth | Supabase, SecureStorage, SessionTimeout | Token management, session expiry |
| Articles | Supabase, Drift, FTS5 | Content sync, search |
| Quiz | Supabase, Drift, SpacedRepetition | Questions, SM-2 scheduling |
| Progress | Drift (study_sessions) | Streak, heatmap |
| Admin | Supabase | User management |
| Notifications | Drift, flutter_local_notifications | Due card reminders |

### Offline Strategy

**Content Availability:**
- All articles stored in local Drift database (`articles` table)
- Quiz questions stored in `quiz_table`
- View history in `view_history` table
- Study sessions in `study_sessions` table

**Sync Behavior (`lib/features/articles/data/article_repository.dart:42-110`):**
- On fetch failure (403/401/429/503/504/SocketException) → return cached data
- Callback to `sync_state_provider` updates UI state
- FTS5 index rebuilt on corruption (automatic recovery)

### Sync Pipeline

```
Article Sync Trigger:
  CategoriesScreen.initState → syncInBackground (if empty DB)
  FAB tap → syncInBackground

Repository.fetchAndSyncArticles:
  ├── Supabase.from('articles').select()
  ├── Drift transaction: insertOnConflictUpdate
  └── On error: return local cache

Quiz Sync Trigger:
  QuizScreen empty state → syncQuestions

Repository.fetchQuestions:
  ├── Supabase.from('questions').select()
  ├── Drift transaction: upsert
  └── On error: return local cache
```

### State Management Philosophy

**Riverpod Patterns Used:**

1. **StreamProvider** — Database streams (`allArticlesProvider`, `bookmarks`)
2. **FutureProvider** — One-time async data (`isSubscribedProvider`, category progress)
3. **StateNotifierProvider** — Mutable state (`sessionTimeoutProvider`, `syncStateProvider`, `QuizNotifier`)
4. **StateProvider** — Simple values (`bottomNavIndexProvider`, `themeModeProvider`)
5. **AsyncNotifierProvider.family** — Parameterized async state (`quizNotifierProvider`, `categoryProgressProvider`)

**No setState** — All state mutation goes through Riverpod providers.

### Navigation Philosophy

**GoRouter Configuration (`lib/main.dart:99-162`):**
- `/` → `InitialFlowGate` (onboarding/disclaimer gate)
- `/login`, `/signup` → Auth screens
- `/home` → `SubscriptionGuard` → `MainShell`
- `/disclaimer`, `/terms`, `/privacy` → Legal screens
- `/article-list/:category` → Article list by category
- `/article-detail` → Uses `state.extra` for `ArticleLocal`
- `/admin` → Redirect checks `isAdmin`

**Bottom Navigation (`lib/app/main_shell.dart`):**
- 6 tabs indexed 0-5: Library, Search, Saved, Quiz, Progress, Settings
- IndexedStack preserves state between tab switches
- Session timer reset on any user interaction

### Notification Pipeline (`lib/core/services/notification_service.dart`)

```
NotificationService.initialize():
  ├── Load timezone data
  ├── FlutterLocalNotificationsPlugin.initialize()
  ├── Android permission request (line 115)
  └── Schedule daily reminders at 8:00 AM

scheduleDueReminder(nextDueAt, dueCount):
  ├── Count due cards for date
  └── zonedSchedule with matchDateTimeComponents = time

_onNextDueAt query → schedule reminder
```

**Note:** Android 13+ requires runtime permission (MISSING in current code).