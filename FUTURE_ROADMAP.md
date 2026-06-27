# WardReady — Future Roadmap

## Version 2 Priorities

### 1. Complete Exam Mode (EHPLE)
- Add `/exam` route in GoRouter
- Build `ExamScreen` UI (3-hour timed test)
- Build `ExamResultsScreen`
- Fix N+1 query performance in `exam_session_notifier.dart`
- Add exam history to database

### 2. Fix Critical Gaps
- Android 13+ notification permission flow
- Session restore initialization call
- Supabase key validation assertion
- FLAG_SECURE in AndroidManifest

### 3. Scale Improvements
- Admin pagination for user list
- Single-query exam question selection
- Background isolate for FTS5 rebuilds
- Index on `quiz_table.next_due_at`

## Architecture Improvements

### State Management
- Extract Quiz service orchestrator (decouple from 3 services)
- Consolidate category progress into single provider
- Add central auth provider to avoid duplication

### Data Layer
- Move `study_sessions`, `view_history` to Drift-managed tables
- Use Drift companion objects for all queries instead of raw SQL
- Add migration testing utilities

### Navigation
- Add proper loading state for async redirects
- Add deep-link intent filters for article sharing
- Consider auto-route for exam mode

## Scalability Improvements

| Component | Current Limit | Target | Solution |
|-----------|---------------|--------|----------|
| User list | ~10k before OOM | 100k+ | Cursor-based pagination |
| Article sync | Full replace | Diff-based | Sync only changed records |
| Quiz questions | 200 in memory | Paging | Stream questions during exam |
| FTS5 index | Block on rebuild | Background | Isolate or defer rebuild |
| Session check | Every 30min | Smart refresh | Check on foreground only |

## Testing Roadmap

### Phase 1 (Immediate)
- Widget tests for all screens
- Integration tests for auth flow
- SM-2 algorithm unit tests (done)

### Phase 2 (Pre-v2)
- Offline scenario tests
- Large dataset performance tests
- Notification permission flow tests
- Accessibility tests (TalkBack)

### Phase 3 (Ongoing)
- Golden tests for all screen states
- Migration path tests
- Crash reporting integration tests

## Security Roadmap

| Priority | Item | Status |
|----------|------|--------|
| HIGH | FLAG_SECURE for medical content | Missing |
| HIGH | Keys validation in release mode | Missing |
| MEDIUM | Database encryption (SQLCipher) | Not implemented |
| LOW | Biometric auth for sensitive actions | Future |
| LOW | Certificate pinning for Supabase | Future |

## Performance Roadmap

| Metric | Target | Solution |
|--------|--------|----------|
| Cold start | <2s | Lazy load, reduce providers |
| Exam start | <1s | Single query or caching |
| Search | <300ms | FTS5 with proper indexes |
| Memory | <100MB idle | Dispose unused providers |

## Documentation Roadmap

- [x] SYSTEM_OVERVIEW.md
- [x] FEATURE_GUIDE.md
- [x] DATA_FLOW.md
- [x] EVENT_FLOW.md
- [x] STATE_MACHINE.md
- [x] DATABASE_REFERENCE.md
- [x] PROVIDER_REFERENCE.md
- [x] ROUTING_REFERENCE.md
- [x] MAINTAINER_GUIDE.md

Remaining:
- [ ] API endpoints reference (Supabase)
- [ ] Deployment guide (Fastlane, GitHub Actions)
- [ ] Monitoring guide (when Sentry added)