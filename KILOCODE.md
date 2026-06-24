# KILOCODE.md

## Flutter entry / routing (lib/main.dart)
- `main()`:
  - `WidgetsFlutterBinding.ensureInitialized()`
  - Loads `SharedPreferences` keys:
    - `hasSeenOnboarding` → `_seenOnboarding`
    - `hasSeenDisclaimer` → `_seenDisclaimer`
  - Initializes Supabase + database warmup (`SELECT 1`) + notification service
  - Runs `ProviderScope(child: MyApp())`
- `GoRouter`:
  - `initialLocation: '/'`
  - Route `'/'` uses `InitialFlowGate` (onboarding → disclaimer → MainShell)
  - Other routes include: `/login`, `/signup`, `/home` (AppEntrance), `/disclaimer`, `/terms`, `/privacy`, `/article-list/:category`, `/article-detail`, `/admin`

## Onboarding (lib/features/onboarding/onboarding_screen.dart)
- `OnboardingScreen` (Stateful)
  - `PageView` + `PageController`
  - 3 slides:
    1) `Icons.local_library` — “441 Clinical Articles”
    2) `Icons.flag` — “Built for Ethiopian Medicine”
    3) `Icons.quiz` — “EHPLE Exam Practice”
  - Dot indicators: 3 `AnimatedContainer`s (300ms)
  - Top-right `TextButton`: “Skip”
  - Bottom `ElevatedButton`: “Next” → “Get Started”
  - Skip/Get Started:
    - sets `SharedPreferences.setBool('hasSeenOnboarding', true)`
    - navigates to `DisclaimerScreen` if `hasSeenDisclaimer != true`, else to `MainShell`
  - **PageView wrapped in `Expanded`** to avoid unbounded Column/PageView layout bug

## Disclaimer (lib/features/legal/disclaimer_screen.dart)
- `DisclaimerScreen` is a StatelessWidget
- Has `onAccepted` callback required by constructor
- Text: Medical disclaimer copy
- Button: “I UNDERSTAND” → triggers `onAccepted`

## MainShell + bottom navigation (lib/app/main_shell.dart)
- `MainShell` is `ConsumerStatefulWidget`
- Bottom nav tab index stored in Riverpod provider (`bottomNavIndexProvider`, defined in `lib/app/nav_provider.dart`)
- Renders 5 tabs via `IndexedStack`:
  - Categories (0)
  - Article Search (1)
  - Bookmarks (2)
  - Settings (3)
  - Progress (4)
- Additional UI:
  - Offline banner: driven by `connectivityProvider`
  - Server unreachable banner: driven by `serverUnreachableProvider` and invalidates `allArticlesProvider` on retry

## Representative feature code paths (sampled from inspected files)

### Articles
- `ArticleListScreen` (lib/features/home/presentation/article_list_screen.dart)
  - Pagination state: multiple `StateProvider`s (offset, requestId, loadedArticles, etc.)
  - Uses providers from `lib/features/articles/data/article_repository.dart`
  - Includes subcategory chips and high-yield toggle in AppBar
- `ArticleDetailScreen` (lib/features/articles/presentation/article_detail_screen.dart)
  - AppBar bookmark stream updates from Drift (`db.bookmarks`)
  - Records:
    - streak update (`streakNotifierProvider.notifier.recordArticleRead()`)
    - `view_history` insert into custom table

### Progress
- `ProgressScreen` (lib/features/progress/progress_screen.dart)
  - Uses `progressNotifierProvider`
  - Heatmap / stats:
    - streak (current streak, total articles, quiz accuracy)
    - heatmap by date from `study_sessions`
    - category progress + quiz accuracy by category

### Quiz
- `QuizScreen` (lib/features/quiz/quiz_screen.dart)
  - Reads quiz questions by category using `quizNotifierProvider(category)`
  - On answer flow:
    - `notifier.recordReview(...)`
    - updates streak with `recordQuizResult(isCorrect)`
  - On completion:
    - saves state to Drift (`saveCurrentStateToDrift()`)
    - resets notifier and returns to previous screen (or navigates to `/home`)

### Admin / Settings
- `AdminDashboardScreen` (lib/features/admin/presentation/admin_dashboard_screen.dart)
  - Loads `adminUsersProvider`
  - Activates users using `AdminRepository.activateUser`
- `SettingsScreen` (lib/features/settings/presentation/settings_screen.dart)
  - `SwitchListTile` toggles `dailyStudyRemindersEnabledProvider`
  - Share + support links via `share_plus` and `url_launcher`
  - Legal links to `/terms` and `/privacy`
  - Logout via `authServiceProvider.signOut()` and routes to `/login`
