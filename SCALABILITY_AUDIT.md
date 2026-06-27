# WardReady — SCALABILITY_AUDIT.md

## Executive Summary

**Scalability Score: 58/100**

The codebase scales moderately well for the current user base but has **critical bottlenecks** at 25K+ articles and 100K+ quiz questions. Database queries, FTS5 indexing, and exam question selection will become performance-critical. Riverpod architecture handles state well, but sync storms and memory pressure will emerge.

---

## Current Bottlenecks

### 1. FTS5 Search Index Rebuild

| File | Lines | Risk |
|------|-------|------|
| `lib/features/articles/data/article_search_provider.dart:278-298` | `_ensureSearchIndex()` rebuilds entire FTS5 index on mismatch | **Critical** — O(n) full rebuild on every sync |

**Evidence:**
```dart
// Line 278-298
await _db.customStatement('DELETE FROM article_search_fts');
final articles = await _db.select(_db.articles).get();
for (final article in articles) {
  await _db.customStatement(...); // Individual inserts
}
```

With 25,000 articles, each sync triggers 25K+ individual inserts.

### 2. Exam Question N+1 Query Pattern

| File | Lines | Risk |
|------|-------|------|
| `lib/features/quiz/exam_session_notifier.dart:128-208` | `_selectWeighted200Questions()` runs sequential queries per category | **Critical** — 17 sequential queries for exam start |

**Evidence:**
- Loop at line 137: `for (final entry in domainWeights.entries)`
- Query per category at line 145-156
- Fill remainder query at line 173-184

With 100 categories, this becomes 100+ sequential queries.

### 3. Category Progress Sequential Queries

| File | Lines | Risk |
|------|-------|------|
| `lib/features/progress/progress_notifier.dart:99-110` | `_loadCategoryProgress()` queries each category sequentially | **High** — N queries for N categories |

**Evidence:**
```dart
// Line 99-110
for (final c in categories) {
  final total = await _db.countArticlesByCategory(category);
  final read = await _db.countReadArticlesByCategory(category);
}
```

### 4. Admin User Load-All Pattern

| File | Lines | Risk |
|------|-------|------|
| `lib/features/admin/data/admin_repository.dart:54-63` | `fetchAllUsers()` loads all users without pagination | **Medium** — Memory pressure with thousands of users |

---

## Five-Year Growth Risks

### Database Growth

| Metric | Current | Target | Risk |
|--------|---------|--------|------|
| Articles | ~250 | 25,000 | **High** — FTS5 rebuild time grows linearly |
| Quiz questions | ~2,000 | 100,000 | **Medium** — Exam select becomes slower |
| Categories | ~20 | 100 | **High** — N+1 query explosion |
| Users | ~100 | 100,000 | **High** — Admin list needs pagination |

### Memory Growth

| Component | Risk | Evidence |
|-----------|------|----------|
| Cached articles | High | `allArticlesProvider` watches entire table |
| Cached quiz questions | Medium | `QuizNotifier` loads all due + new cards |
| Scroll controllers | Low | One per screen, properly disposed |
| FTS5 index size | High | Stored in SQLite, grows with article count |

### Network Growth

| Component | Risk | Evidence |
|-----------|------|----------|
| Sync bandwidth | High | Full article sync on every refresh |
| Rate limiting hits | Medium | No exponential backoff on retries |
| Supabase bills | High | Per-query pricing with sequential queries |

---

## Performance Risks

### Database Query Performance

| Query | Current Time | Target Time | Risk |
|-------|--------------|-------------|------|
| `countArticlesByCategory` | <1ms | <10ms | Low |
| `countReadArticlesByCategory` (JOIN) | <5ms | <50ms | Medium |
| FTS5 full rebuild (25K articles) | ~1s | ~30s | **High** |
| Exam question selection (17 queries) | ~50ms | ~2s | **High** |

### UI Performance

| Screen | Issue | Risk |
|--------|-------|------|
| CategoriesScreen | `GridView.builder` with 12 categories works, 100 will be slow | Medium |
| ProgressScreen | `ListView` with 100 category rows | Low |
| QuizScreen | `AsyncNotifier` loads 200 questions OK, 1000 may be slow | Medium |
| ArticleListScreen | Pagination works, but FTS5 search may block UI | High |

---

## Database Risks

### Missing Indexes

| Table | Column | Evidence | Risk |
|-------|--------|----------|------|
| `view_history` | `article_id` | No index shown | Medium |
| `quiz_table` | `next_due_at` | Used in queries but no index | Medium |
| `quiz_table` | `last_quality` | Used in aggregations | Medium |
| `articles` | `is_high_yield` | Filtered but no index | Low |

### FTS5 Scaling

| Issue | Evidence | Risk |
|-------|----------|------|
| Full rebuild on mismatch | `article_search_provider.dart:278` | **Critical** |
| No incremental updates | Insert-all pattern | **Critical** |
| No index size limit | SQLite unbounded | High |

### Transactions

All transactions are properly scoped:
- `article_repository.dart:51` — Article upserts
- `quiz_repository.dart:110` — Question upserts  
- `spaced_repetition_service.dart:69` — Review recording

**Status:** Correct usage, no issues.

---

## State Management Risks

### Provider Count Growth

Current providers (~30):
- 15+ StateNotifierProviders
- 8+ FutureProviders
- 5+ StreamProviders

At 100K users, this could grow to 50-100 providers.

### Rebuild Behavior

| Provider | Risk | Evidence |
|----------|------|----------|
| `allArticlesProvider` | High | Watches entire articles table, rebuilds on any change |
| `categoryProgressProvider` | Medium | One provider per category |
| `streakNotifierProvider` | Low | Only rebuilds on user action |
| `quizNotifierProvider` family | Medium | Per-category notifier |

### AutoDispose Gaps

| Provider | Issue | Risk |
|----------|-------|------|
| `articleOffsetProvider` | No autoDispose | Medium |
| `articleLoadedArticlesProvider` | No autoDispose | Medium |
| `articleHasMoreProvider` | No autoDispose | Medium |

State persists after screen dispose.

---

## Architecture Risks

### Sync Storms

| Trigger | Risk |
|---------|------|
| Network reconnect | `connectivity_notifier.dart:34` fires timer immediately |
| App resume | `main.dart:267` resets session timer without debounce |
| Multiple retry clicks | `categories_screen.dart:97` invalidates without backoff |

### Single Points of Failure

| Component | Risk |
|-----------|------|
| `main.dart` routing + auth + error handling | God component |
| `app_database.dart` singleton | Single DB file |
| `sync_state_provider` | Central sync state |
| `Supabase.instance` | Single backend |

---

## Recommended Refactors

### Critical (Effort: 2-4 weeks)

| Refactors | Effort | Benefit |
|-----------|--------|---------|
| Incremental FTS5 indexing | 2 weeks | 100x faster search updates |
| Batch quiz question selection | 1 week | Parallel queries, faster exam start |
| Category progress caching | 3 days | Single query instead of N |
| Admin pagination | 2 days | Memory safe user list |

### High (Effort: 1-2 weeks)

| Refactors | Effort | Benefit |
|-----------|--------|---------|
| Add database indexes | 2 days | 10x query speed |
| Exponential backoff on sync retry | 1 day | Prevent rate limit lockouts |
| AutoDispose pagination providers | 1 day | Clean state on navigation |
| Sync guard mutex | 2 days | Prevent overlapping syncs |

### Medium (Effort: Days)

| Refactors | Effort | Benefit |
|-----------|--------|---------|
| Incremental view history update | 1 day | Faster article view recording |
| Memoize category counts | 1 day | Reduce redundant queries |
| Debounce connectivity check | 1 day | Prevent sync storms |

---

## Growth Roadmap

### Year 1 (Current)
- Monitor FTS5 rebuild time
- Track sync duration metrics

### Year 2
- Implement incremental search indexing
- Add database indexes for hot queries

### Year 3
- Admin pagination
- Batch quiz operations

### Year 4-5
- Sharding strategy for large datasets
- Background isolate for heavy operations
- Caching layer for progress stats

---

## Final Verdict

**Rating: Significant Refactoring Needed**

The codebase is **barely scalable** (58/100) for the target growth.

**Critical issues:**
1. **FTS5 rebuilds all 25K articles on every sync** — O(n) disaster
2. **Exam question selection runs 17 sequential queries** — 100 categories = 100 queries
3. **Admin loads all users** — Will crash at 10K users

**Strengths:**
1. Paging works well for articles
2. Drift transactions are correct
3. Riverpod structure is sound

**Immediate actions:**
1. Add indexes to `quiz_table` and `view_history`
2. Implement incremental FTS5 updates
3. Add pagination to admin user list
4. Add sync mutex to prevent overlap