# WardReady — Repository Reference

## ArticleRepository

**File:** `lib/features/articles/data/article_repository.dart`

**Purpose:** Article CRUD, sync, and search operations

**Dependencies:**
- `SupabaseClient` (remote data)
- `AppDatabase` (local cache)
- Callbacks: `onServerUnreachable`, `onRateLimited`, `onSyncIncomplete`, `onDiskFull`, `onSuccessfulSync`

**Public Methods:**

| Method | Description | Error Handling |
|--------|-------------|--------------|
| `fetchAndSyncArticles()` | Sync all remote articles to local DB | 403/401/429/503/504 return cached |
| `syncInBackground()` | Alias for fetchAndSyncArticles | Same as above |
| `watchLocalArticles()` | Stream articles with filters | DB errors propagate |
| `watchArticlesPaged()` | Stream paginated articles | DB errors propagate |
| `countArticlesInCategory()` | Count total articles per category | Returns 0 on error |
| `fetchArticlesPage()` | Paginated fetch | Throws on error |

**Side Effects:**
- Calls sync state provider callbacks on network errors
- Updates all category progress providers after sync

---

## QuizRepository

**File:** `lib/features/quiz/quiz_repository.dart`

**Purpose:** Quiz question fetch, upsert, and local queries

**Dependencies:**
- `SupabaseClient`
- `AppDatabase`
- Callbacks: `onServerUnreachable`, `onRateLimited`, `onDiskFull`, `onSuccessfulSync`

**Public Methods:**

| Method | Description | Error Handling |
|--------|-------------|--------------|
| `fetchQuestions(String category)` | Fetch remote questions | 403 returns local questions |
| `upsertQuestions(List<QuizQuestionEntity>)` | Save to local DB | DiskFullException on full disk |
| `getLocalQuestions(String category)` | Query local quiz questions | Returns empty list on error |
| `_companionFromEntity()` (private) | Drift companion object | - |
| `_questionFromJson()` (private) | Parse Supabase response | Returns null on malformed |

**Caching Strategy:**
- All fetched questions stored in `quiz_table`
- On fetch failure, return local cache
- Uses `onConflict: DoUpdate` for upsert

---

## AdminRepository

**File:** `lib/features/admin/data/admin_repository.dart`

**Purpose:** Admin-only user and subscription operations

**Dependencies:**
- `SupabaseClient` only

**Public Methods:**

| Method | Description | Error Handling |
|--------|-------------|--------------|
| `fetchAllUsers()` | Fetch all profiles with subscriptions | Throws on error |
| `activateUser(String userId)` | Create/update subscription | Throws on error |

**Side Effects:**
- None (read-only for users list)

**Scaling Issue:**
- No pagination — returns ALL users
- Will OOM at ~10k users

---

## SubscriptionRepository

**File:** `lib/features/subscription/data/subscription_repository.dart`

**Purpose:** Subscription status verification

**Dependencies:**
- `SupabaseClient`
- `FlutterSecureStorage` (grace period)

**Public Methods:**

| Method | Description | Error Handling |
|--------|-------------|--------------|
| `checkSubscriptionStatus()` | Check active/paid status | Returns true on admin or grace period |
| `recordSuccessfulCheck()` | Timestamp for grace period | Silent on error |
| `_hasGracePeriod()` | 30-day offline grace | Returns false on parse fail |

**Caching Strategy:**
- Grace period allows 30 days offline access
- Stores `last_sub_check_timestamp` in secure storage

**Admin Override:**
- Line 29-31: Admin users skip subscription check

---

## SpacedRepetitionService (Not a Repository Pattern)

**File:** `lib/features/quiz/spaced_repetition_service.dart`

**Purpose:** SM-2 algorithm implementation

**Dependencies:**
- `AppDatabase`
- `NotificationService`

**Public Methods:**

| Method | Description |
|--------|-------------|
| `getDueCards(String category)` | Cards due for review |
| `recordReview(int id, int quality)` | SM-2 update and notification |
| `_calculateSchedule()` | SM-2 algorithm (locked) |

**Note:** Uses raw SQL for DB operations despite Drift availability

---

## WeaknessService (Not a Repository Pattern)

**File:** `lib/features/quiz/weakness_service.dart`

**Purpose:** Identify weak study areas

**Dependencies:** `AppDatabase`

**Public Methods:**

| Method | Description |
|--------|-------------|
| `getWeakFields(String articleId)` | Fields where last_quality < 3 |

**Side Effects:**
- Ensures `last_quality` column exists (migration check)

---

## ArticleSearchRepository (Not a Repository Pattern)

**File:** `lib/features/articles/data/article_search_provider.dart`

**Purpose:** Full-text search

**Dependencies:** `AppDatabase`

**Public Methods:**

| Method | Description |
|--------|-------------|
| `searchArticles(query, category)` | FTS5 search with fallback |
| `_ensureSearchIndex()` | Create/rebuild FTS5 index |
| `_rebuildSearchIndex()` | Reindex all articles |

**Failure Recovery:**
- Detects FTS5 corruption via SqliteException message
- Falls back to full table scan
- Rebuilds index automatically

---

## NotificationService (Not a Repository Pattern)

**File:** `lib/core/services/notification_service.dart`

**Purpose:** Local notification scheduling

**Dependencies:** `AppDatabase`, `FlutterLocalNotificationsPlugin`

**Public Methods:**

| Method | Description |
|--------|-------------|
| `initialize()` | Plugin setup, permission request |
| `scheduleDueReminder(DateTime, int)` | Set daily reminder |
| `rescheduleDueReminders()` | Refresh all reminders |
| `setDailyRemindersEnabled(bool)` | Toggle + reschedule |
| `cancelDueReminders()` | Cancel scheduled |
| `cancelAllScheduledNotifications()` | Cancel all |

**Note:** Uses raw SQL queries for counting due cards

---

## Common Patterns

### Callback Registration
```dart
// Repository receives VoidCallback on network/disk events
// These callbacks update sync state providers
onRateLimited: () => ref.read(syncStateProvider.notifier).setRateLimited()
```

### Supabase Error Handling
```dart
try {
  await supabase.from('table').select();
} on PostgrestException catch (e) {
  final status = postgrestStatus(e); // lib/core/services/postgrest_status_helper.dart
  if (status == 403) return getLocal(); // Permission denied, use cache
  if (status == 401) throw SupabaseSessionExpiredException();
  rethrow;
}
```

### Secure Storage Pattern
```dart
// For tokens (AuthService) and subscription grace period
final storage = FlutterSecureStorage();
await storage.write(key: 'key', value: 'value');
final value = await storage.read(key: 'key');
```