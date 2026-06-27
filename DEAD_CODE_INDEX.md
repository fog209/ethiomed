# WardReady — DEAD_CODE_INDEX.md

## Confirmed Unused Code

### Database Tables

| Table | File | Lines | Last Reference | Risk |
|-------|------|-------|----------------|------|
| QuizQuestions | `lib/core/database/app_database.dart` | 51-63 | Migration 4 dropped it | SAFE TO DELETE |
| - | - | 92 in `@DriftDatabase` | Never queried | SAFE TO DELETE |

---

### Packages

| Package | pubspec.yaml | Import Found | Usage Count | Risk |
|---------|--------------|--------------|------------|------|
| fsrs | Line 18 | No | 0 | SAFE TO DELETE |
| google_fonts | Line 20 | No | 0 | SAFE TO DELETE |

---

### Files

| Path | Purpose | Unused Evidence | Risk |
|------|---------|-----------------|------|
| `lib/features/quiz/data/quiz_sync_service.dart` | Re-exports quiz_sync_service | Only contains `export '../quiz_sync_service.dart';` | SAFE TO DELETE |

---

### Methods

| File | Method | Evidence | Risk |
|------|--------|----------|------|
| `lib/features/quiz/quiz_sync_service.dart:15-28` | `syncQuestions` | Wraps repository with duplicate error handling | LIKELY SAFE to inline |

---

## Possibly Unused (Needs Verification)

| File | Element | Check Needed |
|------|---------|--------------|
| `lib/features/search/search_screen.dart` | Entire file | Duplicate of article_search_screen? (both exist) |
| `lib/features/articles/presentation/article_search_screen.dart` vs `lib/features/search/search_screen.dart` | Two search screens | Verify which is used in routes |

---

## Exported Symbols Never Imported

| Symbol | File | Imported Where | Risk |
|--------|------|----------------|------|
| QuizQuestionLocal | Generated from QuizQuestions table | Never used in application code | SAFE TO DELETE |