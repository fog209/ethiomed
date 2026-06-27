# WardReady — Maintainer Guide

## First Steps for New Developers

### 1. Environment Setup
```bash
# Flutter 3.11+ required (see pubspec.yaml)
git clone <repo>
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Generate Drift code
flutter analyze  # Must pass with 0 errors
```

### 2. Understanding the Architecture
Read in order:
1. `SYSTEM_OVERVIEW.md` — Overall architecture
2. `lib/main.dart` — Entry point and routing
3. `lib/app/main_shell.dart` — Tab structure
4. `lib/core/database/app_database.dart` — Database schema
5. `FEATURE_GUIDE.md` — Per-feature details

### 3. Build & Run
```bash
# Development
flutter run

# Device testing (device ID: SOAYYD7HEE65QKY5)
flutter run --device-id SOAYYD7HEE65QKY5

# Release APK
flutter build apk --release
# Requires key.properties with signing config
```

## Critical Files (Never Break)

| File | Why Critical |
|------|--------------|
| `lib/core/database/app_database.dart` | Drift schema — all data depends on it |
| `lib/main.dart` | App entry — any error here breaks everything |
| `lib/app/main_shell.dart` | Navigation shell — 6-tab structure |
| `lib/features/auth/data/auth_service.dart` | Session management — security critical |
| `lib/features/subscription/data/subscription_repository.dart` | Revenue gate — business critical |

## Never Edit Without Understanding

| File | Warning |
|------|---------|
| `lib/core/database/app_database.g.dart` | Generated — edit schema, not this file |
| `lib/features/quiz/spaced_repetition_service.dart` | SM-2 algorithm is locked |
| `android/app/build.gradle.kts` | Signing config for release builds |
| `lib/features/articles/data/article_search_provider.dart:282-298` | FTS5 index rebuild loops all articles |

## Dangerous Changes

| Change | Risk | Why |
|--------|------|-----|
| Removing providers from `quizNotifierProvider` dependencies | High | Breaks quiz entirely |
| Changing `study_sessions` table structure | High | Migrations already at v9 |
| Removing `QuizTable` columns | Medium | SM-2 scheduling depends on them |
| Removing `connectivityProvider` polling | Medium | Offline detection may fail |
| Changing route names | Medium | Deep links would break |

## Stable Areas

| Area | Note |
|------|------|
| Authentication flow | Working, well-tested |
| Article rendering (`article_detail_screen.dart`) | Complete with all sections |
| Quiz SM-2 algorithm | Locked, tested |
| Theme system | Dark mode complete, light mode defined |
| Search FTS5 | Recovery implemented |

## Technical Debt Hotspots

| File | Issue | Effort to Fix |
|------|-------|---------------|
| `lib/features/quiz/quiz_notifier.dart` | Tri-service coupling | 4h |
| `lib/features/home/presentation/categories_screen.dart:120-143` | Provider invalidation storm | 2h |
| `lib/features/quiz/exam_session_notifier.dart` | No route for UI | 8h |
| `lib/features/admin/data/admin_repository.dart:54-64` | Unpaginated user list | 4h |
| `lib/core/screens/database_recovery_screen.dart:63` | Uses exit(0) | 30m |

## Build Commands

```bash
# Analysis (ALWAYS run before commits)
flutter analyze

# Drift codegen (REQUIRED after app_database.dart changes)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build APK
flutter build apk --release --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
```

## Key Conventions

| Convention | Where |
|-----------|-------|
| No `setState` in business logic | All use Riverpod |
| Never use `!` operator in UI | Use `?.` and `??` |
| Check `mounted` after `await` | All async callbacks |
| Wrap Supabase in try/catch | All repository files |
| Use `Uri.encodeComponent` for route params | article-list navigation |

## Testing Checklist

Before any PR:
- [ ] `flutter analyze` passes (0 errors)
- [ ] Manual test: Login flow works
- [ ] Manual test: Offline mode shows cache
- [ ] Manual test: Quiz answers and SM-2 schedules
- [ ] Device test: Notification permission (Android 13+)

## Release Checklist

Before tagging release:
- [ ] Supabase keys validated in main.dart
- [ ] key.properties exists for signing
- [ ] FLAG_SECURE added to AndroidManifest
- [ ] All tests passing
- [ ] APK tested on device