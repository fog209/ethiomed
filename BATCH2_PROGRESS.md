# Batch 2 Progress
Branch: chore/feather-light-batch-2-2026-07-19
Started: 2026-07-19

- [x] T1 — env.dart startup-check relocation (commit d83120e)
- [x] T2 — Drift WAL mode (commit 44d5674)
- [ ] T3 — Obfuscated release build + retained symbols
- [ ] T4 — android:dataExtractionRules
- [ ] T5 — Medical abbreviation long-press tooltips
- [ ] T6 — "Daily Pearl" home card
  - Added lib/core/env_guard.dart (validateEnvConfig, no secrets), wired into main() assert, added test/env_guard_test.dart (5 tests pass). env.dart remains gitignored.
  - Added setup callback to NativeDatabase in _openConnection (app_database.dart:1275) executing PRAGMA journal_mode=WAL. Verified returns 'wal'. 63 tests pass.
