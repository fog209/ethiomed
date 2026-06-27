# WardReady — State Machine Reference

## Application States

### 1. Startup State

**Entry Point:** `main()` called

**State Properties:**
- Supabase uninitialized
- Theme not yet loaded
- No session

**Transitions:**
- On SharedPreferences read → **OnboardingCheck** or **DisclaimerCheck** or **AuthCheck**

---

### 2. OnboardingCheck

**Triggered By:** `main.dart:_seenOnboarding == false`

**State Properties:**
- First launch or SharedPreferences cleared
- No user data considered

**Transitions:**
- Onboarding complete → **DisclaimerCheck**
- Skip pressed → **DisclaimerCheck**

---

### 3. DisclaimerCheck

**Triggered By:** `!_seenDisclaimer`

**State Properties:**
- User must acknowledge medical disclaimer
- Content access blocked

**Transitions:**
- Accept disclaimer → **AuthCheck**
- Navigate to home disabled

---

### 4. AuthCheck

**Triggered By:** `InitialFlowGate` with onboarding/disclaimer complete

**State Properties:**
- Supabase session may or may not exist
- `authSessionProvider` stream active

**Transitions:**
```
session == null → LoginState
session != null → SubscriptionCheck
```

---

### 5. LoginState

**Triggered By:** No valid session

**State Properties:**
- `AuthUiState.status == loading` during sign in
- `AuthUiState.hasError == true` on failure

**Transitions:**
- Sign in success → **SubscriptionCheck**
- Sign up → **LoginState** (requires email verification then sign in)

---

### 6. SubscriptionCheck

**Triggered By:** Valid session exists

**State Properties:**
- `isSubscribedProvider` FutureProvider resolving
- `SubscriptionGuard` deciding route

**Transitions:**
```
subscribed == true → MainState
subscribed == false → PaywallState
Supabase error → MainState (grace period) or PaywallState
```

---

### 7. PaywallState

**Triggered By:** User not subscribed

**State Properties:**
- Payment instructions shown
- Telebirr/Telegram links visible (paywall_screen.dart)

**Transitions:**
- Subscription activated → **MainState**
- No route away without payment

---

### 8. MainState

**Triggered By:** Authenticated + subscribed

**State Properties:**
- `MainShell` active with 6 tabs
- `bottomNavIndexProvider` tracks tab
- `sessionTimeoutProvider` active (30min timer)
- `connectivityProvider` polling every 30s

**Tab States:**
- Library (tab 0): Categories grid
- Search (tab 1): ArticleSearchScreen
- Saved (tab 2): BookmarksScreen
- Quiz (tab 3): QuizScreen
- Progress (tab 4): ProgressScreen
- Settings (tab 5): SettingsScreen

---

### 9. Offline State

**Triggered By:** `connectivityProvider == false`

**State Properties:**
- `OfflineBanner` visible
- `serverUnreachableProvider == true` on sync failure
- Cached data shown

**Transitions:**
- Network restored → **MainState** (sync resumes)
- `serverUnreachable == false` on next sync

---

### 10. Syncing State

**Triggered By:** Repository sync in progress

**State Properties:**
- `syncStateProvider` tracks: `serverUnreachable`, `rateLimited`, `syncIncomplete`, `diskFull`
- Shimmer placeholders visible

**Transitions:**
```
success → MainState (with updated data)
rate limited → MainState (shows last data)
disk full → MainState (error banner)
```

---

### 11. RateLimited State

**Triggered By:** HTTP 429 response

**State Properties:**
- `syncStateProvider.rateLimited == true`
- `_rateLimitTimer` counts 30s auto-clear

**Transitions:**
- 30s elapses → Clear after 60s from last check

---

### 12. MigrationError State

**Triggered By:** Database migration step fails

**State Properties:**
- `MigrationErrorStore.value` set
- UI banner in SettingsScreen

**Transitions:**
- Fresh install → Clears
- Manual reset → DatabaseRecoveryScreen

---

### 13. DatabaseRecovery State

**Triggered By:** Database corruption detected

**State Properties:**
- `DatabaseRecoveryScreen` shown
- `_isResetting` flag during cleanup

**Transitions:**
- Reset & Re-sync tapped → Delete DB files → exit(0)
- App restart → **Startup**

---

### 14. SessionExpired State

**Triggered By:** 401 response on protected endpoint OR 30-min idle timeout

**State Properties:**
- Refresh token invalid/expired
- `SupabaseSessionExpiredException` thrown

**Transitions:**
- Login screen → **LoginState**

---

### 15. Admin State

**Triggered By:** Navigating to `/admin`

**State Properties:**
- `currentAdminProfileProvider` FutureProvider resolving
- Redirect logic in GoRouter

**Transitions:**
```
isAdmin == true → AdminDashboardScreen
isAdmin == false → Redirect to /home
```

---

## State Transition Diagram

```
[Startup]
    ↓ hasSeenOnboarding?
[OnboardingCheck] → complete → [DisclaimerCheck]
    ↓ hasSeenDisclaimer?
[DisclaimerCheck] → accepted → [AuthCheck]
    ↓ session?
[AuthCheck] → no → [LoginState]
           → yes → [SubscriptionCheck]
    ↓ subscribed?
[SubscriptionCheck] → no → [PaywallState]
                  → yes → [MainState]

[MainState] ⇄ [OfflineState] (connectivity changes)
[MainState] ⇄ [SyncingState] (sync in progress)
[MainState] ⇄ [RateLimitedState] (429 response)
[MainState] → [DatabaseRecovery] (corruption detected)
[MainState] → [SessionExpired] (30min idle or 401)
[MainState] → [AdminState] (navigate to /admin)
    ↓ isAdmin?
[AdminState] → yes → [AdminDashboard]
             → no → [MainState]

[LoginState] → [PaywallState] (on sign up? depends on subscription)
```