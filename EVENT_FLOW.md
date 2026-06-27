# WardReady — Event Flow Reference

## App Launch

```
main() (lib/main.dart)
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
SharedPreferences initialization (lines 37-39)
  ↓
_read themeMode from prefs
  ↓
FlutterError.onError handler (lines 41-44)
  ↓
PlatformDispatcher.onError handler (lines 46-50)
  ↓
Supabase.initialize() (lines 81-91)
  ↓
ProviderScope created with theme override (lines 94-97)
  ↓
MyApp builds → MaterialApp.router
  ↓
InitialFlowGate checks onboarding/disclaimer flags
  ↓
Route: / → InitialFlowGate → Onboarding or Disclaimer or MainShell
```

## App Resume (from background)

```
MainActivity resume (Android)
  ↓
Flutter engine reactivates
  ↓
Widgets rebuild
  ↓
MainShell initState re-checks subscription (line 39)
  ↓
SessionTimeoutNotifier.resetTimer() called (line 34)
  ↓
All StreamProviders reconnect to database
  ↓
connectivityProvider auto-restarts timer (line 33)
```

## App Background (navigator away)

```
User leaves app → MainActivity pause
  ↓
SessionTimeoutNotifier timer continues counting
  ↓
After 30 minutes idle → timer fires
  ↓
Supabase.auth.signOut() called (line 23)
  ↓
State set to true (line 24)
  ↓
MainShell listener triggers → context.go('/login')
```

## Connectivity Change

```
_connectivityTimer tick (every 30s, lib/core/providers/connectivity_notifier.dart:34)
  ↓
InternetAddress.lookup('example.com')
  ↓
Success → state = true (online)
  ↓
Failure → state = false (offline)
  ↓
UI reacts: OfflineBanner shown when !isOnline (main_shell.dart:119)
```

## Manual Sync

```
CategoriesScreen FAB tap (line 164)
  ↓
SnackBar "Syncing..." shown
  ↓
articleRepositoryProvider.syncInBackground()
  ↓
Repository callbacks invalidate all categoryProgressProvider values (lines 175-182)
  ↓
Providers rebuild → UI updates progress bars
```

## Logout

```
SettingsScreen logout button tap (line 210)
  ↓
authServiceProvider.signOut()
  ↓
Supabase.auth.signOut() (line 233)
  ↓
clearStoredTokens() → SecureStorage delete (lines 258-261)
  ↓
context.go('/login')
  ↓
SubscriptionGuard sees session null → shows PaywallScreen
```

## Notification Click

```
Device receives notification (ID 4201)
  ↓
_onDidReceiveNotificationResponse callback (line 103)
  ↓
_handleNotificationResponse(response)
  ↓
If response.payload == 'sm2_due_cards_daily'
  ↓
Refresh due count → rescheduleDueReminders()
```

## Database Migration

```
AppDatabase created (LazyDatabase, line 432)
  ↓
MigrationStrategy.onUpgrade fired when schemaVersion changes
  ↓
Run migration steps 2-9 (lines 117-161)
  ↓
Each step wrapped in try/catch → setMigrationError on failure
  ↓
MigrationErrorStore.value set → UI banner in SettingsScreen (line 32)
```

## Theme Change

```
SettingsScreen theme toggle (line 85)
  ↓
saveThemeMode(newMode) → SharedPreferences.setInt
  ↓
themeModeProvider.notifier.state = newMode (line 93)
  ↓
MyApp rebuild triggered
  ↓
MaterialApp.themeMode updated
```

## Article View

```
ArticleListScreen onTap
  ↓
context.push('/article-detail', extra: article)
  ↓
ArticleDetailScreen initState (line 50)
  ↓
streakNotifier.recordArticleRead() (line 72)
  ↓
db.recordArticleView() → INSERT study_sessions
  ↓
_recordViewHistory() → INSERT view_history
  ↓
categoryProgressProvider invalidated (line 80)
```

## Quiz Complete

```
User answers last question (quiz_screen.dart:328)
  ↓
_checkLastQuestion true → _resetQuizAndPop (line 329)
  ↓
notifier.saveCurrentStateToDrift() → recordReview (line 338)
  ↓
notifier.reset() clears state (line 343)
  ↓
context.canPop() ? pop() : go('/home') (lines 344-347)
```

## Subscription Expiry

```
_subscriptionTimer tick (every 30min, main_shell.dart:37)
  ↓
isSubscribedProvider.future check (line 39)
  ↓
If false → MaterialBanner shown (lines 42-67)
  ↓
User taps "RENEW" → context.go('/subscription')
  ↓
User taps "LATER" → banner dismissed
```

## Exam Mode Start

```
ExamScreen would call ExamSessionNotifier.startExam()
  ↓
_selectWeighted200Questions(domainWeights) (line 214)
  ↓
For each domain (14 domains) → _domainCount() query
  ↓
For each domain → SELECT * FROM quiz_table WHERE category = ? LIMIT ?
  ↓
Fill remainder queries (lines 169-202)
  ↓
shuffle → return up to 200 questions
  ↓
State: questions populated, isActive=true, timeRemaining=3h