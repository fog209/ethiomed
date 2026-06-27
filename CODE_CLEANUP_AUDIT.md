# WardReady — CODE_CLEANUP_AUDIT.md

## Dead Code

### Unused Tables

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| `lib/core/database/app_database.dart:51-63,92` | `QuizQuestions` table | No code references it; migrated to `quiz_table` in v4 | LOW | SAFE TO DELETE |
| - | - | 92 in `@DriftDatabase` | Never queried | SAFE TO DELETE |

### Unused Providers

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| `lib/features/quiz/data/quiz_sync_service.dart:1` | Re-export file | Just exports parent directory's service | LOW | SAFE TO DELETE |
| `lib/features/search/search_screen.dart:9` | `selectedCategoryProvider` | Defined but screen unused | LOW | SAFE TO DELETE with screen |

### Unused Dependencies

| Package | File | Evidence | Risk | Action |
|---------|------|----------|------|--------|
| fsrs | `pubspec.yaml:18` | No import anywhere in lib/ | NONE | SAFE TO DELETE |
| google_fonts | `pubspec.yaml:20` | No import anywhere in lib/ | NONE | SAFE TO DELETE |

### Unused Service

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| `lib/features/quiz/quiz_sync_service.dart` | QuizSyncService | Wraps repository with duplicate error handling | LOW | SAFE TO DELETE (use repository directly) |

### Unused Screens

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| `lib/features/search/search_screen.dart` | Entire file | main_shell.dart line 11 imports `article_search_screen.dart`, not this file | NONE | SAFE TO DELETE |

---

## Duplicate Code

### Shimmer Loading Patterns

| Files | Element | Evidence | Risk | Action |
|-------|---------|----------|------|--------|
| article_list_screen.dart, categories_screen.dart, quiz_screen.dart, article_detail_screen.dart, admin_dashboard_screen.dart, article_search_screen.dart, search_screen.dart | _buildShimmer methods | Same Shimmer.fromColors patterns repeated | LOW | REFACTOR_CANDIDATE |

### Error Handling Patterns

| Files | Element | Evidence | Risk | Action |
|-------|---------|----------|------|--------|
| quiz_repository.dart, article_repository.dart | PostgrestException handling | Same try/catch/rethrow pattern | LOW | KEEP (consistent) |

### Navigation Patterns

| Files | Element | Evidence | Risk | Action |
|-------|---------|----------|------|--------|
| Multiple screens | `context.canPop() ? context.pop() : context.go('/home')` | Repeated back pattern | LOW | KEEP (idiomatic) |

---

## Obsolete Code

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| `lib/core/database/app_database.dart:230` | `session_date` column | Used only for migration v8 | LOW | KEEP (migration) |
| lib/app/nav_provider.dart:3 | Comment says tabs = 4 | Code has 6 tabs (line 94-102 in main_shell.dart) | LOW | SAFE TO DELETE comment |

---

## Import Cleanup

| File | Unused Import | Evidence | Risk | Action |
|------|---------------|----------|------|--------|
| quiz_sync_service.dart | `dart:io` | Only used for SocketException rethrow | VERIFY | LIKELY KEEP |
| quiz_sync_service.dart | `dio` | Only catches DioException | VERIFY | NEEDED |

---

## Widget Cleanup

| File | Element | Evidence | Risk | Action |
|------|---------|----------|------|--------|
| All screens | Multiple StatefulWidgets | Could use ConsumerWidget + StateProvider | LOW | KEEP (appropriate) |
| article_list_screen.dart | StateProviders not autoDispose | `articleOffsetProvider` etc persist after screen closed | MEDIUM | REFACTOR_CANDIDATE |

---

## Naming Cleanup

| File | Element | Issue | Risk | Action |
|------|---------|-------|------|--------|
| pubspec.yaml | `name: ethiomed` | Old project name; app is WardReady | LOW | SAFE TO RENAME in pubspec.yaml:1 |
| AGENTS.md references | EthioMed | Old naming | LOW | KEEP (archival) |

---

## Files That Can Be Merged

| File | Merge With | Evidence | Risk |
|------|-----------|----------|------|
| quiz_sync_service.dart (data/) | quiz_sync_service.dart (features/quiz/) | Duplicate functionality | NONE |
| search_screen.dart | DELETE instead | Not used | NONE |