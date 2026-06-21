# AUDIT_REPORT

Scope: read-only audit of `lib/` only. Generated `*.g.dart` files, `build/`, `.dart_tool/`, `android/`, and `ios/` were not read.

## lib/core/
- [SEVERITY: high] core/config/app_config.dart:6,9,12 — Chapa public key and Supabase URL/anon key are hardcoded in source, violating the no-hardcoded-API-keys rule.
- [SEVERITY: high] core/database/app_database.dart:197-263 — `study_sessions` schema/data is managed with raw SQLite `customStatement` calls instead of Drift-managed tables.
- [SEVERITY: high] core/database/app_database.dart:299-316 — `view_history` is created and altered with raw SQLite instead of Drift.
- [SEVERITY: high] core/database/app_database.dart:95-101 — Migration drops the legacy `quizQuestions` table for existing v3 databases without copying data into `quizTable`.
- [SEVERITY: medium] core/database/app_database.dart:158-179 — `countCurrentStudyStreak` reads a `DateTimeColumn` as `String`, which can cause local progress counting errors.
- [SEVERITY: high] core/services/notification_service.dart:204-269 — Due-card reminder logic uses raw SQLite `customSelect` against `quiz_table` instead of Drift.
- [SEVERITY: low] core/widgets/empty_state.dart:55 — `actionLabel!` is unnecessary after the null guard and should use `??` or a local non-null value.
- [SEVERITY: low] core/services/notification_service.dart:241-246 — Emoji text is embedded in code; remove unless explicitly requested.

## lib/features/auth/
- [SEVERITY: low] features/auth/data/auth_service.dart:263-265 — `supabaseUrl` getter appears unused and can be removed.

## lib/features/home/
- [SEVERITY: medium] features/home/presentation/categories_screen.dart:97-105 — Manual article sync is launched with `unawaited` and has no error feedback if sync fails.
- [SEVERITY: low] features/home/presentation/categories_screen.dart:111-129 — `_buildBodyItems` is called twice per build, causing duplicated list allocation.
- [SEVERITY: low] features/home/presentation/categories_screen.dart:254-255 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.
- [SEVERITY: low] features/home/presentation/article_list_screen.dart:21-24 — Hardcoded subcategory map duplicates category configuration that should come from a shared source.
- [SEVERITY: low] features/home/presentation/article_list_screen.dart:407-408 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.

## lib/features/articles/
- [SEVERITY: high] features/articles/data/article_repository.dart:22-55 — `PostgrestException` during article sync is converted to local-cache success instead of throwing an `AppException` for the UI/provider to surface.
- [SEVERITY: medium] features/articles/data/article_repository.dart:68-119 — Article query filtering/ordering logic is duplicated across `watchLocalArticles`, `watchArticlesPaged`, and `fetchArticlesPage`.
- [SEVERITY: high] features/articles/data/article_search_provider.dart:228-259 — Article search FTS index is created, cleared, and populated with raw SQLite `customStatement` calls.
- [SEVERITY: medium] features/articles/data/article_search_provider.dart:189-224 — Article search reads from a raw FTS table with `customSelect` instead of Drift.
- [SEVERITY: medium] features/articles/data/article_search_provider.dart:268-284 — `_getIndexedCount` swallows FTS index errors and returns `0`, which can hide index corruption.
- [SEVERITY: high] features/articles/presentation/article_detail_screen.dart:72-91 — Article view history is inserted with raw SQLite `customSelect` instead of Drift.
- [SEVERITY: medium] features/articles/presentation/article_detail_screen.dart:143-157 — Bookmark insert/delete is not wrapped in try/catch, so local DB failures can bubble unhandled.
- [SEVERITY: low] features/articles/presentation/article_detail_screen.dart:245-246 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.
- [SEVERITY: low] features/articles/presentation/article_detail_screen.dart:301-399 — Emoji text is embedded in section titles; remove unless explicitly requested.
- [SEVERITY: medium] features/articles/models/article_model.dart:38-55 — Article content parsing uses unchecked `as String?` casts for many fields and can crash on malformed JSON.
- [SEVERITY: medium] features/articles/domain/models/article.dart:20-34 — Remote article parsing uses unchecked casts for required fields and should validate types before construction.

## lib/features/search/
- [SEVERITY: low] features/search/search_screen.dart:9-220 — This search screen duplicates functionality in `features/articles/presentation/article_search_screen.dart`.
- [SEVERITY: medium] features/search/search_screen.dart:60-64,152-158 — `saveSearch` futures are invoked without `await` or `unawaited`, making failures harder to handle.
- [SEVERITY: low] features/search/search_screen.dart:194-195 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.
- [SEVERITY: medium] features/search/search_history_service.dart:10-25 — SharedPreferences reads/writes for search history have no try/catch error handling.

## lib/features/bookmarks/
- [SEVERITY: low] features/bookmarks/presentation/bookmarks_screen.dart:15-18 — Query comment explains implementation details and can be removed.

## lib/features/admin/
- [SEVERITY: medium] features/admin/data/admin_repository.dart:28-33 — Subscription data is cast with `as Map<String, dynamic>`, which can crash on malformed Supabase responses.
- [SEVERITY: low] features/admin/data/admin_repository.dart:61 — `DEBUG_ADMIN` debug output should be removed before release.
- [SEVERITY: low] features/admin/data/admin_repository.dart:115-119 — Error messages say “Admin activate error” while checking the admin profile.
- [SEVERITY: medium] features/admin/presentation/admin_dashboard_screen.dart:109-111 — Admin dashboard error UI displays the raw error object.
- [SEVERITY: low] features/admin/presentation/admin_dashboard_screen.dart:119-120 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.

## lib/features/settings/
- [SEVERITY: medium] features/settings/presentation/settings_screen.dart:64-70 — Daily reminder toggle awaits `setEnabled` but has no try/catch, so failures are silent.
- [SEVERITY: medium] features/settings/presentation/settings_screen.dart:139-142 — Logout awaits `signOut` but has no try/catch, so logout failures are silent.
- [SEVERITY: medium] features/settings/presentation/settings_screen.dart:74-97 — Admin-profile errors are hidden and provide no user feedback.
- [SEVERITY: low] features/settings/presentation/settings_screen.dart:11 — Telegram admin URL is hardcoded in presentation code.
- [SEVERITY: low] features/settings/presentation/settings_screen.dart:112-120 — Share action is awaited but not error-handled.

## lib/features/progress/
- [SEVERITY: high] features/progress/streak_notifier.dart:45-66 — Quiz result writes use raw SQLite `INSERT ... ON CONFLICT` instead of Drift.
- [SEVERITY: medium] features/progress/streak_notifier.dart:97-114 — Accuracy calculation uses raw SQLite `customSelect` instead of Drift.
- [SEVERITY: low] features/progress/category_progress_provider.dart:7-13 — Local DB calls have no explicit error handling in the provider.

## lib/features/quiz/
- [SEVERITY: high] features/quiz/spaced_repetition_service.dart:40-59,125-140 — Due-card loading/counting uses raw SQLite `customSelect` against `quiz_table`.
- [SEVERITY: high] features/quiz/spaced_repetition_service.dart:81-100,158-178 — Review persistence reads/writes `ease_factor` and `last_quality`, which are not declared in the Drift `QuizTable` schema.
- [SEVERITY: high] features/quiz/weakness_service.dart:18-24,38-40 — Weak-field detection uses raw SQL on `last_quality` and adds that column with raw SQLite instead of Drift.
- [SEVERITY: medium] features/quiz/weakness_service.dart:13-29 — `getWeakFields` catches DB errors and returns an empty set, hiding failures from the UI.
- [SEVERITY: medium] features/quiz/quiz_repository.dart:28-34 — Invalid remote quiz rows are silently dropped during sync.
- [SEVERITY: low] features/quiz/quiz_screen.dart:59-60 — `Colors.grey[300]!` and `Colors.grey[100]!` use null assertions where fallback colors would be safer.
- [SEVERITY: medium] features/quiz/quiz_screen.dart:318-329 — Review and streak writes can fail without user-facing error handling.
- [SEVERITY: low] features/quiz/data/quiz_sync_service.dart:1 — Export wrapper duplicates `features/quiz/quiz_sync_service.dart` and may be unnecessary.

## lib/features/subscription/
- [SEVERITY: medium] features/subscription/presentation/paywall_screen.dart:10-13 — TODO comment and hardcoded Telebirr/Telegram payment configuration should be moved to managed config.
- [SEVERITY: low] features/subscription/presentation/paywall_screen.dart:78-83 — Telegram launch has no error handling if launching fails.

## lib/features/legal/
- No issues found.

## lib/app/ and main.dart
- [SEVERITY: high] main.dart:95-97 — `state.extra! as ArticleLocal` can crash if `/article-detail` is opened without route extra data.
- [SEVERITY: low] main.dart:228-229 — Subscription error UI displays the raw error object.
- [SEVERITY: low] app/main_shell.dart:20-25 — Inline tab comments can be removed or moved to a named constant/list documentation.
- [SEVERITY: low] app/nav_provider.dart:3 — Navigation comment can be removed or replaced with named constants.

## Summary
High issues: 12. Medium issues: 19. Low issues: 25.

Ranked fixes to do next:
1. Remove/rotate hardcoded Supabase and Chapa configuration and move runtime config out of source.
2. Replace raw SQLite schema/data management with Drift-managed tables, especially `study_sessions`, `view_history`, article FTS, and quiz spaced-repetition fields.
3. Fix the quiz spaced-repetition schema mismatch for `ease_factor` and `last_quality` before review persistence is used further.
4. Remove the `/article-detail` null assertion and use a safer route parameter or guarded extra-data pattern.
5. Harden silent failure paths in sync, admin activation, settings actions, search history, and quiz review/streak writes so users see actionable errors instead of stale or incomplete state.
