# WardReady — Database Reference

## Tables

### 1. articles

**File:** `lib/core/database/app_database.dart:22-34`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | TEXT | NO (PK) | Supabase article UUID |
| title | TEXT | NO | Article title |
| category | TEXT | YES | Clinical category (e.g., "Internal Medicine") |
| content | TEXT | YES | JSON string with 10 sections |
| imageUrl | TEXT | YES | Optional image URL |
| videoUrl | TEXT | YES | Optional YouTube/video URL |
| subcategory | TEXT | YES | Added in migration 7 |
| isHighYield | BOOLEAN | NO (default false) | Added in migration 6 |

**Indexes:**
- Primary key on `id`

**Relationships:**
- Referenced by `view_history.article_id`
- Referenced by `quiz_table.articleId`

**Schema History:**
- v1: Created
- v6: Added `isHighYield`
- v7: Added `subcategory`

---

### 2. bookmarks

**File:** `lib/core/database/app_database.dart:36-39`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | NO (autoIncrement, PK) | Local row ID |
| articleId | TEXT | NO (FK → articles.id) | Bookmark reference |

**Indexes:**
- `articleId` indexes implicitly via FK

**Relationships:**
- Many-to-one with articles

---

### 3. study_sessions

**File:** `lib/core/database/app_database.dart:41-48`

**Actual table created in code (not Drift-managed):** `lib/core/database/app_database.dart:226-235`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| date | TEXT | NO (PK) | YYYY-MM-DD format |
| articles_viewed_count | INTEGER | NO (default 0) | Legacy name |
| session_date | TEXT | YES | Legacy column, used for migration |
| articles_read | INTEGER | NO (default 0) | Actual article count |
| quizzes_completed | INTEGER | NO (default 0) | Quiz attempts |
| quiz_correct | INTEGER | NO (default 0) | Correct answers |

**Indexes:**
- `idx_study_sessions_date` (line 292)

**Purpose:**
- Streak calculation (consecutive days with `articles_read > 0`)
- Heatmap data (articles per day)

**Schema History:**
- v1: Not in schema, created via `_ensureStudySessionsTable` (migration 8)
- Legacy: `date` stored as DateTime in Drift schema but TEXT in actual table

---

### 4. quiz_table (QuizTable in Drift)

**File:** `lib/core/database/app_database.dart:67-89`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | NO (autoIncrement, PK) | Local ID |
| remoteId | TEXT | NO (unique) | Supabase question ID |
| articleId | TEXT | NO | Reference to article |
| stem | TEXT | NO | Question text |
| optionA | TEXT | NO | Answer option A |
| optionB | TEXT | NO | Answer option B |
| optionC | TEXT | NO | Answer option C |
| optionD | TEXT | NO | Answer option D |
| correctOption | TEXT | NO (len 1) | 'A', 'B', 'C', or 'D' |
| explanation | TEXT | NO | Answer explanation |
| category | TEXT | NO | Question category |
| difficulty | TEXT | NO (default 'medium') | easy/medium/hard |
| testedField | TEXT | NO (default 'clinicalFeatures') | Section being tested |
| wrongCount | INTEGER | NO (default 0) | Incremented on wrong answer |
| lastAttemptedAt | INTEGER | YES | Unix timestamp |
| easeFactor | REAL | NO (default 2.5) | SM-2 ease factor |
| repetitions | INTEGER | YES | SM-2 repetition count |
| nextDueAt | INTEGER | YES | Unix timestamp for next review |
| lastQuality | INTEGER | YES | User quality rating 0-5 |

**Indexes:**
- None declared in Drift

**Purpose:**
- Store quiz questions locally
- SM-2 scheduling columns
- `last_quality` added via `_ensureQuizTableSm2Columns` (migration 9)

**Schema History:**
- v4: Created (dropped legacy `QuizQuestions` table)
- v5: Added srInterval, repetitions, nextDueAt
- v9: Added easeFactor, lastQuality, testedField, wrongCount columns (raw SQL)

**Note:** Drift schema declares `easeFactor`, `repetitions`, `nextDueAt` but NOT `lastQuality`. DB has it via migration.

---

### 5. quiz_table (QuizQuestions - UNUSED)

**File:** `lib/core/database/app_database.dart:51-63`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | NO (autoIncrement) | Local ID |
| articleId | TEXT | YES | Old reference |
| stem | TEXT | NO | Question text |
| optionA/B/C/D | TEXT | NO | Options |
| correctOption | TEXT | NO | Correct answer |
| explanation | TEXT | YES | Explanation |
| category | TEXT | YES | Category |
| difficulty | TEXT | YES | Difficulty |

**Status:** Declared in `@DriftDatabase` but data redirected to `quiz_table`. Safe to remove.

---

### 6. view_history

**File:** Created via raw SQL in `lib/core/database/app_database.dart:328-359`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | INTEGER | NO (autoIncrement) | Row ID |
| article_id | TEXT | NO | Reference to article |
| article_title | TEXT | YES | Denormalized for display |
| category | TEXT | YES | Denormalized for filtering |
| viewed_at | TEXT | NO (default '') | Timestamp |

**Purpose:** Track article reads for heatmap

**Schema History:**
- Not in Drift schema, created on-demand via `_ensureViewHistoryTable`

---

## Virtual Tables

### article_search_fts

**File:** Created in `lib/features/articles/data/article_search_provider.dart:262-270`

| Column | Type | Description |
|--------|------|-------------|
| article_id | UNINDEXED | FK to articles.id |
| title | TEXT | Search indexed |
| content | TEXT | Search indexed |
| category | TEXT | Search indexed |

**Tokenizer:** unicode61 remove_diacritics 2

**Purpose:** Full-text search with ranking

---

## Migration History

| Version | Changes | File Reference |
|---------|---------|----------------|
| 1→2 | Create `bookmarks` table | app_database.dart:117-119 |
| 2→3 | Create `quizQuestions` table | app_database.dart:123-127 |
| 3→4 | Drop `quizQuestions`, create `quizTable` | app_database.dart:129-128 |
| 4→5 | Add `srInterval`, `repetitions`, `nextDueAt` | app_database.dart:130-142 |
| 5→6 | Add `articles.isHighYield` | app_database.dart:144-148 |
| 6→7 | Add `articles.subcategory` | app_database.dart:150-154 |
| 7→8 | Ensure `study_sessions` exists with all columns | app_database.dart:155-158 |
| 8→9 | Ensure `quiz_table` SM-2 columns | app_database.dart:159-160 |

---

## Unused/Legacy Columns

| Table | Column | Issue |
|-------|--------|-------|
| study_sessions | session_date | Migration column, not read |
| quiz_table | wrongCount | Not updated anywhere |
| quiz_table | lastAttemptedAt | Type mismatch (DateTime vs INTEGER in queries) |

---

## Future Risks

1. **FTS5 Index** — Not automatically rebuilt on new article insert
2. **Quiz table** — Missing `last_quality` in Drift schema but used in code
3. **Study sessions** — Drift schema declares DateTime but actual table uses TEXT
4. **No WAL mode** — Could improve concurrent read performance
5. **No partial indexes** — Quiz queries scan all due cards