# WardReady — PRODUCTION_READINESS

## Crash Risks

### Lifecycle Misuse

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| DatabaseRecoveryScreen.exit(0) | `lib/core/screens/database_recovery_screen.dart:63` | Medium | `exit(0)` terminates Dart VM without Flutter cleanup | Replace with `SystemNavigator.routeInformationUpdated` | Verified |
| SessionTimeout timer not disposed on early error | `lib/core/providers/connectivity_notifier.dart:33` | Low | Timer starts in constructor; if provider fails before mounted, timer may leak | Lazy-start timer in first `markOffline` call | Verified |
| QuizNotifier service dependencies created in build() | `lib/features/quiz/quiz_notifier.dart:31-36` | Medium | Services looked up in `build()` family; async not supported | Move to `providerScope.container` injection | Verified |

### Mounted Issues

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| _runAfterBuild pattern in article_list_screen | `lib/features/home/presentation/article_list_screen.dart:63-65,283-286,322-333` | Low | Uses microtask properly with mounted checks | Acceptable pattern | Verified |
| All async callbacks check mounted | All files | Low | Consistent pattern | No fix needed | Verified |

### Async Races

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Admin redirect without loading state | `lib/main.dart:152-159` | Medium | Redirect awaits `currentAdminProfileProvider.future` without handling slow network | Add redirectDelay or splash | Verified |
| Subscription check race on resume | `lib/app/main_shell.dart:37-39` | Low | Every 30min check could show banner during navigation | Disable during transitions | Verified |
| Quiz sync resets state during load | `lib/features/quiz/quiz_notifier.dart:153-161` | Medium | `syncQuestions` sets loading state, could interrupt active quiz | Check quiz state before sync | Verified |

### Navigation Races

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| No /exam route defined | `lib/features/quiz/exam_session_notifier.dart` | High | Notifier exists but GoRouter has no route | Add `/exam` route | Verified |
| Article detail extra could be wrong type | `lib/main.dart:144-148` | Medium | `state.extra` cast without type check | Validate type before cast | Verified |

### Provider Invalidation Storm

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| 25+ category progress invalidations after sync | `lib/features/home/presentation/categories_screen.dart:135-142` | High | Loop over all categories calling `invalidate` | Single aggregated provider | Verified |

### Null Safety Edge Cases

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| article.detail null route extra | `lib/main.dart:144` | High | `state.extra! as ArticleLocal` crashes if wrong type | Safe cast with fallback | Verified |
| Colors.grey[300]! in shimmer | Multiple files | Low | Grey swatch can return null | Use Colors.grey.shade300 | Verified |
| last_quality column missing in Drift schema | `lib/core/database/app_database.dart:67-89` | Medium | Column used but not declared | Add column to QuizTable | Verified |

### Initialization Ordering

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| authServiceProvider.initialize() never called | `lib/features/auth/data/auth_service.dart:129-139` | CRITICAL | Session restore method exists but not invoked | Call in main() after Supabase init | Verified |
| NotificationService not initialized on app start | `lib/core/services/notification_service.dart:86` | Medium | Only initialized when scheduling | Initialize on app start if enabled | Verified |

---

## Memory Risks

### Listeners

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| All ScrollController listeners properly removed | Multiple | Low | Good pattern | No fix needed | Verified |

### Controllers

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| No TextEditingController leaks | Multiple | Low | None found | No fix needed | Verified |

### Streams

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Drift streams auto-dispose via Riverpod | All | Low | Proper pattern | No fix needed | Verified |

### Timers

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Session timeout timer | `lib/core/providers/session_timeout_provider.dart:19,35` | Low | Properly disposed via _cleanup on onDispose | No fix needed | Verified |
| Sync rate limit timer | `lib/core/providers/sync_state_provider.dart:49,81-86` | Low | Properly disposed | No fix needed | Verified |
| Subscription check timer | `lib/app/main_shell.dart:27,74` | Low | Properly disposed | No fix needed | Verified |
| Connectivity polling timer | `lib/core/providers/connectivity_notifier.dart:34-36` | Medium | Starts immediately; no backoff | Add exponential backoff | Verified |

### Subscriptions

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| StreamBuilder in article_detail_screen | `lib/features/articles/presentation/article_detail_screen.dart:151` | Low | Properly managed by Riverpod | No fix needed | Verified |

### autoDispose Opportunities

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| No autoDispose on search controller | `lib/features/articles/data/article_search_provider.dart:22-30` | Low | Actually uses autoDispose | No fix needed | Verified |
| articleOffsetProvider not autoDispose | `lib/features/home/presentation/article_list_screen.dart:12` | Medium | Persists across screen reopens | Add autoDispose | Verified |

---

## Performance

### Rebuild Hotspots

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Settings screen rebuilds all items | `lib/features/settings/presentation/settings_screen.dart:44-224` | Medium | Entire list rebuilt on state change | ListView.builder with itemBuilder | Verified |
| Category progress invalidation storm | `lib/features/home/presentation/categories_screen.dart:120-143` | High | 25+ invalidations trigger 25+ DB queries | Consolidate into single provider | Verified |

### Expensive Synchronous Work

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| FTS5 rebuild loops all articles | `lib/features/articles/data/article_search_provider.dart:279-298` | High (scale) | Sync loop over all articles blocks UI | Background isolate | Verified |
| Exam question selection N+1 queries | `lib/features/quiz/exam_session_notifier.dart:128-207` | High (scale) | 17 sequential queries per domain | Single query with UNION ALL | Verified |
| All clinical sections built at once | `lib/features/articles/presentation/article_detail_screen.dart:429-480` | Medium | All 19 section widgets created even when collapsed | Lazy build or const widgets | Verified |

### Database Bottlenecks

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| No index on quiz_table.next_due_at | `lib/features/quiz/spaced_repetition_service.dart:41-65` | Medium (scale) | Query scans all questions for due cards | Add index in migration | Verified |
| Admin fetchAllUsers unpaginated | `lib/features/admin/data/admin_repository.dart:54-64` | High | Returns entire user table | Add limit/offset | Verified |

### Unnecessary Riverpod Rebuilds

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| allArticlesProvider rebuilds on all article changes | `lib/features/articles/data/article_repository.dart:253-258` | Medium | Stream watches all articles | Separate stream per category | Verified |

### Large Widget Trees

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Progress screen stat cards | `lib/features/progress/progress_screen.dart:82-109` | Low | 4 Flexible children in Row | Acceptable | Verified |

### Search Efficiency

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| FTS5 fallback to full scan | `lib/features/articles/data/article_search_provider.dart:191-201` | Medium | On corruption, scans entire table | Limit fallback or disable | Verified |

---

## Security

| Issue | File | Risk | Root Cause | Fix | Verified |
|-------|------|------|------------|-----|----------|
| Supabase keys with empty defaults | `lib/app/env.dart:2-8` | CRITICAL | `String.fromEnvironment` defaults to empty string | Validate non-empty in release | Verified |
| No FLAG_SECURE for medical content | `android/app/src/main/AndroidManifest.xml` | HIGH | No screenshot prevention | Add `android:flags="FLAG_SECURE"` | Verified |
| allowBackup not set | `android/app/build.gradle.kts` | MEDIUM | Default true, may backup database | Add `allowBackup="false"` | Verified |
| Database not encrypted | `lib/core/database/app_database.dart` | LOW | Plain SQLite files | SQLCipher or accept risk | Verified |
| Notification permission missing | `lib/core/services/notification_service.dart:115` | CRITICAL | Code requests but no runtime check | Check before enabling toggle | Verified |
| key.properties required for release | `android/app/build.gradle.kts:10-14` | HIGH | Signing config fails without file | Create CI template | Verified |

---

## Offline Architecture Verification

### Graceful Cache Falls Back

| Feature | File | Offline Behavior | Status |
|---------|------|------------------|--------|
| Articles sync | `lib/features/articles/data/article_repository.dart:70-86` | Returns local cache on 403/401/429/503/504/SocketException | VERIFIED |
| Quiz questions | `lib/features/quiz/quiz_repository.dart:63-64,80-81` | Returns local cache on errors | VERIFIED |
| Search | `lib/features/articles/data/article_search_provider.dart:191-201` | Falls back to full scan on FTS5 error | VERIFIED |

### Potential Offline Failures

| Issue | File | Risk | Description |
|-------|------|------|-------------|
| DatabaseRecovery exit(0) | `lib/core/screens/database_recovery_screen.dart:63` | Medium | Poor UX but not crash |
| Search index corruption persists | `lib/features/articles/data/article_search_provider.dart` | Low | Full scan works but slow |
| No disk full handling in UI | `lib/core/providers/sync_state_provider.dart` | Medium | Provider set but no banner shown |

---

## Riverpod Architecture

### Provider Cycles

| Issue | File | Risk | Status |
|-------|------|------|--------|
| No cycles detected | All | Low | VERIFIED |

### Provider Misuse

| Issue | File | Risk | Description |
|-------|------|------|-------------|
| QuizNotifier services in build() | `lib/features/quiz/quiz_notifier.dart:31-36` | Medium | Creates dependencies in build |
| Repository callbacks to providers | `lib/features/articles/data/article_repository.dart:238-250` | Medium | Side effects in repository |

### Overly Broad Providers

| Issue | File | Risk | Fix |
|-------|------|------|-----|
| allArticlesProvider watches all changes | `lib/features/articles/data/article_repository.dart:253` | Medium | Separate per-category |

### State Duplication

| Issue | File | Risk | Description |
|-------|------|------|-------------|
| categoryProgressProvider many copies | `lib/features/progress/category_progress_provider.dart` | Medium | One per category (25+ instances) |

### Missing autoDispose

| Issue | File | Risk | Fix |
|-------|------|------|-----|
| articleOffsetProvider | `lib/features/home/presentation/article_list_screen.dart:12` | Medium | Add autoDispose |

---

## Flutter Best Practices

| Issue | File | Violation | Fix |
|-------|------|-----------|-----|
| Using `unawaited` on futures | Multiple | Acceptable but explicit error handling preferred | Add try/catch in callbacks |
| Colors.grey[300]! null assertions | 12+ files | Unsafe | Use Colors.grey.shade300 |
| Shimmer base/highlight hardcoded | Multiple | Could use theme | Extract to constants |
| No const constructors where possible | Multiple | Minor perf | Use const where possible |

---

## Release Blockers

| Priority | Issue | File | Fix | Effort |
|----------|-------|------|-----|--------|
| CRITICAL | Supabase key validation | `lib/app/env.dart` | Assertion in main() | 30m |
| CRITICAL | Notification permission | `lib/core/services/notification_service.dart` | Runtime check before enable | 2h |
| CRITICAL | Session restore not called | `lib/features/auth/data/auth_service.dart` | Call initialize() in main | 15m |
| HIGH | FLAG_SECURE missing | `android/app/src/main/AndroidManifest.xml` | Add flag | 15m |
| HIGH | EHPLE Exam Mode missing UI | `lib/features/quiz/exam_session_notifier.dart` | Add /exam route + screen | 8h |
| HIGH | Admin pagination | `lib/features/admin/data/admin_repository.dart` | Add limit/offset | 4h |
| MEDIUM | Database recovery UX | `lib/core/screens/database_recovery_screen.dart` | Replace exit(0) | 30m |

---

## Technical Debt V2

### Critical
| Issue | File | Effort | Risk |
|-------|------|--------|------|
| QuizNotifier tri-service coupling | `lib/features/quiz/quiz_notifier.dart:17-34` | 4h | Breaks all quiz on refactor |

### High
| Issue | File | Effort | Risk |
|-------|------|--------|------|
| Exam question N+1 queries | `lib/features/quiz/exam_session_notifier.dart:128-207` | 3h | Slow exam start |
| Notification permission flow | `lib/core/services/notification_service.dart` | 2h | Android 13+ broken |
| FLAG_SECURE | `android/app/src/main/AndroidManifest.xml` | 15m | Policy violation |
| Admin pagination | `lib/features/admin/data/admin_repository.dart` | 4h | Scale failure |

### Medium
| Issue | File | Effort | Risk |
|-------|------|--------|------|
| Quiz table schema mismatch | `lib/core/database/app_database.dart` | 30m | last_quality not in schema |
| Provider invalidation storm | `lib/features/home/presentation/categories_screen.dart` | 2h | UI jank |
| Unused QuizQuestions table | `lib/core/database/app_database.dart:51-63` | 15m | Dead schema |
| Unused fsrs/google_fonts | `pubspec.yaml` | 15m | APK bloat |

### Low
| Issue | File | Effort | Risk |
|-------|------|--------|------|
| Colors.grey[]! null assertions | Multiple files | 1h | Possible dark mode crash |
| Shimmer duplication | Multiple | 30m | Code duplication |
| Search history no error handling | `lib/features/search/search_history_service.dart` | 30m | Silent failures |