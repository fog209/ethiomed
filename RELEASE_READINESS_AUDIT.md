# RELEASE_READINESS_AUDIT.md

## WardReady - Play Store Release Readiness Verification

**Audit Date:** June 28, 2026  
**Project:** WardReady (Offline-first Flutter Medical Education App)  
**Platform:** Android APK  
**Application ID:** com.wardready.app

---

## AndroidManifest.xml

### Verified: Permission Declarations

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/src/main/AndroidManifest.xml:2-3` |
| **INTERNET:** Declared ✓ |
| **POST_NOTIFICATIONS:** Declared ✓ |
| **Status:** Both permissions properly declared |

### Verified: Backup Settings

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/src/main/AndroidManifest.xml:8` |
| **allowBackup:** `false` ✓ |
| **Status:** Secure - no backup |

### Verified: FLAG_SECURE

| Attribute | Value |
|-----------|-------|
| **Evidence:** No FLAG_SECURE attribute in AndroidManifest.xml or MainActivity |
| **Risk:** Screen recording/screenshots allowed |
| **Severity:** HIGH |
| **Fix:** Add `android:flags="FLAG_SECURE"` to `<activity>` element |
| **Release Blocking?:** YES |

### Verified: Exported Attribute

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/src/main/AndroidManifest.xml:11` |
| **exported:** `true` ✓ |
| **Status:** Required for LAUNCHER intent-filter |

---

## build.gradle(.kts) Configuration

### Verified: Compile SDK

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:18` |
| **compileSdk:** 36 |
| **Status:** ✓ Current (latest stable) |

### Verified: Target SDK

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:30` |
| **targetSdk:** 35 |
| **Status:** ✓ Current (Android 15) |

### Verified: Min SDK

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:29` |
| **minSdk:** `flutter.minSdkVersion` (UNVERIFIED - uses Flutter default) |
| **Status:** ⚠ Not explicit |
| **Fix:** Specify explicit minSdk (21 recommended for security) |
| **Release Blocking?:** NO |

### Verified: Version Code/Name

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:31-32` |
| **versionCode:** 1 |
| **versionName:** "1.0.0" |
| **Status:** ✓ Appropriate for first release |

### Verified: Signing Configuration

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:35-42` |
| **Release signing:** Requires `key.properties` file |
| **Risk:** Build fails without keystore configuration |
| **Severity:** HIGH |
| **Fix:** Provide key.properties template or debug fallback |
| **Release Blocking?:** YES |

### Verified: Proguard/R8

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:47-48` |
| **isMinifyEnabled:** `true` ✓ |
| **isShrinkResources:** `true` ✓ |
| **proguardFiles:** Default + `proguard-rules.pro` ✓ |

### Verified: Proguard Rules

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/proguard-rules.pro:1-5` |
| **Drift preservation:** `-keep class drift.**` ✓ |
| **AndroidX SQLite:** `-keep class androidx.sqlite.**` ✓ |
| **Status:** ✓ Sufficient for Drift ORM |

---

## pubspec.yaml Configuration

### Verified: Package Metadata

| Attribute | Value |
|-----------|-------|
| **Evidence:** `pubspec.yaml:1-2` |
| **name:** ethiomed |
| **description:** Present ✓ |
| **Version:** 1.0.0+1 ✓ |

### Verified: Flutter SDK Constraint

| Attribute | Value |
|-----------|-------|
| **Evidence:** `pubspec.yaml:7` |
| **sdk:** ^3.11.0 |
| **Status:** ✓ Modern SDK |

### Verified: Unused Dependencies

| Attribute | Value |
|-----------|-------|
| **Evidence:** `pubspec.yaml:18` |
| **fsrs:** ^2.0.0 declared but UNVERIFIED - no imports found in lib/ |
| **google_fonts:** ^6.2.1 declared but UNVERIFIED - no imports found in lib/ |
| **Severity:** MEDIUM |
| **Fix:** Remove unused dependencies |
| **Release Blocking?:** NO |

---

## Android 13+ Notification Permissions

### Verified: Runtime Permission Request

| Attribute | Value |
|-----------|-------|
| **Evidence:** `lib/core/services/notification_service.dart:111-116` |
| **Request method:** `androidPlugin?.requestNotificationsPermission()` |
| **Caller:** NotificationService.initialize() |
| **Usage:** Called before schedule, but no explicit UI flow |
| **Risk:** User may never grant permission |
| **Severity:** HIGH |
| **Fix:** Add permission rationale dialog before requesting |
| **Release Blocking?:** YES |

### Verified: Notification Channel

| Attribute | Value |
|-----------|-------|
| **Evidence:** `lib/core/services/notification_service.dart:70-84` |
| **Channel:** Defined with high priority ✓ |
| **ID:** `sm2_due_cards` |
| **Status:** ✓ Proper configuration |

---

## Play App Signing Readiness

### Verified: Signing Configuration Structure

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:35-42` |
| **Status:** Uses external keystore file - compatible with Play App Signing |
| **Fix Required:** Generate upload keystore, configure Play Console |
| **Release Blocking?:** NO (configuration works) |

---

## Data Safety Implications

### Verified: Data Collected

| Data Type | Location | Purpose |
|-----------|----------|--------|
| Study statistics | SQLite (local) | Calculate streak/quiz accuracy |
| Search history | SharedPreferences | Show recent searches (10 items) |
| Bookmark preferences | SQLite (local) | Save articles for later |
| Auth tokens | FlutterSecureStorage | Authentication session |

### Verified: Network Data

| Destination | Data Sent |
|-----------|---------|
| Supabase REST API | Email, password, session tokens |

### Verified: Encryption

| Storage | Protection |
|---------|------------|
| SQLite database | None (plain file) |
| SharedPreferences | None (plain file) |
| FlutterSecureStorage | Android Keystore (on non-rooted devices) |

---

## Network Security Config

### Status: MISSING

| Attribute | Value |
|-----------|-------|
| **Evidence:** No `network_security_config.xml` found |
| **Risk:** No certificate pinning, cleartext traffic allowed if not enforced |
| **Severity:** MEDIUM |
| **Fix:** Add network_security_config.xml with base-config cleartext=false |
| **Release Blocking?:** NO |

---

## Notification Initialization

### Verified: First-Time Flow

| Attribute | Value |
|-----------|-------|
| **Evidence:** `lib/core/services/notification_service.dart:86-122` |
| **Trigger:** Called on first schedule or settings toggle |
| **Permission:** Requested inline |
| **Status:** ⚠ No explicit user education |

---

## Crash Handling

### Status: UNVERIFIED

| Attribute | Value |
|-----------|-------|
| **Evidence:** No crash reporting initialized |
| **Current handling:** `FlutterError.onError` prints to console, `ErrorWidget.builder` shows generic screen |
| **Status:** Debug output sufficient for initial release |
| **Release Blocking?:** NO |

---

## Offline Behavior

### Verified: Cache-First Architecture

| Attribute | Value |
|-----------|-------|
| **Evidence:** Multiple repositories return local cache on 403/429/503/504/SocketException |
| **ArticleRepository:** Returns local articles on network error ✓ |
| **QuizRepository:** Returns local questions on network error ✓ |
| **ConnectivityNotifier:** Monitors network state ✓ |
| **OfflineBanner:** Shows offline state ✓ |
| **Status:** ✓ Fully functional offline |

---

## Release-Only Risks

### Verified: Debug Output

| Attribute | Value |
|-----------|-------|
| **Evidence:** 79 `debugPrint` calls found in lib/ |
| **Examples:** `categories_screen.dart:138-139`, `progress_notifier.dart:64-65` |
| **Risk:** Stack traces visible in logcat |
| **Severity:** MEDIUM |
| **Fix:** Gate behind `kDebugMode` or remove |
| **Release Blocking?:** NO |

### Verified: Error Widget

| Attribute | Value |
|-----------|-------|
| **Evidence:** `lib/main.dart:52-78` |
| **ErrorWidget.builder:** Shows generic error screen in release mode ✓ |
| **Status:** ✓ Secure |

---

## Startup Risks

### Verified: Critical Path

| Attribute | Value |
|-----------|-------|
| **Evidence:** `lib/main.dart:80-91` |
| **Supabase.initialize():** Can throw on network failure |
| **Risk:** App fails to launch if Supabase URL/key invalid |
| **Severity:** HIGH |
| **Fix:** Add validation in main.dart for empty keys in release mode |
| **Release Blocking?:** YES |

### Verified: Keystore Dependency

| Attribute | Value |
|-----------|-------|
| **Evidence:** `android/app/build.gradle.kts:36-42` |
| **key.properties required for release build** |
| **Risk:** No fallback for local builds |
| **Severity:** HIGH |
| **Release Blocking?:** YES |

---

## Top 10 Release Blockers

1. **FLAG_SECURE missing** - Medical content needs screen capture prevention  
2. **key.properties required for release build** - No signing configuration fallback  
3. **Supabase keys can be empty** - No validation causes silent launch failure  
4. **Android 13+ notification permission flow incomplete** - No runtime permission request UI  
5. **Unused dependencies** - fsrs, google_fonts inflate APK size  
6. **No network security config** - No certificate pinning for Supabase  
7. **SQLite database unencrypted** - All cached medical content readable  
8. **debugPrint statements in production** - Stack traces may leak via logcat  
9. **Telebirr number hardcoded** - Should be obfuscated or remote-configured  
10. **No explicit minSdk** - Compatibility matrix unclear