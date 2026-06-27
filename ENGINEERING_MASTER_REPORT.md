# WardReady — ENGINEERING_MASTER_REPORT.md

## 1. Executive Summary

**Overall Engineering Score: 74/100**

The WardReady codebase is a well-architected offline-first Flutter application demonstrating mature engineering practices. Riverpod state management, Drift database, and GoRouter navigation are implemented consistently. Performance and security foundations are solid but require targeted improvements before full production scale.

| Category | Score (0-100) |
|----------|---------------|
| Architecture | 82 |
| Code Quality | 75 |
| Lifecycle Safety | 75 |
| Repository Design | 78 |
| State Management | 80 |
| Offline-first Design | 88 |
| Theme System | 72 |
| Performance | 71 |
| Security | 73 |
| Maintainability | 76 |
| Testability | 62 |
| Release Readiness | 76 |

---

## 2. Biggest Strengths

### Offline-First Architecture
**Why good:** Every repository returns cached data on network failure, ensuring the app never shows blank screens.

**Evidence:** `article_repository.dart:75-77`, `quiz_repository.dart:64-65`, `subscription_repository.dart:52-53`

### Riverpod State Consistency
**Why good:** Unified AsyncNotifier/FamilyAsyncNotifier pattern across all features.

**Evidence:** `quiz_notifier.dart:11`, `progress_notifier.dart:32`, `article_search_provider.dart:26-30`

### Drift Database Design
**Why good:** Proper transactions, migration strategy, and repository pattern.

**Evidence:** Schema versions 1-9 with graceful error handling (`app_database.dart:100-109`)

### Error Recovery
**Why good:** Migration errors, sync failures, and database issues all have recovery paths.

**Evidence:** `migration_error_provider`, `database_recovery_screen.dart`, sync fallback to cache

### GoRouter Navigation
**Why good:** Declarative routing with proper guards and redirects.

**Evidence:** Admin route guard (`main.dart:151-159`), subscription guard (`main.dart:280-301`)

---

## 3. Biggest Weaknesses

### Critical

| Problem | Why it matters | Risk | Effort |
|---------|---------------|------|--------|
| No FLAG_SECURE for medical content | Screenshots can capture sensitive educational material | Medium | 5m |
| Session restoration disabled | Users must re-login, reduced retention | Medium | 15m |

### High

| Problem | Why it matters | Risk | Effort |
|---------|---------------|------|--------|
| FTS5 full rebuild on sync | O(n) with article count, degrades with scale | High | 1 day |
| N+1 queries for category progress | Sequential queries for each category | High | 1 day |
| N+1 queries for exam questions | 17 sequential queries for exam start | High | 1 day |
| Android 13+ notification permission incomplete | Notifications may silently fail | Medium | 2h |

### Medium

| Problem | Why it matters | Risk | Effort |
|---------|---------------|------|--------|
| Orphaned `QuizQuestions` table | Storage waste, schema confusion | Low | 30m |
| Duplicate search screens | Maintenance burden | Low | 1h |
| Unused packages (`fsrs`, `google_fonts`) | Larger APK | Low | 10m |
| Pagination providers missing autoDispose | Stale state on navigation | Medium | 1h |

### Low

| Problem | Why it matters | Risk | Effort |
|---------|---------------|------|--------|
| Shimmer duplication | Code bloat | Low | 4h |
| Validation duplication | Technical debt | Low | 2h |
| `showDiskFullBanner` unused | Dead code | Low | 5m |
| `ArticleContent` class unused | Dead code | Low | 5m |

---

## 4. Confirmed Technical Debt

| Debt Type | Location | Evidence |
|-----------|----------|----------|
| Duplicate code | `search_screen.dart` vs `article_search_screen.dart` | Both implement full search UI |
| Dead code | `lib/features/quiz/data/quiz_sync_service.dart:1` | Single-line re-export |
| Dead code | `lib/features/articles/models/article_model.dart` | `ArticleContent` never imported |
| Dead code | `lib/core/widgets/error_banners.dart:3-6` | `showDiskFullBanner` never called |
| Unused dependencies | `pubspec.yaml:18,20` | `fsrs`, `google_fonts` declared |
| Orphaned schema | `app_database.dart:50-63,92` | `QuizQuestions` table unused |
| Migration artifact | `app_database.dart:75-89` | Old table dropped in v4 |
| Lifecycle issue | `quiz_notifier.dart:17-19` | Services in build() not constructor |
| State duplication | `article_providers.dart:3` | `articlesProvider` duplicates `allArticlesProvider` |

---

## 5. Architecture Health

| Area | Assessment |
|------|------------|
| Feature boundaries | **Good** — Clear separation by feature folder |
| Dependency direction | **Good** — UI → Providers → Repositories → Database |
| Repository separation | **Good** — One per domain, consistent patterns |
| Provider layering | **Good** — StateNotifierProvider, AsyncNotifierProvider, Family variants |
| Database ownership | **Good** — Single `AppDatabase` singleton |
| Navigation architecture | **Excellent** — GoRouter with route guards |
| Offline architecture | **Excellent** — All data flows offline-first |
| Sync architecture | **Good** — Callback-based event notification |
| Future scalability | **Needs work** — N+1 queries will degrade |

---

## 6. Design Pattern Review

### Repository Pattern
**Applied well:** `ArticleRepository`, `QuizRepository`, `SubscriptionRepository`, `AdminRepository` all follow the same callback-based error notification pattern.

**Breaks down:** Callback pattern couples repositories to UI state providers tightly.

### Riverpod
**Applied well:** Consistent use of `AsyncNotifierProvider`, `FutureProvider.family`, `StreamProvider`. AutoDispose used appropriately in search.

**Breaks down:** Pagination providers missed `autoDispose`, state clobber in `QuizNotifier` finally block.

### Notifier Architecture
**Applied well:** `StreakNotifier`, `ProgressNotifier`, `ArticleSearchController` properly structured.

**Breaks down:** `QuizNotifier` services initialized in `build()` instead of constructor.

### Database/Drift
**Applied well:** Transactions for writes, migrations with error handling, proper singleton management.

**Breaks down:** Raw SQL mixed with ORM, FTS5 rebuilds entire table.

---

## 7. Performance Review

| Area | Score | Evidence |
|------|-------|----------|
| Database queries | 65 | N+1 patterns for category progress |
| Search/FTS | 60 | Full rebuild on mismatch |
| Pagination | 80 | ListView.builder with offset |
| Riverpod rebuilds | 75 | RepaintBoundary for heatmap |
| Memory usage | 75 | Controllers disposed, streams watched |
| Notification scheduling | 70 | Singleton pattern wasteful |
| SM-2 calculations | 80 | Pure functions, no I/O in hot path |
| Startup | 70 | Two async ops before runApp |
| Image loading | 85 | cached_network_image with placeholders |

---

## 8. Security Review

| Area | Score | Evidence |
|------|-------|----------|
| Supabase | 80 | RLS fallback to cache |
| Token storage | 85 | FlutterSecureStorage used |
| Permissions | 65 | Missing FLAG_SECURE, incomplete Android 13 flow |
| Backup/privacy | 75 | No cloud backup, local only |
| Play Store readiness | 70 | Needs FLAG_SECURE for medical content |

---

## 9. UX Engineering Review

| Area | Score | Evidence |
|------|-------|----------|
| Theme | 70 | Consistent but hardcoded colors persist |
| Loading states | 85 | Shimmer everywhere, good placeholders |
| Offline UX | 90 | Banner, cached content shown |
| Errors | 75 | Clear messages, retry options |
| Navigation | 80 | Intuitive tab layout, back handling |
| Search | 75 | FTS5 but rebuild performance concern |
| Quiz | 85 | Smooth SM-2 flow, good feedback |
| Progress | 80 | Heatmap, stats, clear visualization |
| Settings | 75 | Standard options, clear actions |
| Accessibility | 60 | No explicit a11y labels/features |

---

## 10. Release Readiness

### Must Fix Before Release
- Add FLAG_SECURE to AndroidManifest.xml
- Call `AuthService.initialize()` in main()

### Should Fix Before Release
- Remove unused packages (`fsrs`, `google_fonts`)
- Delete duplicate search screen
- Delete redundant quiz_sync_service re-export
- Remove orphaned `QuizQuestions` table

### Can Wait Until v1.1
- FTS5 incremental indexing
- Category progress query batching
- Exam question selection optimization
- Admin user pagination

### Future Improvements
- Background isolate for heavy operations
- Certificate pinning for Supabase
- Biometric authentication option

---

## 11. Decision Validation

| Decision | Status | Reason |
|----------|--------|--------|
| Offline-first | **KEEP** | Core differentiator, implemented well |
| Drift ORM | **KEEP** | Works for current scale, needs optimization |
| Supabase | **KEEP** | Provides required backend services |
| SM-2 Spaced Repetition | **KEEP** | Feature-complete and well-tested |
| FTS5 Search | **MODIFY** | Needs incremental indexing strategy |
| GoRouter | **KEEP** | Handles all routing needs |
| Riverpod | **KEEP** | Consistent patterns, good architecture |

---

## 12. Engineering Risk Register

| Issue | Severity | Likelihood | Impact | Priority | Action |
|-------|----------|------------|--------|----------|--------|
| No FLAG_SECURE | Medium | High | Medium | HIGH | Add to AndroidManifest |
| Session restoration | Medium | High | Medium | HIGH | Call initialize() |
| FTS5 full rebuild | High | High | High | HIGH | Incremental strategy |
| Category progress N+1 | High | Medium | High | HIGH | Batch queries |
| Exam N+1 queries | High | Medium | High | HIGH | Rewrite exam start |
| Duplicate search | Low | High | Low | MEDIUM | Delete one |
| Unused packages | Low | High | Low | LOW | Remove from pubspec |
| Pagination autoDispose | Medium | Medium | Medium | MEDIUM | Add autoDispose |
| Admin user list | Medium | Low | High | MEDIUM | Add pagination |

---

## 13. Roadmap

### Immediate (0-30 days)
- Security hardening (FLAG_SECURE, initialize())
- Technical debt cleanup
- Performance monitoring setup

### Next Sprint (30-60 days)
- FTS5 indexing optimization
- Category progress batching
- Exam question selection fix

### v1.1 (60-90 days)
- Admin pagination
- Background isolate research
- Accessibility improvements

### Long-term (90+ days)
- Scale testing at 100K users
- Certificate pinning
- Offline sync improvements

---

## 14. Final Verdict

### If I inherited this project...

**Keep:**
- Offline-first architecture
- Riverpod state management
- Drift database design
- GoRouter navigation
- SM-2 implementation

**Refactor first:**
- FTS5 indexing (critical for performance)
- N+1 query patterns (critical for scale)
- Remove duplicate code (cleanup priority)

**Never touch:**
- Core sync architecture (it works)
- Quiz state machine (well-tested)
- Error recovery patterns (resilient)

**Surprised by:**
- 3 years of solid evolution without major rewrites
- Consistent patterns across features
- Excellent offline fallback everywhere

**High maturity:**
- Repository pattern consistency
- Provider composition
- Migration strategy
- Lifecycle safety

**Scalability limits:**
- N+1 queries degrade linearly
- FTS5 rebuild O(n) time
- Admin list unpaginated

---

## If I had only one week before release...

**Priority 1 (Day 1-2):** Add FLAG_SECURE to AndroidManifest.xml, call `AuthService.initialize()` in main(), remove unused packages.

**Priority 2 (Day 3-4):** Delete duplicate search screen and quiz_sync_service re-export, remove orphaned `QuizQuestions` table.

**Priority 3 (Day 5-7):** Add database indexes for `next_due_at` and `article_id`, cache heatmap grid in progress screen, monitor performance metrics.

The app is functionally complete. These changes will harden it for production without changing core architecture.