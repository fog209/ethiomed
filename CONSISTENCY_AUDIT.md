# WardReady — CONSISTENCY_AUDIT.md

## Executive Summary

**Overall Consistency Score: 72/100**

The codebase shows good consistency in core patterns (Riverpod, navigation, error handling) but has significant inconsistencies in:
- Widget libraries (multiple shimmer implementations)
- Duplicate search screens
- Mixed database patterns (Drift vs raw SQL)
- Duplicate model definitions (Article vs ArticleContent)
- Unused code alongside active code

### Strengths
- Unified Riverpod state management
- Consistent navigation patterns
- Good error handling patterns in repositories
- Offline-first fallback everywhere

### Weaknesses
- Two search screen implementations
- Duplicate shimmer loading patterns
- Raw SQL mixed with Drift ORM
- Unused ArticleContent class
- Unused notification banner function

---

## Critical Inconsistencies (Fix Before Release)

### 1. Duplicate Search Screens

| File | Issue | Risk |
|------|-------|------|
| `lib/features/search/search_screen.dart` | Complete duplicate of article_search_screen.dart | HIGH — Confusion, maintenance burden |
| `lib/features/articles/presentation/article_search_screen.dart` | Used in main_shell.dart line 11 | HIGH — Only used screen |

**Recommendation:** Delete `lib/features/search/search_screen.dart`

### 2. Unused ArticleContent Class

| File | Issue | Risk |
|------|-------|------|
| `lib/features/articles/models/article_model.dart` | ArticleContent never imported | MEDIUM — Technical debt |

**Recommendation:** Delete file

### 3. Unused showDiskFullBanner Function

| File | Issue | Risk |
|------|-------|------|
| `lib/core/widgets/error_banners.dart:3-17` | Function defined but never called | LOW — Dead code |

**Recommendation:** Delete or implement usage

### 4. QuizSyncService Wrapper

| File | Issue | Risk |
|------|-------|------|
| `lib/features/quiz/quiz_sync_service.dart` | Wraps repository with identical error handling | MEDIUM — Unnecessary indirection |

**Recommendation:** Delete and use repository directly

---

## High-Value Refactors

### Effort: Low

1. **Extract shimmer widgets** — 7 files have duplicate `_buildShimmer...` methods
2. **Remove unused dart:io imports** where only exceptions are caught
3. **Add autoDispose to pagination providers** in article_list_screen.dart

### Effort: Medium

1. **Consolidate database access** — Use Drift for all queries instead of raw SQL
2. **Remove QuizQuestions table** from Drift schema
3. **Standardize error handling** — Some repositories swallow errors, others rethrow

### Effort: High

1. **ArticleContent model cleanup** — Remove unused model
2. **Repository callback pattern** — Repositories directly call providers, should use events
3. **FTS5 rebuild optimization** — Move to background isolate

---

## Standardization Opportunities

| Pattern | Locations | Recommendation |
|---------|-----------|----------------|
| Shimmer loading | 7 files | Extract to `core/widgets/shimmer_loading.dart` |
| Debug logging | All files | Standardize on `debugPrint` only |
| Color grey access | 12 files | Use `Colors.grey.shade300` instead of `[300]!` |
| Category progress | Each category has own provider | Consolidate to single provider |
| Navigation back | Every screen | Extract helper: `safePopOrHome(context)` |
| Empty state | Multiple | Extract to shared `EmptyState` widget (already exists) |
| Error SnackBar | Multiple places | Extract to `showErrorSnackBar(context, message)` |

---

## False Positives

| Finding | Evidence |
|---------|----------|
| Two article model files | `domain/models/article.dart` vs `models/article_model.dart` — domain is for remote, models for local; intentional but confusing |
| Raw SQL in Drfit database | Migration methods intentionally use raw SQL for schema evolution — acceptable |
| Multiple shimmer implementations | Each has different dimensions; could be intentional for UX |

---

## Recommended Coding Standards

### Providers
```dart
// Use autoDispose for screen-scoped state
final myProvider = StateNotifierProvider.autoDispose<MyNotifier, MyState>((ref) {
  return MyNotifier(ref.watch(dependencyProvider));
});

// Use AsyncNotifier for async data
final myDataProvider = AsyncNotifierProvider<MyNotifier, MyData>((ref) {
  return MyNotifier(ref);
});
```

### Repositories
```dart
// Throw exceptions, let UI handle
try {
  return await supabase.from('table').select();
} on PostgrestException catch (e) {
  final status = postgrestStatus(e);
  if (status == 403) return getLocalCache(); // Offline-first
  throw AppException(e.message);
}

// Do NOT call providers directly; return results only
```

### Async
```dart
// Always check mounted after await
if (!mounted) return;
await someOperation();
if (!mounted) return;

// Use microtask for post-frame operations
Future.microtask(() { ... });
```

### Navigation
```dart
// Safe back pattern
context.canPop() ? context.pop() : context.go('/home');

// Route extra validation
final extra = state.extra;
if (extra is MyType) return MyScreen(data: extra);
return MyScreen(); // fallback
```

### Logging
Use `debugPrint()` consistently. Never use `print()` in production code.

### Error Handling
- Catch specific exceptions (PostgrestException, SocketException, DioException)
- Return cached data on network errors
- Throw `AppException` for UI to show
- Log with `debugPrint` before rethrow

### Theming
```dart
// Use ColorScheme
Theme.of(context).colorScheme.primary

// NOT Colors.grey[300]!
Colors.grey.shade300
```

### Database Access
- Use Drift ORM for all queries
- Only use raw SQL for migrations or FTS5
- Add indexes for queried columns

---

## Final Verdict

**Rating: Good**

The codebase is **Good** overall. The core architecture patterns are consistent (Riverpod, offline-first, error handling). However, there are:

1. **Duplicate implementations** (two search screens, shimmer patterns)
2. **Unused code** (ArticleContent, showDiskFullBanner, fsrs package)
3. **Mixed patterns** (Drift ORM vs raw SQL in same file)
4. **Legacy migrations** still active (session_date column)

These issues are **maintenance burdens** but do not break the application. The codebase is ready for release after fixing the critical inconsistencies (duplicate search screen and unused dependencies).