# KILOCODE.md — KiloCode Project Context

## App Identity
- Name: WardReady (was EthioMed)
- Type: Offline-first Flutter Android APK
- Purpose: Medical education for Ethiopian health science students
- Test device ID: SOAYYD7HEE65QKY5
- Colors: Navy #1A237E | Gold #F9A825
- Theme: Material 3 dark mode

## Tech Stack — DO NOT CHANGE
- State: Riverpod ONLY — never setState in business logic
- Local DB: Drift ONLY — never raw SQLite
- HTTP: dio ONLY — never raw http package
- Secrets: flutter_secure_storage ONLY — never SharedPreferences for secrets
- Backend: Supabase (Auth + PostgreSQL + Storage)

## Packages — DO NOT ADD NEW ONES
supabase_flutter, drift, sqlite3_flutter_libs, path_provider,
flutter_secure_storage, flutter_riverpod, riverpod_annotation,
dio, cached_network_image, shimmer, flutter_markdown,
google_fonts, url_launcher, shared_preferences

## Coding Rules
- debugPrint not print
- try/catch with PostgrestException on ALL Supabase calls
- context.mounted check after every await
- const constructors wherever possible
- Never use ! unless certain — prefer ?. and ??
- Never hardcode keys — use AppConfig class
- Never touch *.g.dart files
- Never add Firebase
- Never change pubspec.yaml without explicit instruction

## Project Structure
lib/
  app/           → AppConfig, main.dart, main_shell.dart (4-tab nav)
  features/
    auth/        → login, register, auth_service.dart
    articles/    → article_model.dart, article_viewer_screen.dart
    categories/  → categories_screen.dart
    search/      → search_screen.dart, search_history_service.dart
    bookmarks/   → bookmark_service.dart, bookmarks_screen.dart
    settings/    → settings_screen.dart
    admin/       → (to be built — users list + activate button)
  core/
    database/    → app_database.dart (Drift)
    sync/        → sync_service.dart
    subscription/→ subscription_service.dart

## Article Model— 14 Fields in content JSONB
definition, epidemiology, etiology, pathophysiology,
clinicalFeatures, redFlags, approach, diagnosis,
treatment, contraindications, complications,
clinicalPearls, ethiopianContext, mnemonics

## What Is Built (Day 15)
- Auth: email/password working
- Drift DB: ArticlesTable, FTS5, Bookmarks, SyncMeta
- Article viewer: expandable sections, markdown rendering
- Categories screen: 16 specialties GridView
- Search: FTS5 + debounce + history + result count
- Bookmarks: swipe to dismiss
- Sync: first sync + delta sync
- MainShell: 4-tab BottomNavigationBar
- Ethiopian Clinical Pearl + Mnemonics UI rendered
- MigrationStrategy implemented
- flutter analyze: zero errors

## What Is NOT Built Yet
- Pagination in article_list_screen.dart (20/page infinite scroll)
- Admin panel: lib/features/admin/ (users list + activate button)
- New article fields UI: redFlags (red box), approach (numbered steps),
  contraindications (orange box), clinicalPearls (gold box)
- flutter build apk --release (CRITICAL before June 23)

## Task Rules for KiloCode
- One file per task — never multi-file in one prompt
- Never split a task another tool already started
- Run flutter analyze after every change — must be zero errors
- Run on device: flutter run -d SOAYYD7HEE65QKY5
- Commit after every working change: git add . && git commit -m "feat: ..."

## Critical Deadlines
- June 23: Nex N2 Pro free tier ends — must have APK built before this
- June 27: Distribution target

## Do Not Touch
- *.g.dart (generated files)
- pubspec.yaml (unless explicitly told)
- /android folder internals
- Any file KiloCode or Jules already has in progress
