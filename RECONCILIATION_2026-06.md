# RECONCILIATION_2026-06.md

WardReady reconciliation check. Read-only. Date: 2026-06-28.

## 1. git log --oneline -30

```
f3ec3a2 fix: cap _searchAllArticles() result size to prevent unbounded FTS5 result sets
ce2daaa feat: article read-time estimate on cards
6990ede feat: today's plan card on home screen
536534d feat: retry wrong answers mini-session after quiz
09cd58f fix: proguard rules for Drift R8 obfuscation safety
cb8b6c8 fix: android:label corrected to WardReady
db50e1f fix: persist theme before updating provider state
78c673b fix: guard async callbacks with mounted checks
aabb458 chore: update android:label from ethiomed to WardReady
9607f74 fix: MaterialBanner actions not empty crash
7a44d78 fix: dark mode defaults to dark, toggle persists on restart
7704985 fix: Expanded replaced with Flexible in progress_screen.dart
184d54a fix: SM-2 columns added to QuizTable class definition
f474365 fix: deprecated ColorScheme fields updated for Flutter 3.18+
a3fef66 feat: dark mode redesign — navy-indigo palette
fa34640 fix: audit fixes — navigator, empty rows, repaintboundary, targetSdk
76d256a fix: article counts, progress tab, chip deselect, theme toggle
2b8b1aa security: 30-minute session timeout auto-logout
aa89290 security: 30-minute session timeout auto-logout
caba375 security: 30-minute session timeout auto-logout
f39e4ab fix: SM-2 migration guard, progress late field, unbounded flex layout
fe07d62 fix: back button canPop guard, WardReady branding, admin route guard, Chapa key removed, FLAG_SECURE
6cf30a1 fix: subcategoryFilter deferred past build in initState
8fbd939 fix: subcategory filter state modified after build
e80b96b fix: view_history ALTER TABLE no longer crashes on duplicate column
21f3f18 fix: drift database singleton — remove duplicate AppDatabase instantiation in NotificationService and main.dart
8565833 fix: dark mode contrast in article detail — explicit text colors
7064749 fix: migration version order — migrations 5+6 now execute correctly
59a389f fix: back button crash — guard context.pop with canPop check; drift database singleton — prevent multiple instances
8e9ad03 fix: filter chips now deselectable via provider pattern
```

## 2. Task verification (commit + code behavior)

| Task | Commit | Code matches? | Evidence |
|---|---|---|---|
| **A** — `android:label = WardReady` | `cb8b6c8` (prior attempt `aabb458`) | ✅ Yes | `AndroidManifest.xml:5` → `android:label="WardReady"` |
| **B** — POST_NOTIFICATIONS perm + runtime request | none dedicated | ✅ Yes (code present) | Manifest declares `android.permission.POST_NOTIFICATIONS`; runtime request in `notification_service.dart` → `androidPlugin?.requestNotificationsPermission()` inside `initialize()`. Code touched via `fa34640` / `21f3f18`, no single dedicated commit. |
| **C** — `android:allowBackup = false` | none dedicated | ✅ Yes (code present) | `AndroidManifest.xml` → `android:allowBackup="false"`. Set as part of the `fe07d62` hardening pass; no dedicated commit. |
| **D** — proguard Drift keep rules | `09cd58f` | ✅ Yes | `proguard-rules.pro` keeps `io.requery.**`, `androidx.sqlite.**`, `@androidx.room.Database`, `drift.**` members, `-dontwarn drift.**` |
| **E** — retry-wrong-answers mini-session | `536534d` | ✅ Yes | `quiz_screen.dart:328-338` — on last question, if `wrongAnswerCount > 0` shows `_showRetryScreen`; "Review Wrong Answers?" dialog offers Skip / retry via `notifier.loadQuestionsByIds(wrongQuestionIds)`. `wrongAnswerCount`/`wrongQuestionIds` exposed in `quiz_notifier.dart:64-66`. |
| **H** — edge-to-edge inset handling | **NONE** | ❌ **No** | No `enableEdgeToEdge` / `setDecorFitsSystemWindows` in `MainActivity.kt` (it only sets `FLAG_SECURE`). No `SystemChrome.setEnabledSystemUIMode(edgeToEdge)` in Dart. Only inset handling present is ordinary `SafeArea` on several screens. Behavior and commit both absent. |
| **I** — `secondaryContainer` in darkTheme | `a3fef66` (dark redesign) | ⚠️ Partial | `lib/core/theme/app_theme.dart` defines a dark `ColorScheme` but does **not** populate the `secondaryContainer` slot — it sets `secondary: Color(0xFF7986CB)` and omits `secondaryContainer` entirely. Dark theme exists; the literal `secondaryContainer` value the task names is not set. |
| **J** — AAB build readiness (signing config, versionCode) | none dedicated | ✅ Yes (code present) | `build.gradle.kts`: `versionCode = 1`, `versionName = "1.0.0"`, `signingConfigs { create("release") { ... } }`, release build type wired to `signingConfigs.getByName("release")` with minify+shrink+proguard. `key.properties` loaded at top. No dedicated commit; configuration is in place. |
| **K** — `_searchAllArticles()` pagination limit | `f3ec3a2` | ✅ Yes | `article_search_provider.dart:214-234` — query is `SELECT * FROM articles LIMIT ?` bound to `_maxSearchResults`; caller also `.take(_maxSearchResults)`. Bounded. |

### Summary of section 2
- **Fully present (commit + behavior):** A, D, E, K — 4 tasks.
- **Behavior present, no dedicated commit:** B, C, J — 3 tasks (folded into audit/hardening commits).
- **Not present:** H — edge-to-edge. No commit, no code.
- **Partial:** I — dark theme exists but `secondaryContainer` slot is not actually populated.

## 3. Commits NOT accounted for by tasks A–K (the "few others")

These have no corresponding A–K task. One line each, files touched:

- `ce2daaa` feat: article read-time estimate on cards — `app_database.dart`, `article.dart`, `article_search_screen.dart`, `article_list_screen.dart`
- `6990ede` feat: today's plan card on home screen — `categories_screen.dart`
- `db50e1f` fix: persist theme before updating provider state — `settings_screen.dart`
- `78c673b` fix: guard async callbacks with mounted checks — `main_shell.dart`, `app_config.dart`, `app_theme.dart`, `article_repository.dart`, `article_search_provider.dart`, `article_list_screen.dart`, `categories_screen.dart`
- `9607f74` fix: MaterialBanner actions not empty crash — `offline_banner.dart`
- `7704985` fix: Expanded → Flexible in progress_screen — `progress_screen.dart`
- `184d54a` fix: SM-2 columns added to QuizTable — `app_database.dart`, `app_database.g.dart`, `exam_session_notifier.dart`, `quiz_repository.dart`, `spaced_repetition_service.dart` *(note: touches the locked SM-2 file)*
- `fa34640` fix: audit fixes (navigator, empty rows, repaintboundary, targetSdk) — `build.gradle.kts`, `notification_service.dart`, `onboarding_screen.dart`, `progress_screen.dart`, `spaced_repetition_service.dart` *(note: touches the locked SM-2 file)*
- `76d256a` fix: article counts, progress tab, chip deselect, theme toggle — `app_database.dart`, `categories_screen.dart`, `progress_notifier.dart`, `search_screen.dart`, `settings_screen.dart`, `main.dart`
- `2b8b1aa` security: 30-min session timeout auto-logout — `session_timeout_provider.dart`
- `aa89290` security: 30-min session timeout auto-logout — `main_shell.dart`, `session_timeout_provider.dart`
- `caba375` security: 30-min session timeout auto-logout — `main_shell.dart`, `session_timeout_provider.dart`, `login_screen.dart`, `main.dart`
- `f39e4ab` fix: SM-2 migration guard, progress late field, unbounded flex — `app_database.dart`, `progress_notifier.dart`, `quiz_screen.dart`
- `6cf30a1` fix: subcategoryFilter deferred past build in initState — `article_list_screen.dart`
- `8fbd939` fix: subcategory filter state modified after build — `article_list_screen.dart`
- `e80b96b` fix: view_history ALTER TABLE no crash on duplicate column — `app_database.dart`
- `21f3f18` fix: drift DB singleton (remove duplicate AppDatabase) — `app_database.dart`, `notification_service.dart`, `spaced_repetition_service.dart`, `main.dart` *(note: touches the locked SM-2 file)*
- `8565833` fix: dark mode contrast in article detail — `article_detail_screen.dart`
- `7064749` fix: migration version order (5+6 execute correctly) — `app_database.dart`
- `59a389f` fix: back button crash canPop guard + drift singleton — `app_database.dart`, `article_detail_screen.dart`
- `8e9ad03` fix: filter chips deselectable via provider pattern — `search_screen.dart`

**Flags worth noting (no action taken, read-only):**
- Three commits (`184d54a`, `fa34640`, `21f3f18`) modify `lib/features/quiz/spaced_repetition_service.dart`, which AGENTS.md marks as **LOCKED — never modify**. Worth confirming those edits were SM-2-math-neutral if that matters for the audit.
- `f474365` (deprecated ColorScheme fields) and `7a44d78` (dark mode defaults to dark) are also unaccounted small fixes — `f474365` not shown in the file-touched batch above; both are benign.

## 4. flutter analyze

Command: `C:\flutter\bin\flutter.bat analyze`

```
Analyzing ethiomed...
No issues found! (ran in 211.3s)
```

**Result: clean. Zero issues.**

## 5. Bottom line

- 30 commits in window. 4 map cleanly to named tasks (A, D, E, K); 3 more have the behavior present without a dedicated commit (B, C, J).
- **Task H (edge-to-edge) is missing entirely** — no commit, no code. This is the only task in the set with no implementation.
- **Task I is partial** — dark theme exists, but the `secondaryContainer` slot named in the task is not populated.
- Everything else reconciles. `flutter analyze` is clean.

End of report. Stopping here — no files edited other than this one.
