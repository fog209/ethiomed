# AUDIT_REPORT_2026-06.md

WardReady full-codebase audit. Read-only. Date: 2026-06-30.
Reference: `AGENTS.md` (workspace instructions). Scope: all of `lib/`,
`android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`,
`android/app/proguard-rules.pro`, `pubspec.yaml`. 61 Dart files total
(60 hand-written + 1 generated `app_database.g.dart`).

---

## 1. Rule violations

### Navigator.push / Navigator.pop / Navigator.pushReplacement
**none found.** Clean. All navigation goes through GoRouter
(`context.go` / `context.push` / `context.pop`).

### print() instead of debugPrint()
**none found.** Clean.

### setState() used for anything beyond local widget animation
4 hits — **all legitimate** per AGENTS.md's "local widget state" allowance:
- `lib/core/screens/database_recovery_screen.dart:38` — `_isResetting` loading spinner (local UI).
- `lib/features/articles/presentation/article_detail_screen.dart:522` — `_showLowYieldSections` visibility toggle (local UI).
- `lib/features/onboarding/onboarding_screen.dart:86` — `_currentPage` page indicator (local animation).
- `lib/main.dart:292` — `_hasSeenDisclaimer` in `DisclaimerGate` (local UI).

### Raw http package usage instead of dio
**none found.** No `package:http/` imports. All `dart:io` imports are for
`File`/`Platform`/`SocketException` (filesystem + db path + socket error type),
not HTTP. dio is the only HTTP client.

### Raw sqlite usage instead of Drift
**none found.** All DB access is via `_db.select()` / `_db.customSelect()` /
`_db.update()` etc. The one `import 'sqlite3'` in `quiz_repository.dart:8` is
for the `SqliteException` *type* in a catch clause — not raw DB access.
Defensible.

### `!` non-null assertions that are not provably safe
- `lib/core/services/postgrest_status_helper.dart:12` — `match.group(0)!`.
  **Provably safe** — only reached after a successful regex match.
- `lib/core/widgets/empty_state.dart:56` — `actionLabel!`. **Provably safe** —
  guarded by `if (actionLabel != null && onAction != null)` earlier in the same
  build path.
- `lib/features/articles/presentation/article_detail_screen.dart:295` —
  `widget.article!.category?.toUpperCase()`. **Potentially unsafe.**
  `ArticleDetailScreen` has a no-arg constructor `ArticleDetailScreen()` (used
  by the `/article-detail` route's fallback branch in `main.dart:175`). If that
  null-article path ever renders this build subtree, this throws. Needs a
  null guard, not `!`.
- `Colors.grey[NNN]!` across ~8 files (shimmer skeletons) — Material shades are
  non-null at those indices. **Defensible.**

### await inside a Widget not followed by context.mounted check
**none found** in current code. The prior `78c673b` hardening pass added
`mounted` guards throughout. Spot-checked `login_screen`, `signup_screen`,
`article_detail_screen`, `categories_screen`, `onboarding_screen`,
`database_recovery_screen` — all guard correctly after awaits.

### StatefulWidget async callbacks missing `if (!mounted) return;`
**none found.** Same as above — the mounted-guard pass covered these.

### dispose() methods calling ref.read() or ref.watch()
**none found.** Spot-checked all `dispose()` overrides — they only call
`.dispose()` / `.cancel()` / `focusNode.dispose()`.

---

## 2. Locked-stack drift

Comparing `pubspec.yaml` dependencies against the exact AGENTS.md list:

| AGENTS.md package | In pubspec? | Notes |
|---|---|---|
| supabase_flutter | ✓ | |
| drift | ✓ | |
| sqlite3_flutter_libs | ✓ | |
| path_provider | ✓ | |
| flutter_secure_storage | ✓ | |
| flutter_riverpod | ✓ | |
| riverpod_annotation | ✓ | |
| dio | ✓ | |
| cached_network_image | ✓ | |
| shimmer | ✓ | |
| flutter_markdown | ✓ | |
| google_fonts | ✓ | |
| url_launcher | ✓ | |
| shared_preferences | ✓ | |
| package_info_plus | ✓ | |
| go_router | ✓ | |
| flutter_local_notifications | ✓ | |
| build_runner (dev) | ✓ | |
| drift_dev (dev) | ✓ | |
| riverpod_generator (dev) | ✓ | |

**No additions, no removals.** The dependency list matches AGENTS.md exactly.
No version-pinning anomalies (all use caret ranges). Flutter SDK constraint
and Kotlin/Gradle plugin versions are not governed by AGENTS.md.

**One naming note (not drift):** the Dart package name in `pubspec.yaml` line 1
is still `ethiomed`, and `applicationId` is `com.wardready.app`. The Dart
package name is old-branding residue but renaming it is a repo-wide refactor
(every `lib/...` import path is relative, so impact is contained — no
`package:ethiomed/` imports survive). See §4.

---

## 3. Protected-file check

### `lib/features/quiz/spaced_repetition_service.dart` — SM-2 algorithm
The SM-2 formula is intact and matches the standard SM-2 specification:
- EF update: `EF = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))`, clamped to
  a floor of 1.3. ✓ Standard.
- Quality thresholds: q < 3 resets repetitions/interval to 0; q ≥ 3 advances. ✓ Standard.
- Interval: rep 1 → 1, rep 2 → 6, rep n → `round(prevInterval * EF)`. ✓ Standard.
- Default EF = 2.5. ✓ Standard.

The file uses an injected `NotificationService` (per the `21f3f18` DI fix) and
reads SR columns (`srInterval`, `easeFactor`, `repetitions`, `lastQuality`,
`nextDueAt`) from `QuizTable` — but the *math* is canonical SM-2. No formula
constants or thresholds deviate. **Algorithm unchanged.**

### `lib/core/database/app_database.g.dart` — manual-edit signs
- Line 1: `// GENERATED CODE - DO NOT MODIFY BY HAND` header present. ✓
- Formatting is consistent generated style (2-space indent, `$`-prefixed
  synthetic names like `$_itemColumn`, `$ArticlesTable`, no hand-written
  comments). ✓
- No `// TODO`, no human-style comments, no inconsistent brace style. ✓
**No signs of manual editing.** File is cleanly generated.

---

## 4. Branding/naming sweep

Hits for "EthioMed" / "ethiomed" / "com.ethiomed":

| File | Line | Hit | Severity |
|---|---|---|---|
| `lib/core/database/app_database.dart` | 525 | `'ethiomed.sqlite'` (db filename) | **High** — old-brand DB filename. Changing it requires a migration; `database_recovery_screen` already lists both old+new names. |
| `lib/core/screens/database_recovery_screen.dart` | 47–49 | `'ethiomed.sqlite'`, `'-shm'`, `'-wal'` (cleanup paths) | Medium — intentional (cleans up legacy DB files). |
| `lib/features/auth/data/auth_service.dart` | 112 | `'ethiomed_access_token'` (secure-storage key) | Medium — internal key name. AGENTS.md lists "token key rename" as explicitly NOT-started. |
| `lib/features/auth/data/auth_service.dart` | 113 | `'ethiomed_refresh_token'` (secure-storage key) | Medium — same as above. |
| `lib/features/auth/presentation/signup_screen.dart` | 73 | `'Join EthioMed'` (**user-visible**) | **High** — user-facing old-brand text on the signup button. |
| `pubspec.yaml` | 1 | `name: ethiomed` (Dart package name) | Low — internal, no user visibility, but inconsistent with `com.wardready.app`. |

**No `com.ethiomed` hits.** No `package:ethiomed/` imports survive (the old
`search_screen.dart` that had one no longer exists). The user-visible
`'Join EthioMed'` on signup is the most important hit — users see it.

---

## 5. Theme migration status

Hardcoded `Color(...)` / `Colors.*` outside the 5 AGENTS.md exceptions
(MarkdownBody white, Learning Radar amber, SM-2 button colors,
ErrorWidget.builder, heatmap intensity). Grouped by file:

**`lib/app/main_shell.dart`** (6) — `Colors.white54`, `Colors.grey`,
`Colors.white` ×2, `Colors.orange.shade800`, `Colors.white`.
**`lib/core/screens/database_recovery_screen.dart`** (7) — navy/gold
`Color(0xFF...)` ×3, `Colors.amber`, `Colors.white`, `Colors.white70`,
`Colors.white54`.
**`lib/core/widgets/error_banners.dart`** (2) — `Colors.red.shade700`,
`Colors.white`.
**`lib/features/admin/presentation/admin_dashboard_screen.dart`** (12) —
navy/gold `Color(0xFF...)` ×6, `Color(0xFF2E7D32)`, `Colors.grey.shade700`,
`Colors.red`, `Colors.grey[300]!`, `Colors.grey[100]!`, `Colors.white` ×2.
**`lib/features/articles/presentation/article_detail_screen.dart`** (8) —
`Colors.grey[300]!`, `Colors.grey[100]!`, `Colors.white` ×6.
**`lib/features/articles/presentation/article_search_screen.dart`** (5) —
`Colors.grey[300]!`, `Colors.grey[100]!`, `Colors.white` ×3.
**`lib/features/bookmarks/presentation/bookmarks_screen.dart`** (2) —
`Colors.amber`, `Colors.white70`.
**`lib/features/home/presentation/article_list_screen.dart`** (9) —
`Colors.grey` ×2, `Colors.white` ×3, `Colors.red`, `Colors.grey[800]!`,
`Colors.grey[700]!`, `Colors.white`.
**`lib/features/home/presentation/categories_screen.dart`** (4) —
`Colors.grey[800]!`, `Colors.grey[700]!`, `Colors.white` ×2.
**`lib/features/legal/disclaimer_screen.dart`** (2) — gold `Color(0xFFFFB300)` ×2.
**`lib/features/onboarding/onboarding_screen.dart`** (5) — gold/navy
`Color(0xFF...)` ×3, `Colors.grey`, navy `Color(0xFF1A237E)`.
**`lib/features/progress/progress_screen.dart`** (5) — `Colors.white70`,
navy/gold `Color(0xFF...)` ×2, `Colors.grey.shade300` ×2.
**`lib/features/quiz/quiz_screen.dart`** (9) — navy/gold const ×2,
`Colors.grey[300]!`, `Colors.grey[100]!`, `Colors.white` ×3, SM-2 red/orange
`Color(0xFF...)` ×2 *(SM-2 button colors are an AGENTS.md exception — exclude
these 2)*.
**`lib/features/settings/presentation/settings_screen.dart`** (2) —
`Colors.red` ×2 (logout).
**`lib/features/subscription/presentation/paywall_screen.dart`** (9) —
navy/gold `Color(0xFF...)` ×8, `Colors.white`, `Colors.white70`.
**`lib/main.dart`** (3) — navy `Color(0xFF1A237E)`, gold `Color(0xFFF9A825)`,
`Colors.white` *(ErrorWidget.builder — **AGENTS.md exception, exclude**)*.

**`lib/core/theme/app_theme.dart`** — this file *defines* the palette, so its
`Color(0xFF...)` values are the source of truth, not violations.

**Net count (excluding exceptions):** ~88 hardcoded color references across
15 files. The previously-known ~51 in onboarding/paywall/admin are still
present (admin 12, paywall 9, onboarding 5 = 26 in those three; the original
~51 count likely spanned more of the early screens). The count has **grown**
overall — article_detail, article_search, article_list, categories, quiz,
bookmarks, progress, settings, error_banners, database_recovery, main_shell
all carry hardcoded colors that a full theme migration would absorb.

---

## 6. Feature-status reconciliation

Cross-checking AGENTS.md's "already done" list against actual code:

| Feature | Code present? | Notes |
|---|---|---|
| Auth | ✓ | `auth_service.dart`, login/signup screens. |
| Category navigation (19) | ✓ | `categories_screen.dart`. |
| Article sync (auto + manual) | ✓ | `article_repository.dart`. |
| Offline article cache | ✓ | Drift `articles` table. |
| Article viewer | ✓ | `article_detail_screen.dart`. |
| FTS5 search with debounce | ✓ | `article_search_provider.dart`. |
| SM-2 quiz engine | ✓ | `spaced_repetition_service.dart`. |
| Learning Radar | ✓ | `weakness_service.dart`. |
| High-Yield mode | ✓ | `is_high_yield` column + detail screen toggle. |
| **EHPLE exam mode** | ⚠ **stub** | `exam_session_notifier.dart` defines `examSessionNotifierProvider`, but **no screen consumes it**. Grep for the provider finds only its own definition — it is never `ref.watch`ed by any widget. Onboarding mentions "EHPLE Exam Practice" as marketing copy, but there is no exam UI. Listed as "done" in AGENTS.md but **not wired into the app**. |
| Progress screen + heatmap | ✓ | `progress_screen.dart`. |
| Streaks | ✓ | `streak_notifier.dart`. |
| Bookmarks | ✓ | `bookmarks_screen.dart`. |
| Onboarding | ✓ | `onboarding_screen.dart`. |
| Legal screens | ✓ | disclaimer/terms/privacy. |
| Settings | ✓ | `settings_screen.dart`. |
| Theme toggle | ✓ | `themeModeProvider` in `main.dart`. |
| Session timeout | ✓ | `session_timeout_provider.dart`. |
| Local notifications | ✓ | `notification_service.dart`. |
| Admin dashboard | ✓ | `admin_dashboard_screen.dart`. |
| Retry-wrong-answers | ✓ | Real impl in `quiz_screen.dart` (dialog → `loadQuestionsByIds`). |
| Today's-plan card | ✓ | `categories_screen.dart` today-plan provider. |
| Read-time estimate | ✓ | `article.dart` + card display. |
| android:label fix | ✓ | Manifest. |
| POST_NOTIFICATIONS | ✓ | Manifest + runtime gate. |
| allowBackup=false | ✓ | Manifest. |
| Proguard Drift rules | ✓ | `proguard-rules.pro`. |
| edge-to-edge | ✓ | `main.dart` (just landed in `c061312`). |
| secondaryContainer in darkTheme | ⚠ **partial** | Dark theme exists; `secondaryContainer` slot still not populated (the Step 4 change from the prior session was paused, not applied). |

**Flags:** EHPLE exam mode is a stub (provider exists, no UI). secondaryContainer
is unpopulated. Everything else reconciles.

---

## 7. Scale risk sweep (350+ articles, target 441+)

### Confirmed scale risks
1. **`progress_notifier.dart:107-128` — N+1 category progress query.**
   `_loadCategoryProgress` runs 1 query to list categories, then **2 queries
   per category** (`countArticlesByCategory` + `countReadArticlesByCategory`)
   in a loop. At 19 categories = **39 sequential DB round-trips** per progress
   screen load. Fine at 45 articles, noticeable at 350+. Should be a single
   `GROUP BY category` query.
2. **`article_search_provider.dart:336-355` — FTS5 rebuild is a full table scan
   + per-row insert loop.** `_ensureFtsIndex` selects ALL articles then inserts
   each into the FTS table one-by-one (not batched). At 350+ rows this is a
   350+-iteration loop on every index-mismatch check. Runs in background but
   blocks the DB connection while it works.
3. **`article_repository.dart:77/81/85/109` — `select(articles).get()` returns
   the full cached article set.** Called on every sync fallback path (401/403/
   429/503/504 + success). At 350+ rows this materializes every article into
   memory on each load. The articles list screens then filter/paginate from
   this in-memory list. Bounded by cache size, but the full-table load is the
   default pattern.

### Checked and OK
- **`categories_screen.dart` sync logic** — uses `COUNT(*) ... GROUP BY category`
  with `LIMIT 1`. Aggregate query, not full-table load. ✓
- **`article_search_provider.dart` search** — bounded by `LIMIT _maxSearchResults`
  (the `f3ec3a2` fix). ✓
- **`progress_screen.dart` ListViews** (lines 75, 214) — both hold a **fixed**
  set of section widgets (stat cards, heatmap, category breakdown). The
  category breakdown is ~19 items max — small enough that `.builder` isn't
  required, though it would be cleaner. Not a scale risk.
- **`quiz_repository.dart:142` `getLocalQuestions`** — loads all questions for
  one category (WHERE category = ?), no LIMIT. Bounded by per-category quiz
  count (~20-30), not total. ✓ for now.
- **All article list screens** — use `ListView.builder` via
  `cached_network_image` + slivers. ✓

---

## 8. AndroidManifest / build configuration sanity check

| Check | Result | Evidence |
|---|---|---|
| `android:label = "WardReady"` | ✓ | `AndroidManifest.xml` application tag. |
| POST_NOTIFICATIONS permission | ✓ | `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`. |
| Runtime request gate (API 33+) | ✓ | `notification_service.dart` calls `androidPlugin?.requestNotificationsPermission()` in `initialize()`. |
| `android:allowBackup="false"` | ✓ | Explicitly false on `<application>`. |
| Proguard Drift `-keep` rules | ✓ | Keeps `io.requery.**`, `androidx.sqlite.**`, `@androidx.room.Database`, `drift.**`; `-dontwarn drift.**`. |
| `targetSdk` / `compileSdk` | ✓ | Both 35 in `build.gradle.kts` (Android 15). Matches AGENTS.md's Android 15/16 intent. |
| Signing config | ✓ | `release` signingConfig wired, `key.properties` loaded, minify+shrink+proguard on release build type. |
| `versionCode` / `versionName` | ✓ | `versionCode = 1`, `versionName = "1.0.0"`. |

**All config checks pass.**

---

## 9. Anything else

1. **Duplicate `subcategoryFilterProvider` declarations.** Defined in both
   `lib/features/articles/article_providers.dart:5` AND
   `lib/features/home/presentation/article_list_screen.dart:20`. The screen
   uses its own local one; the rest of the app uses the other. They hold
   **separate state** — a latent bug where resetting one doesn't reset the
   other. Should be a single shared provider.
2. **Inconsistent marketing article counts.**
   `paywall_screen.dart:32` says **"267+ clinical articles"** while
   `onboarding_screen.dart:91` says **"441 Clinical Articles"** and
   **"2,000+ MCQs"**. Users see both screens. The 441 figure matches the
   eventual target; 267+ looks stale or like a different count basis.
   Pick one.
3. **`DisclaimerGate` in `main.dart:267` is dead code.** The route table sends
   `/` to `InitialFlowGate`, which itself handles the disclaimer check
   (`main.dart:243`). `DisclaimerGate` is a separate class that is never
   routed to. Harmless but orphaned.
4. **`exam_session_notifier.dart` reads SR columns** (`nextDueAt`,
   `repetitions`, `srInterval`, `easeFactor`, `lastQuality`) via raw SQL that
   may not match the current `QuizTable` companion shape. Since the provider
   is never consumed by a screen (§6), this is dormant — but if EHPLE exam
   mode is ever wired up, this query needs verification against the live
   schema.
5. **`quiz_repository.dart:149` — indexed-placeholder / positional-variable
   mismatch.** Builds `id = ?${e.key}` (producing `?0`, `?1`... — Drift
   *indexed* placeholders) but passes `Variable(id)` values positionally.
   This is in the retry-wrong-answers path. If Drift resolves these as
   positional, the binding is correct by accident; if it treats `?0`/`?1` as
   indexed, the variables list is in the wrong form. Worth a targeted test
   of the retry flow with >1 wrong answer.

---

## Summary

| Category | Issue count |
|---|---|
| 1. Rule violations | 1 real (`article!.category` unsafe `!`); rest clean |
| 2. Locked-stack drift | 0 |
| 3. Protected-file check | 0 (SM-2 intact, .g.dart clean) |
| 4. Branding/naming | 6 hits (1 user-visible: "Join EthioMed") |
| 5. Theme migration | ~88 hardcoded colors across 15 files (grown) |
| 6. Feature-status | 2 flags (EHPLE exam = stub, secondaryContainer = unpopulated) |
| 7. Scale risk | 3 (progress N+1, FTS rebuild loop, full-table article loads) |
| 8. Android config | 0 (all pass) |
| 9. Anything else | 5 (dup provider, marketing #s, dead code, exam schema, quiz placeholder) |

### If this were a real task queue, fix these 3 first:
1. **`signup_screen.dart:73` "Join EthioMed" → "Join WardReady"** — one-line,
   user-visible branding bug, zero risk. (§4)
2. **`progress_notifier.dart:107-128` N+1 → single GROUP BY query** — the most
   impactful scale fix; turns 39 queries into 1 at 19 categories. (§7)
3. **`article_detail_screen.dart:295` `widget.article!.category`** — replace
   `!` with `?.` + fallback. Only real null-safety violation; crashes on the
   null-article route fallback. (§1)

End of report. Read-only audit — no files edited other than this one.
