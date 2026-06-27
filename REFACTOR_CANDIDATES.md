# WardReady — REFACTOR_CANDIDATES.md

## Duplicate Code to Consolidate

| Files | Element | Evidence | Effort |
|-------|---------|----------|--------|
| 7 files | Shimmer loading patterns | `_buildShimmer...()` methods with identical structure | 2h |

---

## StateProviders to autoDispose

| Provider | Current | Issue | Effort |
|----------|---------|-------|--------|
| articleOffsetProvider | Not autoDispose | Persists after screen closed | 15m |
| articleLoadedArticlesProvider | Not autoDispose | Memory persists unnecessarily | 15m |
| articleHasMoreProvider | Not autoDispose | State leaks between sessions | 15m |
| articleIsLoadingMoreProvider | Not autoDispose | Could show stale loading state | 15m |
| articleCurrentCategoryProvider | Not autoDispose | Used only for pagination | 15m |
| articleRequestIdProvider | Not autoDispose | Should reset on screen open | 15m |

---

## Quiz Service Architecture

| File | Issue | Evidence | Effort |
|------|-------|----------|--------|
| quiz_notifier.dart:17-34 | Service coupling | Reads 3 services in build() | 4h |
| quiz_sync_service.dart | Redundant wrapper | Wraps repository with same error handling | 30m |
| SpacedRepetitionService | Uses raw SQL | Drift ORM available but bypassed | 2h |

---

## Search Screens

| File | Issue | Evidence | Effort |
|------|-------|----------|--------|
| search_screen.dart | Duplicate screen | main_shell uses article_search_screen.dart | DELETE instead of refactor |

---

## Database Schema

| Table | Issue | Evidence | Effort |
|-------|-------|----------|--------|
| study_sessions | Uses raw SQL | Drift schema declares DateTime, actual uses TEXT | 1h |
| view_history | Uses raw SQL | Created via customStatement in app_database | 1h |
| quiz_table | Missing column | last_quality used but not declared in schema | 30m |

---

## Navigation

| Pattern | Issue | Evidence | Effort |
|---------|-------|----------|--------|
| context.canPop() ? pop() : go('/home') | Repeated everywhere | Code style indicates common pattern | 30m to extract helper |

---

## Color Usage

| Pattern | Issue | Evidence | Effort |
|---------|-------|----------|--------|
| Colors.grey[300]! | Null assertion | Could return null in some themes | 1h to replace with .shade300 |

---

## Provider Ownership

| Provider | Issue | Evidence | Effort |
|----------|-------|----------|--------|
| Repository callbacks | Repositories call state providers | Direct coupling between data and UI layers | 3h to use event pattern |