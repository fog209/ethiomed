# WardReady — Feature Guide

## Authentication

**Purpose:** User identity, session management, secure token storage

**Files:**
- Service: `lib/features/auth/data/auth_service.dart`
- Presentation: `lib/features/auth/presentation/login_screen.dart`, `signup_screen.dart`
- Provider: `lib/main.dart:13-15`

**Repositories:** `AuthService` (owns: Supabase client, FlutterSecureStorage)

**Providers:**
- `authServiceProvider` — singleton AuthService instance
- `authSessionProvider` — `StreamProvider<Session?>` from Supabase auth state
- `authControllerProvider` — `StateNotifierProvider<AuthController, AuthUiState>`

**Database Tables:** None (tokens in SecureStorage)

**Routes:** `/login`, `/signup` (no guard, accessible to all)

**Dependencies:**
- `supabase_flutter` — Auth client
- `flutter_secure_storage` — Token persistence

**Failure Modes:**
- Network failure → Sign in error
- Expired session → Silent 401 on API calls, redirect to login
- Rooted device → Tokens can be extracted (accepted risk)

**Future Extension:**
- Password recovery via Supabase magic links
- Biometric auth (fingerprint/Face ID)

---

## Onboarding

**Purpose:** First-launch introduction to app features

**Files:**
- `lib/features/onboarding/onboarding_screen.dart`

**Repositories:** None

**Providers:** None (direct SharedPreferences access)

**Database Tables:** None

**Routes:** Handled in `InitialFlowGate` at `/` route

**Dependencies:** None

**Failure Modes:**
- SharedPreferences save failure → Onboarding repeats
- Skip button navigates to disclaimer (line 24-36)

**Future Extension:**
- Dynamic slide content from remote config
- User preference collection during onboarding

---

## Disclaimer

**Purpose:** Legal acknowledgment before app access

**Files:**
- `lib/features/legal/disclaimer_screen.dart`
- `lib/features/legal/terms_screen.dart`
- `lib/features/legal/privacy_screen.dart`
- `lib/features/legal/terms_content.dart`
- `lib/features/legal/privacy_content.dart`

**Repositories:** None

**Providers:** None (direct SharedPreferences)

**Database Tables:** None

**Routes:** `/disclaimer`, `/terms`, `/privacy`

**Dependencies:** None

**Failure Modes:**
- User cannot proceed without clicking "I Understand"
- Legal screens accessible anytime via Settings

**Future Extension:**
- Remote legal content management
- Version acceptance tracking

---

## Articles

**Purpose:** Offline medical content library

**Files:**
- Repository: `lib/features/articles/data/article_repository.dart`
- Presentation: `lib/features/articles/presentation/article_list_screen.dart`, `article_detail_screen.dart`
- Search: `lib/features/articles/data/article_search_provider.dart`
- Providers: `lib/features/articles/article_providers.dart`

**Repositories:** `ArticleRepository`

**Providers:**
- `articleRepositoryProvider` — singleton
- `allArticlesProvider` / `articlesProvider` — Stream all articles
- `paginatedArticlesProvider` — Family for paging
- `articlesCountInCategoryProvider` — Future count per category
- `highYieldModeProvider` — Toggle for focused study
- `subcategoryFilterProvider` — Filter by subcategory

**Database Tables:**
- `articles` — Content storage
- `article_search_fts` — FTS5 virtual table for search

**Routes:** `/article-list/:category`, `/article-detail`

**Dependencies:**
- `drift` — Local database
- `supabase_flutter` — Remote content sync
- `cached_network_image` — Image caching
- `flutter_markdown` — Content rendering

**Failure Modes:**
- Sync failure → Cached data shown
- FTS5 corruption → Full table scan fallback
- Malformed JSON → Empty sections

**Future Extension:**
- Deep linking to specific articles
- Bookmark folders/collections

---

## Quiz

**Purpose:** MCQ practice with SM-2 spaced repetition

**Files:**
- `lib/features/quiz/quiz_screen.dart` — UI
- `lib/features/quiz/quiz_notifier.dart` — State management
- `lib/features/quiz/quiz_repository.dart` — Data layer
- `lib/features/quiz/quiz_sync_service.dart` — Sync wrapper
- `lib/features/quiz/spaced_repetition_service.dart` — SM-2 algorithm
- `lib/features/quiz/exam_session_notifier.dart` — EHPLE exam mode
- `lib/features/quiz/weakness_service.dart` — Learning radar

**Repositories:** `QuizRepository`

**Providers:**
- `quizRepositoryProvider` — singleton
- `quizNotifierProvider` — Family by category for quiz state
- `quizSyncServiceProvider` — Wraps sync
- `spacedRepetitionServiceProvider` — SM-2 logic
- `weaknessServiceProvider` — Weak field detection
- `weakFieldsProvider` — Family by article ID

**Database Tables:**
- `quiz_table` — Questions with SM-2 columns (`ease_factor`, `sr_interval`, `repetitions`, `next_due_at`, `last_quality`)

**Routes:** No dedicated route (embedded in MainShell tab 3)

**Dependencies:**
- `timezone` — Next due calculation
- `flutter_local_notifications` — Reminders

**Failure Modes:**
- Question fetch fails → Local cache
- Review write fails → User sees error
- Exam mode N+1 queries → Slow start (performance issue)

**Future Extension:**
- Exam mode UI (`/exam` route missing)
- Review explanations from remote

---

## Progress

**Purpose:** Study streak, heatmap, category completion tracking

**Files:**
- `lib/features/progress/progress_screen.dart` — UI
- `lib/features/progress/progress_notifier.dart` — Data aggregation
- `lib/features/progress/streak_notifier.dart` — Stats calculation
- `lib/features/progress/category_progress_provider.dart` — Per-category progress

**Repositories:** None (direct Drift access)

**Providers:**
- `progressNotifierProvider` — Aggregates all progress data
- `streakNotifierProvider` — Streak calculation

**Database Tables:**
- `study_sessions` — Daily aggregate data
- `view_history` — Article view timestamps
- `quiz_table` — For accuracy calculation

**Routes:** Tab 4 in MainShell (`/progress` implied)

**Dependencies:** None

**Failure Modes:**
- Migration incomplete → Returns 0s gracefully
- No session data → Streak shows 0

**Future Extension:**
- Monthly/yearly statistics
- Achievement badges

---

## Search

**Purpose:** Full-text article search with FTS5

**Files:**
- `lib/features/articles/presentation/article_search_screen.dart` — Search UI
- `lib/features/articles/data/article_search_provider.dart` — Logic
- `lib/features/search/search_history_service.dart` — History persistence

**Repositories:** `ArticleSearchRepository`

**Providers:**
- `articleSearchControllerProvider` — Search state
- `articleSearchRepositoryProvider` — Repository

**Database Tables:** `article_search_fts` virtual table

**Routes:** Tab 1 in MainShell (`/search` implied)

**Dependencies:** `sqlite3` (for FTS5 parsing)

**Failure Modes:**
- FTS5 corruption → Falls back to full scan
- Empty query → All articles returned

**Future Extension:**
- Recent searches UI
- Saved searches

---

## Bookmarks

**Purpose:** Save articles for later review

**Files:**
- `lib/features/bookmarks/presentation/bookmarks_screen.dart` — UI

**Repositories:** None (direct Drift access)

**Providers:** None (StreamBuilder in screen)

**Database Tables:** `bookmarks` — One row per saved article

**Routes:** Tab 2 in MainShell (`/bookmarks` implied)

**Dependencies:** None

**Failure Modes:**
- Database full → Insert fails silently

**Future Extension:**
- Bookmark folders
- Export bookmarks

---

## Settings

**Purpose:** User preferences and account management

**Files:**
- `lib/features/settings/presentation/settings_screen.dart`

**Repositories:** None

**Providers:**
- `dailyStudyRemindersEnabledProvider` — Toggle state
- `themeModeProvider` — App theme

**Database Tables:** None (SharedPreferences)

**Routes:** Tab 5 in MainShell

**Dependencies:** `share_plus`, `url_launcher`

**Failure Modes:**
- Logout error → Silent (no try/catch)
- Notification enable error → Silent

**Future Extension:**
- Account deletion
- Data export

---

## Admin

**Purpose:** Subscription management for admin users

**Files:**
- Repository: `lib/features/admin/data/admin_repository.dart`
- Presentation: `lib/features/admin/presentation/admin_dashboard_screen.dart`

**Repositories:** `AdminRepository`

**Providers:**
- `adminRepositoryProvider` — Singleton
- `adminUsersProvider` — All users list
- `currentAdminProfileProvider` — Is admin check

**Database Tables:** None (Supabase only)

**Routes:** `/admin` (redirect guarded)

**Dependencies:** `supabase_flutter`

**Failure Modes:**
- Non-admin → Redirect to /home
- List unpaginated → OOM at scale

**Future Extension:**
- Pagination for user list
- Subscription analytics

---

## Notifications

**Purpose:** SM-2 due card reminders

**Files:**
- `lib/core/services/notification_service.dart`

**Repositories:** None

**Providers:**
- `notificationServiceProvider`
- `dailyStudyRemindersEnabledProvider`

**Database Tables:** Queries `quiz_table` for due counts

**Routes:** None

**Dependencies:** `flutter_local_notifications`, `timezone`

**Failure Modes:**
- Android 13+ → Notifications fail silently (permission missing)
- Multiple devices → Each schedules independently

**Future Extension:**
- Custom reminder time
- Snooze functionality