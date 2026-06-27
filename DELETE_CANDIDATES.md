# WardReady — DELETE_CANDIDATES.md

## Files Safe to Delete

| Path | Evidence | Risk | Action |
|------|----------|------|--------|
| `lib/features/search/search_screen.dart` | NOT imported in main_shell.dart (line 11 uses `article_search_screen.dart`) | NONE | SAFE TO DELETE |
| `lib/features/quiz/data/quiz_sync_service.dart` | Re-export only (line 1: `export '../quiz_sync_service.dart';`) | NONE | SAFE TO DELETE |

---

## Database Tables

| Table | Evidence | Risk | Action |
|-------|----------|------|--------|
| QuizQuestions | Never queried; data redirected to quiz_table in migration 4 | NONE | SAFE TO DELETE from schema |

---

## Packages

| Package | Evidence | Risk | Action |
|---------|----------|------|--------|
| fsrs | pubspec.yaml:18; no import found in lib/ | NONE | SAFE TO DELETE |
| google_fonts | pubspec.yaml:20; no import found in lib/ | NONE | SAFE TO DELETE |

---

## Unused Providers

| Provider | Evidence | Risk | Action |
|----------|----------|------|--------|
| selectedCategoryProvider | Defined in `search_screen.dart` which is unused | NONE | SAFE TO DELETE with file |

---

## Obsolete Files

| Path | Evidence | Risk | Action |
|------|----------|------|--------|
| `lib/features/quiz/data/quiz_sync_service.dart` | Duplicate of parent directory service | NONE | SAFE TO DELETE |