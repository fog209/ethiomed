# WardReady — Routing Reference

## GoRouter Configuration

**File:** `lib/main.dart:99-162`

| Route | Guard | Arguments | Destination | Purpose |
|-------|-------|-----------|-------------|---------|
| `/` | InitialFlowGate | None | Onboarding/ Disclaimer/ MainShell | Entry point |
| `/login` | None | None | LoginScreen | Authentication |
| `/signup` | None | None | SignupScreen | Account creation |
| `/home` | SubscriptionGuard | None | MainShell | Main app |
| `/disclaimer` | None | None | DisclaimerScreen | Medical disclaimer |
| `/terms` | None | None | TermsScreen | Legal |
| `/privacy` | None | None | PrivacyScreen | Legal |
| `/article-list/:category` | None | path param `category` | ArticleListScreen | Paginated list |
| `/article-detail` | None | `extra: ArticleLocal` | ArticleDetailScreen | Detail view |
| `/admin` | Redirect (isAdmin) | None | AdminDashboardScreen | Admin panel |

## Navigation Paths

### InitialFlowGate Logic
```dart
// lib/main.dart:174-180
if (!_seenOnboarding) return OnboardingScreen();
if (!_seenDisclaimer) return DisclaimerScreen();
return MainShell(); // which checks subscription
```

### SubscriptionGuard Logic
```dart
// lib/main.dart:281-301
isSubscribed.when(
  data: (active) => active ? MainShell() : PaywallScreen(),
  loading: () => CircularProgressIndicator(),
  error: (err, _) => Text("Sync Error: $err"),
);
```

### Admin Redirect Logic
```dart
// lib/main.dart:152-159
redirect: (context, state) async {
  final isAdmin = await container.read(currentAdminProfileProvider.future);
  if (!isAdmin) return '/home';
  return null;
}
```

## Route Details

### /
- **Builder:** `InitialFlowGate` widget
- **Guards:** SharedPreferences flags
- **Transition:** Forward navigation only
- **Failure:** Invalid state → Default to onboarding

### /article-list/:category
- **Path Parameter:** `category` (URL encoded)
- **Builder:** `ArticleListScreen(category: ...)`
- **Navigation:** From CategoriesScreen grid tiles
- **Back:** `context.canPop() ? pop() : go('/home')` pattern used throughout

### /article-detail
- **Arguments:** `state.extra as ArticleLocal?` (nullable)
- **Builder:** 
  ```dart
  if (article is ArticleLocal) {
    return ArticleDetailScreen(article: article);
  }
  return ArticleDetailScreen(); // fallback
  ```
- **Failure:** Null article → Navigate to home with SnackBar (line 54-63)

### /admin
- **Redirect:** Async check for `isAdmin`
- **Failure Conditions:**
  - User null → redirect `/home`
  - Profile not found → redirect `/home`
  - `is_admin != true` → redirect `/home`
- **Race Condition:** Redirect awaits FutureProvider without timeout/loading state

### Navigation Methods
- `context.go('/home')` — Replace stack
- `context.push('/route')` — Add to stack
- `context.pop()` — Back
- `context.canPop() ? pop() : go('/home')` — Safe back pattern

## Missing Routes

| Feature | Required Route | Status |
|---------|---------------|--------|
| Exam Mode | `/exam` | NOT DEFINED |
| Exam Results | `/exam-results` | NOT DEFINED |
| Paywall | `/subscription` | Referenced in MainShell but no route |

## Deep Links

**Status:** None configured
**File:** `android/app/src/main/AndroidManifest.xml` has no `<intent-filter>` for deep linking

## Navigation Best Practices (in codebase)

1. **Back Buttons:** All use `context.canPop() ? context.pop() : context.go('/home')` pattern
2. **Close Buttons:** CloseButton in AppBar calls reset-and-pop logic
3. **Tab Navigation:** IndexedStack with explicit index list (main_shell.dart:94-102)
4. **Scroll Reset:** Bottom nav tap resets index (main_shell.dart:125-127)