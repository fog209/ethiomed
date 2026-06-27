# WardReady — Data Flow Reference

## User Login Flow

```
LoginScreen.textFields → AuthController.signIn()
      ↓
AuthService.signIn(email, password)
      ↓
Supabase.auth.signInWithPassword()
      ↓
Supabase returns Session
      ↓
AuthService._persistSession(session)
      ↓
FlutterSecureStorage.write(access_token, refresh_token)
      ↓
AuthUiState.success → LoginScreen navigates
      ↓
AppEntrance StreamBuilder detects session
      ↓
SubscriptionGuard subscribes to isSubscribedProvider
      ↓
SubscriptionRepository.checkSubscriptionStatus()
      ↓
Supabase.from('profiles').select('is_admin')
      ↓
Supabase.from('subscriptions').select('status, expiry_date')
      ↓
Auth true + subscribed → MainShell
```

## Article Sync Flow

```
CategoriesScreen.initState or FAB tap
      ↓
ArticleRepository.fetchAndSyncArticles()
      ↓
Supabase.from('articles').select('*, is_high_yield')
      ↓
model.Article.fromJson() for each row
      ↓
Drift transaction: articles.insertOnConflictUpdate(ArticlesCompanion)
      ↓
_onSuccessfulSync() callback → syncStateProvider.setSuccessfulSync()
      ↓
allArticlesProvider stream updates → UI rebuilds
```

**Failure Path:**
```
Supabase error (403/401/429/503/504/SocketException)
      ↓
Callback (_onServerUnreachable, etc.)
      ↓
Return _db.select(_db.articles).get() — cached data
      ↓
UI shows cached articles + offline banner
```

## Search Flow

```
ArticleSearchScreen.textField → ArticleSearchController.updateQuery()
      ↓
_debounceTimer (300ms) → _runSearch(query, category)
      ↓
ArticleSearchRepository.searchArticles()
      ↓
_ensureSearchIndex() → CREATE VIRTUAL TABLE IF NOT EXISTS
      ↓
If count mismatch → _rebuildSearchIndex()
      ↓
FTS5 query: SELECT via article_search_fts JOIN articles
      ↓
Rows mapped to ArticleLocal → return limited results
      ↓
ArticleSearchState results updated → UI rebuilds
```

**Corruption Recovery:**
```
SqliteException with 'fts5' or 'malformed' in message
      ↓
_rebuildSearchIndex() → INSERT ... VALUES('rebuild')
      ↓
Retry search query
```

## Quiz Flow

```
QuizScreen builds → quizNotifierProvider(category).future
      ↓
QuizNotifier.build(category)
      ↓
SpacedRepetitionService.getDueCards(category)
      ↓
Drift customSelect on quiz_table (next_due_at IS NULL or <= now)
      ↓
QuizRepository.getLocalQuestions(category) for new cards
      ↓
Merge due + new → questions list
      ↓
QuizScreen renders first question
```

**Answer Flow:**
```
User taps option → QuizNotifier.selectOption(option)
      ↓
_showExplanation = true, _selectedOption set
      ↓
UI reveals explanation + SM-2 buttons
      ↓
User taps "Again/Hard/Good/Easy" → QuizNotifier.recordReview(id, quality)
      ↓
SpacedRepetitionService._calculateSchedule() (SM-2 algorithm)
      ↓
Drift customSelect UPDATE quiz_table (ease_factor, sr_interval, next_due_at)
      ↓
NotificationService.scheduleDueReminder() for next due date
```

## Progress Flow

```
MainShell shows → StreakNotifier.build()
      ↓
_countCurrentStudyStreak() → study_sessions query
      ↓
_countTotalArticlesViewed() → COALESCE SUM query
      ↓
_loadAccuracy() → quiz_table SUM queries
```

**Article Read Recording:**
```
ArticleDetailScreen initState → streakNotifier.recordArticleRead()
      ↓
AppDatabase.recordArticleView() → INSERT ... ON CONFLICT study_sessions
      ↓
StreakNotifier._loadStats() re-run
```

**Quiz Result Recording:**
```
QuizScreen._recordReviewAndAdvance → notifier.recordReview() + streakNotifier.recordQuizResult()
      ↓
StreakNotifier.recordQuizResult(correct) → INSERT quiz_correct increment
      ↓
ProgressNotifier rebuilds
```

## Bookmark Flow

```
ArticleDetailScreen bookmark icon tap
      ↓
if (isBookmarked) DELETE FROM bookmarks WHERE article_id = ?
      ↓
else INSERT INTO bookmarks (articleId: ...)
      ↓
Bookmarked icon updates (StreamBuilder watching)
```

**Bookmarks List:**
```
BookmarksScreen → StreamBuilder on bookmarks table
      ↓
Drift select → List<Bookmark>
      ↓
For each bookmark → article lookup by ID
      ↓
ListView.builder renders saved articles
```

## Notification Flow

```
App start → MainShell initState → NotificationService not yet initialized
      ↓
Daily study reminder toggle ON → NotificationReminderNotifier.setEnabled(true)
      ↓
NotificationService.setDailyRemindersEnabled(true)
      ↓
rescheduleDueReminders() → _nextDueAt() query
      ↓
_scheduleDailyReminder() → zonedSchedule at 8:00 AM
      ↓
Device receives notification → _handleNotificationResponse
      ↓
Check due count → reschedule if changed
```

## Onboarding Flow

```
App launch → main.dart _seenOnboarding flag check
      ↓
if (false) → OnboardingScreen displayed
      ↓
Skip/Get Started → SharedPreferences.setBool('hasSeenOnboarding', true)
      ↓
Navigate to disclaimer or home
```

## Disclaimer Flow

```
_initialFlowGateState → DisclaimerGate widget
      ↓
SharedPreferences check 'hasSeenDisclaimer'
      ↓
if (false) → DisclaimerScreen shown
      ↓
"I Understand" button → setBool('hasSeenDisclaimer', true)
      ↓
Navigate to /home (which shows SubscriptionGuard)
```

## Theme Flow

```
SettingsScreen theme toggle → saveThemeMode(mode)
      ↓
SharedPreferences.setInt('themeMode', mode.index)
      ↓
themeModeProvider.state = newMode
      ↓
MyApp rebuilds with ThemeMode.dark/light
```