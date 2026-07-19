# WardReady — Batch Execution Addendum: Feather + Light Tier

**Date:** 2026-07-19
**Branch:** `chore/feather-light-batch-2026-07-19` (off `master`)
**Scope:** 22-task autonomous feather/light batch. Investigation-first (1–7),
small fixes (8–13), light features (14–21), script-only (22).

---

## Completed & committed

| # | Task | Result | Commit |
|---|------|--------|--------|
| 1 | `AuthService.initialize()` call site | No-op by design; real init (`Supabase.initialize`) is in `main()` before `runApp`. No caller exists. **No change.** | — |
| 2 | Zero-article categories | Public Health/Epidemiology, Forensic Medicine, Anesthesiology are fully ABSENT from `app_config.dart` (and everywhere), not hidden. **No change.** | — |
| 3 | Android permissions audit | Manifest declares only `INTERNET` (used) + `POST_NOTIFICATIONS` (used by `flutter_local_notifications`). No unused permissions. **No change.** | — |
| 4 | `minSdk` root-cause | `flutter.minSdkVersion` (21) → hardcoded `24` in commit `f7ffb9d` "Phase 3.2: Standardize SDK versions". Standardization only — no deeper technical reason. | — |
| 5 | Day-365 expiry | `subscription_repository` enforces `expiryDate.isAfter(now())`; `schema.sql` sets `expiry_date=now()+interval'365 days'` at activation. Enforced server+client. **No change.** | — |
| 6 | R8/ProGuard | `isMinifyEnabled`+`isShrinkResources` true in `build.gradle.kts`; proguard rules present. **Verified via a real `--release` APK build** (`app-release.apk` 65 MB produced). | — |
| 7 | `pub outdated` + CVE | All outdated pkgs are minor/major bumps (Riverpod 2→3, secure_storage 9→10, etc.). **No CVEs found.** No bumps (rules: bump only trivial CVE fixes). | — |
| 8 | `FLAG_SECURE` | Already present in `MainActivity.kt` (lines 16–19). **No change.** | — |
| 9 | `env.dart` hardening | Added debug `assert` failing loudly when `--dart-define` supplies an empty credential. **Local-only** — `lib/app/env.dart` is gitignored (credential-safe), so change is not committed. | — |
| 10 | DB indexes | Added `idx_quiz_next_due_at` + `idx_view_history_article_id` (idempotent `CREATE INDEX IF NOT EXISTS` in ensure methods). | `6c19899` |
| 11 | Quiz/exam grounding SQL | Verified: `quiz_table.article_id` ⟷ `articles(id)` locally; Supabase `questions.article_id` FK `REFERENCES articles(id)` + indexes `idx_questions_*` already present. **No change.** | — |
| 12 | Remove dead `QuizQuestions` | Dropped `QuizQuestions` Drift class + table list; migrated old upgrade steps to raw SQL; added `from < 23` drop step; schema v22→**v23**. `.g.dart` regenerated (0 refs). | `6c19899` |
| 13 | `cross_link_text.dart` orphan | Confirmed orphaned (no importers). **Deleted**. | `6c19899` |
| 14 | Server-time expiry check | `_fetchServerNow()` via new `server_now` RPC; expiry compared against server time (anti-clock-spoof). New migration `0005_server_now_rpc.sql`. | `c7cc2ad` |
| 15 | WebView JS/file-access lockdown | **N/A** — no WebView in the app (all links use `url_launcher` `externalApplication`). No package to lock down. | — |
| 16 | Admin-only RLS on `subscriptions` | New migration `0006_subscriptions_admin_rls.sql`: `is_user_admin()` helper + INSERT/UPDATE policies (admins only), mirroring `section_registry` idempotent style. | `da2c6ce` |
| 17 | CI workflow | `.github/workflows/ci.yml` — `flutter analyze` + `flutter test` on push/PR (ubuntu, stable). | `b09645e` |
| 18 | MaterialIcons tree-shaking | **Verified**: release build shows 1645184→13688 bytes (99.2% reduction). All icons (incl. 16 section_registry) referenced statically via literal `Icons.*`, so safe. **Live visual smoke test NOT performed** (no device in session). | — |
| 19 | Attending Tip on questions | Added `attending_tip` column (`quiz_table` + Supabase `questions`), schema v23→**v24**, model mapping, and UI block in `quiz_screen.dart`. Migration `0007_questions_attending_tip.sql`. | `56f7712` |
| 20 | Reading-mode polish | `reading_mode_provider` (font scale, line height, sepia), persisted via `shared_preferences`; applied to article `MarkdownBody`; settings section. | `d0055cd` |
| 21 | Calculator formulas | 8 calculators (BMI, Cockcroft–Gault, Corrected Calcium, GCS, qSOFA, CURB-65, Wells PE, Wells DVT) with cited formulas, functional UI, and **1 unit test each** (12 tests, all pass). | `5d7f7ca` |
| 22 | Flashcard dedup | `scripts/dedup_flashcards.py` collapses 22,410→11,987 unique (10,423 dropped) by (deck,front,back). Output `scripts/apkg_flashcards_deduped.json`. Pure script; no Supabase/Drift/schema touched. | `0d66c1f` |

---

## Caveats / notes for the human

- **T9 (`env.dart`)** is a genuine code change but lives in a gitignored file
  (`lib/app/env.dart` is excluded so real credentials never commit). It is
  present in the working tree on this branch but will NOT appear in `git log`.
- **T15 (WebView)** is genuinely not applicable — flagging so it isn't
  silently re-raised. If an in-app WebView is ever added, revisit lockdown.
- **T18 (icons)** is verified by build output + static audit, not a live device
  render. Recommend a quick on-device smoke test before release.
- **Supabase migrations `0005`–`0007`** are written but NOT yet applied to the
  live project (they require manual SQL-editor execution / service-role, per
  existing repo convention). `server_now`, `is_user_admin`, and
  `questions.attending_tip` will not function until applied.
- The branch is **not merged to master** (per instructions — merge is the
  human's call). `flutter analyze` → 0 errors; `flutter test` → 58/58 pass.
- Commit `6c19899` bundles T10 (indexes) + T12 (table removal) + T13 (delete)
  because all three touched the same `app_database.dart` diff; noted for
  review but logically cohesive (DB cleanup).
