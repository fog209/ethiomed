# Batch 2 Progress
Branch: chore/feather-light-batch-2-2026-07-19
Started: 2026-07-19

- [x] T1 — env.dart startup-check relocation (commit d83120e)
- [x] T2 — Drift WAL mode (commit 44d5674)
- [x] T3 — Obfuscated release build + retained symbols (commit 1a89fa9)
- [ ] T4 — android:dataExtractionRules (BLOCKED)
- [x] T5 — Medical abbreviation long-press tooltips (commit 1f024f9)
- [x] T6 — Daily Pearl home card (commit 0be2780)
  - Added lib/core/env_guard.dart (validateEnvConfig, no secrets), wired into main() assert, added test/env_guard_test.dart (5 tests pass). env.dart remains gitignored.
  - Added setup callback to NativeDatabase in _openConnection (app_database.dart:1275) executing PRAGMA journal_mode=WAL. Verified returns 'wal'. 63 tests pass.
  - Added release_build job to ci.yml (gated to master push), uploads build/symbols/<version> as artifact. Added docs/RELEASE_SYMBOLICATION.md, gitignored build/symbols/. YAML validated.
  - BLOCKED: Premise mismatch. AndroidManifest already has android:allowBackup=false and android:fullBackupContent=false (no custom backup_rules.xml exists). allowBackup=false already disables ALL auto-backup and device-to-device transfer (incl. flutter_secure_storage) on every API level. dataExtractionRules only takes effect when allowBackup=true, so adding it under the current config is inert and would be misleading. Owner decision needed: either (a) keep allowBackup=false as-is (secure storage already protected), or (b) switch to allowBackup=true + explicit backup_rules.xml AND data_extraction_rules.xml. Did NOT add a misleading rules file. See BATCH2 final report.
  - Added MedicalTermLinkBuilder (article_markdown_helpers.dart) registered as 'a' builder in article_detail_screen MarkdownBody. Long-press -> Tooltip with expansion; tap -> _handleLinkTap (unchanged). Expansion map uses ONLY trusted 1:1 pairs already in _medicalTerms (vte/ards/ckd/esrd/copd), no guessed clinical content. 2 widget tests pass.
  - Added daily_pearl.dart (pickDailyPearl pure deterministic by day-of-year modulo count; eligible keys: clinicalPearls, mnemonics from live schema), DailyPearlCard in entry_point_cards.dart shown on Home after Quick Access header. Tapping pushes /article-detail with id+section (reuses existing route, scrolls to section). Null/empty -> SizedBox.shrink (graceful). 4 unit tests pass.
