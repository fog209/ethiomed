# Article Content Schema Redesign — Running Report

## Phase 0 — Investigation (read-only, no changes)
- `ArticleContent` model: 16 nullable `String?` fields, `fromJson` maps 16 hardcoded keys, `toJson` emits all 16.
- Rendering: `_ClinicalSectionConfig` {title,icon,initiallyExpanded}; `_clinicalSectionOrder` fixed 16-key array; `_clinicalSections` map key→config; `_buildClinicalSections` iterates order, applies yield/weak highlighting; `_decodeSections` jsonDecode→Map.
- `Articles.content` = `TextColumn` (nullable JSON string). Drift schemaVersion=20. No column change needed.
- **CONTRADICTION**: `content_update_service.dart` is badge-only (reads `updated_at`). Real content sync = `quiz_repository.dart:syncArticlesByCategory` (full upsert of `jsonEncode(content)`). Registry sync follows that pattern, separate function.
- `articles.content` = `jsonb`, anon SELECT. schema.sql CLINICAL CONTENT SCHEMA comment lists 16 fields (stale doc for Phase 4).
- `QuizTable.testedField`: free-form text (default `clinicalFeatures`), confirmed NOT an enum. Consumed by weakness_service, quiz_screen, categories_screen, and the LOCKED spaced_repetition_service/exam_session_notifier (read-only). No change needed.
- Live: 32 articles. Live `content` = old fixed-field shape (no `schemaVersion`), only-present keys. All 16 keys appear; "HTN" has all 16.

## Phase 1 — New content shape (code DONE)
- `lib/features/articles/models/article_model.dart`: `ArticleSection{key,body}` + `ArticleContent{schemaVersion, sections}`. `fromJson` handles new (`sections` array) and legacy (16-key order) shapes; `bodyFor(key)` helper.
- `lib/core/database/app_database.dart`: added `SectionRegistry` table (`SectionRegistryEntry`: key PK, label, iconName, displayOrder, appliesTo [TEXT storing JSON array], enabled, updatedAt). Registered in `@DriftDatabase`. Ran build_runner → regenerated `.g.dart` clean. No schemaVersion bump (content column type unchanged).
- `lib/features/articles/data/content_update_service.dart`: added `syncSectionRegistry()` (dedicated, full-pull-on-launch, no badge logic, modeled on quiz_repository upsert), `sectionRegistryProvider`, `SectionRegistryEntryX.parsedAppliesTo`. Imports: `dart:convert`, `drift/drift.dart`.
- `lib/app/main_shell.dart`: wired `syncSectionRegistry()` as a separate `Future.microtask` at startup.
- Analyzed clean (dart analyze, single-file): article_model.dart, content_update_service.dart.

## Phase 2 — Section registry SQL (WRITTEN, NOT EXECUTED — checkpoint)
- `supabase/migrations/0002_section_registry.sql`: `create table public.section_registry(...)` + RLS + `section_registry_read_all` SELECT policy (true), NO anon/auth write policy. 16 seed INSERTs mirroring `_clinicalSections` (icon_name = Flutter Icons identifier; display_order = `_clinicalSectionOrder`; applies_to = null for all). Uses `on conflict (key) do nothing`.
- **NOT run against live Supabase** — creating a new table + seeds is a live schema change (AGENTS.md checkpoint). Awaiting go-ahead.
- Exact seed statements (key, label, icon_name, display_order):
  1. definition — 📝 Definition — info_outline
  2. epidemiology — 🌍 Epidemiology — public
  3. etiology — 🧬 Etiology — biotech
  4. pathophysiology — 🔬 Pathophysiology — psychology_outlined
  5. clinicalFeatures — 🩺 Clinical Features — list_alt
  6. redFlags — 🚩 Red Flags — warning_rounded
  7. approach — 🧭 Approach — format_list_numbered
  8. diagnosis — 🔎 Diagnosis — search
  9. treatment — 💊 Treatment — medication
  10. contraindications — 🛑 Contraindications — report_problem_outlined
  11. dontMiss — 🚨 Don't Miss — priority_high
  12. complications — ⚠️ Complications — warning_amber_rounded
  13. clinicalPearls — 💡 Clinical Pearls — lightbulb_outline
  14. ethiopianContext — 🇪🇹 Ethiopian Clinical Pearl — local_hospital_outlined
  15. mnemonics — 🧠 Mnemonics — auto_awesome_mosaic_outlined
  16. examTraps — 📋 Exam Traps — help_outline

## Phase 3 — Rendering refactor (DONE)
- `article_detail_screen.dart`: `_decodeSections` now returns `ArticleContent` (via `ArticleContent.fromJson`). Removed `_ClinicalSectionConfig` (dead) and the hardcoded `_clinicalSections` map.
- New registry-driven resolution: `_resolveSectionMeta(key)` → (1) local `sectionRegistryProvider` entry if enabled, (2) in-code `_fallbackLabels`/`_fallbackIconNames` for the 16 known keys (so offline/unsynced renders identically), (3) unknown key → `_humanizeKey` + default icon `Icons.article_outlined` + order 999 (appended after known sections).
- `_iconByName` lookup map (IconData per `icon_name` string) — extend with one line for new icons; `_defaultExpandedFor` preserves redFlags/approach/ethiopianContext expansion.
- `_buildClinicalSections` now iterates `ArticleContent.sections`, resolves metadata, sorts by resolved order then array position, and renders via the existing `_buildMarkdownExpansionTile` (UI/card style unchanged). `_clinicalSectionOrder` retained for scroll-to-section lookup.
- Imports: added `article_model.dart`, `content_update_service.dart` (for `sectionRegistryProvider`).
- `flutter analyze` clean; `flutter test` 42 pass (35 + 7 new). `spaced_repetition_service.dart` confirmed UNTOUCHED (not in git diff).

## Phase 4 — Data migration (DONE)
- Generated `scripts/phase4_write.sql` (reusing `phase4_dryrun.py`'s `convert()`), run in the Supabase SQL Editor (service role). All 32 articles migrated to `{schemaVersion:2, sections:[...]}`.
- First full run applied 28/32 (the leading 4 statements did not execute in the editor); follow-up `scripts/phase4_write_remaining.sql` completed the remaining 4. Verified via anon read: 32/32 now `schemaVersion: 2`, 0 anomalies.
- `supabase/schema.sql` CLINICAL CONTENT SCHEMA comment updated to document `schemaVersion: 2` + `sections` array.
- Live `section_registry` also carries `category_label_overrides` (0003, run manually): `pathophysiology` → {Anatomy, Microbiology}, `treatment` → {Anatomy: Surgical Landmarks}.

## Phase 5 — Verify (DONE for analyze/test/model)
- `flutter analyze`: no issues. `flutter test`: 42 pass.
- Old-shape (no schemaVersion) → converts via 16-key order: covered by `test/article_content_model_test.dart`.
- New-shape + unknown-key fallback: covered by model test + `_humanizeKey` test.
- testedField/Learning Radar/weakness: untouched (quiz/weakness code unchanged; only reads `tested_field` string).
- spaced_repetition_service.dart: NOT modified.
