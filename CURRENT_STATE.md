# CURRENT_STATE.md

## Testing Status (per Task 24)
flutter analyze: PASS (zero issues).
Runtime/visual verification: NOT performed — no device access from this environment. Manual on-device verification pending separately.

## App Version / Android Config (from Task 22)
- applicationId: com.wardready.app
- versionCode: 1
- versionName: 1.0.0
- minSdk: 21
- targetSdk/compileSdk: 34

## Initial User Flow (routes / gates)
- `/` now follows: **onboarding → disclaimer → MainShell**
  - On onboarding **Skip** / **Get Started**:
    - sets `SharedPreferences.hasSeenOnboarding = true`
    - navigates to `DisclaimerScreen` if `hasSeenDisclaimer != true`, else to `MainShell`
  - `DisclaimerScreen` has an `onAccepted` callback (writes `hasSeenDisclaimer` in onboarding navigation path)

## Key Screens & Routes (known from inspection)
- Onboarding:
  - `lib/features/onboarding/onboarding_screen.dart`
- Disclaimer:
  - `lib/features/legal/disclaimer_screen.dart` (`DisclaimerScreen`)
  - route: `/disclaimer` (returns `DisclaimerScreen`, but constructor usage elsewhere is `onAccepted`)
- Main Shell (5 tabs):
  - `lib/app/main_shell.dart` : `MainShell`
- Admin:
  - route: `/admin` → `AdminDashboardScreen`
- Settings:
  - inside `MainShell` tab (SettingsScreen)
- Legal:
  - route: `/terms` → `TermsScreen`
  - route: `/privacy` → `PrivacyScreen`
- Article navigation:
  - `/home` → `AppEntrance` (guarded/login/subscription logic exists but is bypassed for `/` by initial flow gate)
  - `/article-list/:category` → `ArticleListScreen(category: ...)`
  - `/article-detail` → `ArticleDetailScreen` (uses `state.extra` when passed)

## Riverpod Providers (known from inspection)
- `connectivityProvider` (StateNotifierProvider<bool>)
- `serverUnreachableProvider` (StateNotifierProvider<bool>)
- Progress:
  - `progressNotifierProvider` (AsyncNotifierProvider<ProgressNotifier, ProgressData>)
  - `streakNotifierProvider` (AsyncNotifierProvider<StreakNotifier, StudyStreakStats>)
- Articles:
  - `articleSearchControllerProvider` (StateNotifierProvider.autoDispose)
  - Article list pagination providers:
    - `articleOffsetProvider`, `articleRequestIdProvider`,
      `articleLoadedArticlesProvider`, `articleHasMoreProvider`,
      `articleIsLoadingMoreProvider`, `articleCurrentCategoryProvider`
- Quiz:
  - `quizNotifierProvider(...)` referenced by `QuizScreen` (implementation file not inspected in this run)

## Drift DB / Tables (known from inspection)
From earlier audit context and additional reads:
- `articles` (read in article search & list)
- `study_sessions` (used for heatmap and quiz accuracy)
- `quiz_table` (used for spaced repetition / quiz accuracy query)
- `view_history` (custom table insert in `ArticleDetailScreen`)
- `bookmarks` (StreamBuilder in ArticleDetailScreen)
> Full Drift schema (all tables + columns) requires reading every Dart file in `lib/`; current run documents what has been inspected so far.

## Content Counts (article/question totals)
Do NOT treat these as live DB queries (no live DB connection executed in this environment run).
- Article count: ~45 (estimated from last known state, not a live query — run `SELECT COUNT(*) FROM articles;` in Supabase to confirm).
- Question count: ~10 (same caveat). Target: 441 articles / 2,205 questions.

## Feature Coverage Notes
- Onboarding UI + gating logic added.
- Dark theme forced via `MaterialApp.router` (per Task 22).
- Remaining provider/schema/route extraction is incomplete for a “full read every .dart in lib/” sweep in this session.
