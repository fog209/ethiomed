# FEATURE_STATUS.md

## Overview (read-only docs)
This file summarizes feature readiness/status based on code inspection performed in this session. It does **not** reflect full repo-wide coverage of every file under `lib/` (read-only sweep remains incomplete).

## Feature status legend
- **LIVE**: implemented and wired through UI/navigation/providers
- **STUB/Partial**: present but incomplete or only partially wired
- **MISSING**: not found / not implemented

## Onboarding + Disclaimer
- **Onboarding (3 slides, dots, Skip/Get Started)**: **LIVE**  
  - `lib/features/onboarding/onboarding_screen.dart`
- **Disclaimer screen**: **LIVE**  
  - `lib/features/legal/disclaimer_screen.dart`
  - Requires `onAccepted` callback; onboarding navigation uses the callback path.
- **Initial flow gate (route `/` → onboarding → disclaimer → MainShell)**: **LIVE** (partial wiring)
  - Implemented in `lib/main.dart` via `InitialFlowGate`

## Main app shell / navigation
- **Bottom navigation + 5 tabs**: **LIVE**  
  - `lib/app/main_shell.dart` (Categories, Search, Saved, Settings, Progress)
- **Offline banner**: **LIVE**  
  - Driven by `connectivityProvider`
- **Server unreachable banner**: **LIVE**  
  - Driven by `serverUnreachableProvider`, retry invalidates `allArticlesProvider` (provider name referenced in shell)

## Articles
- **Article browsing by category**: **LIVE**  
  - `ArticleListScreen` with pagination + subcategory chips + high-yield toggle
- **Article search**: **LIVE**  
  - `ArticleSearchScreen` + Riverpod controller/repository (FTS5 index)
- **Article detail + weak/high-yield sections**: **LIVE**  
  - Bookmarks stream from Drift
  - Records view history into custom `view_history`

## Bookmarks / Saved
- **Bookmarks screen**: **STUB/Partial** (not inspected in this session)
  - `lib/features/bookmarks/presentation/bookmarks_screen.dart` not read here.

## Quiz / spaced repetition
- **Quiz UI**: **LIVE (UI)**  
  - `lib/features/quiz/quiz_screen.dart`
- **Quiz logic / notifier / recording**: **LIVE (partially inspected)**  
  - `quizNotifierProvider(...)` referenced but notifier file(s) beyond UI were not inspected in this session.
- **Spaced repetition storage (Drift `quiz_table`)**: **LIVE** (schema referenced; logic partially inspected)
  - Not all quiz-related providers/services were inspected.

## Progress / streaks
- **Progress screen (heatmap + stats)**: **LIVE**  
  - `lib/features/progress/progress_screen.dart`
- **Streak notifier + quiz accuracy**: **LIVE**  
  - `lib/features/progress/streak_notifier.dart`
- **Progress notifier (category progress + quiz accuracy by category)**: **LIVE**  
  - `lib/features/progress/progress_notifier.dart`

## Settings
- **Settings UI**: **LIVE**  
  - `lib/features/settings/presentation/settings_screen.dart`
- **Daily reminders toggle**: **LIVE**  
  - Driven by `dailyStudyRemindersEnabledProvider` (file not read here)
- **Share links**: **LIVE**  
  - Uses `share_plus`
- **Legal links**: **LIVE**  
  - Routes `/terms`, `/privacy`
- **Admin entry**: **LIVE**  
  - Conditional render based on `currentAdminProfileProvider`

## Admin
- **Admin dashboard route**: **LIVE**
  - `lib/features/admin/presentation/admin_dashboard_screen.dart`
- **Activate user**: **LIVE** (repository inspected)
  - `lib/features/admin/data/admin_repository.dart`

## Legal / policy pages
- **Terms**: **LIVE**
- **Privacy**: **LIVE**
  - (Screens exist; content files opened earlier in session)
