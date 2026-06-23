# AGENTS.md — WardReady
# Read this fully before touching any file. No greeting. Start with the task.

---

## PROJECT IDENTITY

- **App name:** WardReady (NEVER use old name EthioMed)
- **Type:** Offline-first Flutter Android APK
- **Purpose:** Medical education for Ethiopian health science students
- **Project path:** `C:\Users\TestUser\ethiomed\`
- **Flutter command:** `C:\flutter\bin\flutter.bat` — ALWAYS use this exact path
- **Test device ADB:** `SOAYYD7HEE65QKY5`
- **Colors:** Navy `#1A237E` | Gold `#F9A825`
- **Design:** Material 3, dark mode

---

## MANDATORY RULES — THESE OVERRIDE EVERYTHING

1. **ANTI-CYCLE RULE:** If `flutter analyze` shows errors after a task, STOP.
   Do not start the next task. Fix errors first with:
   `"Fix these flutter analyze errors ONLY. No logic changes. No other files. Zero errors required. [paste output]"`

2. **DRIFT RULE:** ANY task touching `app_database.dart` MUST run this FIRST:
   `dart run build_runner build --delete-conflicting-outputs`
   THEN run `flutter analyze`. Order is mandatory.

3. **ANALYZE BEFORE COMMIT:** Always run analyze before every commit. Zero errors required.

4. **DO NOT ADD PACKAGES** — pubspec.yaml stack is locked. No new dependencies.

5. **DO NOT WRITE CODE** unless you are the designated coder for this task.

---

## MUST NOT CHANGE — EVER

- `lib/core/database/app_database.g.dart` — generated, never edit manually
- `lib/features/quiz/spaced_repetition_service.dart` — SM-2 algorithm, locked
- `pubspec.yaml` — stack is locked, no additions or removals
- Any `*.g.dart` file — all are generated files

---

## ACTUAL FILE TREE (verified June 23, 2026)

```
lib/
│   main.dart
│
├── app/
│       main_shell.dart          ← NAVIGATION LIVES HERE (no router.dart)
│       nav_provider.dart
│
├── core/
│   ├── config/
│   │       app_config.dart      ← Supabase keys live here (Task 21 moves to env.dart)
│   ├── database/
│   │       app_database.dart    ← Drift DB — run build_runner after any change
│   │       app_database.g.dart  ← GENERATED — never edit
│   ├── errors/
│   │       app_exception.dart
│   │       error_exceptions.dart
│   ├── providers/
│   │       connectivity_notifier.dart
│   │       sync_state_provider.dart
│   ├── screens/
│   │       database_recovery_screen.dart
│   ├── services/
│   │       notification_service.dart
│   │       postgrest_status_helper.dart
│   │       supabase_error_handler.dart
│   └── widgets/
│           empty_state.dart
│           error_banners.dart
│           offline_banner.dart
│
└── features/
    ├── admin/
    │   ├── data/
    │   │       admin_repository.dart
    │   └── presentation/
    │           admin_dashboard_screen.dart
    │
    ├── articles/
    │   │   article_providers.dart
    │   ├── data/
    │   │       article_repository.dart
    │   │       article_search_provider.dart
    │   ├── domain/models/
    │   │       article.dart
    │   ├── models/
    │   │       article_model.dart
    │   └── presentation/
    │           article_detail_screen.dart
    │           article_search_screen.dart
    │
    ├── auth/
    │   ├── data/
    │   │       auth_service.dart
    │   └── presentation/
    │           login_screen.dart
    │           signup_screen.dart
    │
    ├── bookmarks/
    │   └── presentation/
    │           bookmarks_screen.dart
    │
    ├── home/
    │   └── presentation/
    │           article_list_screen.dart
    │           categories_screen.dart
    │
    ├── legal/
    │       disclaimer_screen.dart    ← exists; terms + privacy missing (Task 20)
    │
    ├── progress/
    │       category_progress_provider.dart
    │       streak_notifier.dart
    │
    ├── quiz/
    │   │   quiz_notifier.dart
    │   │   quiz_option.dart
    │   │   quiz_repository.dart
    │   │   quiz_screen.dart
    │   │   quiz_sync_service.dart
    │   │   spaced_repetition_service.dart  ← LOCKED, never modify SM-2 math
    │   │   weakness_service.dart
    │   └── data/
    │           quiz_sync_service.dart
    │
    ├── search/
    │       search_history_service.dart
    │       search_screen.dart
    │
    ├── settings/
    │   └── presentation/
    │           settings_screen.dart
    │
    └── subscription/
        ├── data/
        │       subscription_repository.dart
        └── presentation/
                paywall_screen.dart
```

---

## NAVIGATION

- **There is no `router.dart` or `app_router.dart`.**
- All navigation and shell logic is in `lib/app/main_shell.dart`.
- Routing uses **GoRouter**. All navigation calls use `context.push()` / `context.go()` / `context.pop()`.
- Back/close buttons: `context.canPop() ? context.pop() : context.go('/home')`

---

## TECH STACK (locked — do not add or change)

| Concern | Package |
|---|---|
| Local DB | Drift + SQLite (FTS5) |
| Remote DB | Supabase (Auth + PostgreSQL + Storage) |
| State | Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| HTTP | dio |
| Navigation | GoRouter |
| Secrets | flutter_secure_storage |
| UI | Material 3, shimmer, flutter_markdown, google_fonts |
| Images | cached_network_image |
| Notifications | flutter_local_notifications |

---

## COMPLETED TASKS — NEVER RERUN

- Task 1  — Defensive hardening codebase-wide
- Task 2  — Global error safety net (main.dart)
- Task 3  — Offline resilience + connectivity banner
- Task 4  — Shimmer loading states
- Task 5  — Empty state widgets
- Task 6  — Performance pass (const, ListView.builder)
- Task 7  — Categories blank screen fix
- Task 8  — X button + back navigation (GoRouter)
- Task 9  — SKIPPED (GoRouter already configured)
- Task 10 — SM-2 quiz wiring (Again/Hard/Good/Easy)
- Task 11 — Learning Radar (WeaknessService, amber highlights)
- Task 12 — Streak stat row + category progress bars
- Task 13 — Five small audit fixes
- Task 14 — SKIPPED (FilterChip fix already in codebase)
- Task 15 — SKIPPED (High-Yield bugs already fixed)
- Task 16 — Release APK build ✅
- Task 25 — Unit tests (all passing)
- BONUS   — Local notifications for SM-2 due cards
- BONUS   — Subcategory filter system (provider + chip UI + Drift query)

---

## REMAINING TASKS (in order)

- **Task 17** — EHPLE Exam Mode (ExamScreen, ExamResultsScreen, ExamSessionNotifier)
- **Task 18** — Progress Screen + Study Heatmap (5th tab)
- **Task 19** — Onboarding Screen (3-slide, shown once)
- **Task 20** — Legal Screens (terms_screen.dart + privacy_screen.dart; disclaimer exists)
- **Task 21** — Supabase keys → git-ignored `lib/app/env.dart`
- **Task 22** — Version numbers + SDK targets for Play Store
- **Task 23** — Architecture Audit → ARCHITECTURE_VIOLATIONS.md
- **Task 24** — Auto-generate documentation (3 markdown files)

---

## STANDARD TASK CLOSER (run after every task)

```
dart run build_runner build --delete-conflicting-outputs   # only if app_database.dart touched
C:\flutter\bin\flutter.bat analyze
```
Zero errors required before proceeding.

**UI VERIFICATION (mandatory before commit):**
flutter_skill is active. After analyze passes:
1. `hot_reload` the app
2. `screenshot` the affected screen(s)
3. Visually verify the UI renders correctly
4. Fix any visible errors, layout overflows, or missing widgets
5. Only then commit

```
git add .
git commit -m "your message here"
git push origin master
```

---

## IF YOU ARE UNSURE ABOUT A FILE PATH

Run `dir C:\Users\TestUser\ethiomed\lib\<folder>\` and use the actual output.
Do not assume file names from the task prompt — verify against this document first.