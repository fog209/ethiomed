# WardReady — Agent Instructions

This file is read automatically by ZCode at the start of every task in
this workspace. It is the operational summary of the full project
context (GMPlan.txt / master context doc). If something here seems to
conflict with a specific task instruction given in chat, the chat
instruction for THAT task wins — but these rules apply by default.

## Identity
- App name: WardReady. NEVER "EthioMed" (old name, retired — if you see
  it anywhere, flag it, don't silently rename in scope-creep).
- applicationId: com.wardready.app
- Offline-first Flutter Android APK. Medical education for Ethiopian
  health science students (EHPLE exam prep).
- Builder is a non-developer. Be explicit and conservative — do not
  assume context that isn't written down here or in the task.

## Locked Tech Stack — DO NOT ADD OR REMOVE PACKAGES
Flutter + Dart, Supabase (Auth + Postgres + Storage), Drift (ALL local
DB), Riverpod (ALL state), dio (ALL HTTP), flutter_secure_storage (ALL
secrets), GoRouter (ALL navigation), Material 3, manual Telebirr only
payment (no Chapa/Stripe/Play Billing, ever).

Exact pubspec.yaml packages — do not add, remove, or suggest alternatives:
supabase_flutter, drift, sqlite3_flutter_libs, path_provider,
flutter_secure_storage, flutter_riverpod, riverpod_annotation, dio,
cached_network_image, shimmer, flutter_markdown, google_fonts,
url_launcher, shared_preferences, package_info_plus, go_router,
flutter_local_notifications, build_runner (dev), drift_dev (dev),
riverpod_generator (dev)

If a task seems to need a new package: STOP and ask instead of adding
it. This is the single most important rule in this file.

## Absolute prohibitions
- Never touch any `*.g.dart` file.
- Never edit `pubspec.yaml` without the human explicitly approving it
  in that specific task's instructions.
- Never modify `lib/features/quiz/spaced_repetition_service.dart`
  (SM-2 algorithm) under any circumstance, for any task, even if the
  task seems related to it. If a fix seems to require touching it,
  stop and say so instead.
- Never use `Navigator.push` / `Navigator.pop` / `Navigator.pushReplacement`.
  GoRouter only: `context.push()` for drill-down screens that need back-
  stack behavior (article detail, admin, terms, privacy, etc.),
  `context.go()` for top-level/tab navigation, `context.pop()` to
  return. Always guard pop with
  `context.canPop() ? context.pop() : context.go('/home')`.
- Never use `print()`. `debugPrint()` only.
- Never use `setState()` for business logic. Riverpod only.
  `setState()` is allowed only for purely local widget animation state.
- Never add Firebase. Never add Sentry or any crash-reporting package
  without an explicit go-ahead (it's a known gap, but the package
  decision is the human's to make, not yours).
- Never use `!` unless the value is provably non-null. Use `?.` / `??`.

## Database (Drift)
All local DB access goes through Drift. Never raw SQLite.
**DRIFT RULE — order is non-negotiable**: any task that touches
`lib/core/database/app_database.dart` (schema, tables, columns) MUST
run this BEFORE `flutter analyze`:
```
dart run build_runner build --delete-conflicting-outputs
```

## HTTP
dio for all HTTP. Never the raw `http` package.
Supabase calls: catch `PostgrestException` first, then `catch (e)`.

## Async safety
Always check `context.mounted` after every `await` inside a Widget.
Always check `if (!mounted) return;` in StatefulWidget async callbacks.
`dispose()` must ONLY call `.dispose()`, `.cancel()`, or
`focusNode.dispose()` — never `ref.read()` / `ref.watch()` inside it.

## Theming
Use `Theme.of(context).colorScheme.*` everywhere except the explicit
exceptions below. Mapping in use throughout the project:
- Navy backgrounds → `colorScheme.surface` / `surfaceContainerHighest`
- Navy primary icon → `colorScheme.primary`
- Navy border/divider → `colorScheme.outline`
- Gold accent/CTA → `colorScheme.secondary`
- White text on Navy → `colorScheme.onSurface`
- White text on Gold → `colorScheme.onSecondary`

**Never migrate these (intentional exceptions):**
- `Colors.white` on MarkdownBody (explicit Phase 3 fix)
- `Colors.amber` on Learning Radar weak sections (semantic data color)
- SM-2 buttons: red=Again, orange=Hard, green=Good, blue=Easy
- `ErrorWidget.builder` colors (no BuildContext available, static)
- Heatmap intensity colors (semantic data visualization)

## Validation & Git workflow (apply to every task)
1. After any code change, run: `C:\flutter\bin\flutter.bat analyze`
2. Zero errors required. If errors appear:
   - Do not start or continue any other task.
   - Fix ONLY the errors shown. No unrelated logic changes. No other files.
   - Re-run analyze. Repeat until clean.
   - If the SAME file fails twice in this loop: STOP completely. Report
     the file and error instead of attempting a third fix.
3. Once clean: `git add .` → `git commit -m "<message>"` → `git push origin master`.
4. Use `--debug` APK builds for all diagnosis. Never `--release` while debugging.
5. Prefer `const` constructors where possible.

## Things that are already done — do not re-implement or re-litigate
Auth, category navigation (19 categories), article sync (auto + manual),
offline article cache, article viewer, FTS5 search with debounce, SM-2
quiz engine, Learning Radar, High-Yield mode, EHPLE exam mode, progress
screen + heatmap, streaks, bookmarks, onboarding, legal screens,
settings, theme toggle, session timeout, local notifications, admin
dashboard, retry-wrong-answers, today's-plan card, read-time estimate,
android:label fix, POST_NOTIFICATIONS permission, allowBackup=false,
Proguard rules for Drift R8, edge-to-edge inset handling,
secondaryContainer in darkTheme.

## Things explicitly NOT to start without a human go-ahead in that task
Certificate pinning, accessibility audit, light theme customization,
GitHub Actions CI, Play Store assets, privacy policy public hosting,
crash reporting/Sentry, drug reference lookup, clinical calculators,
Amharic UI, weekly performance summary, outbox/sync queue, Impeller
renderer + shader precompilation, SM-2 isolate offloading (blocked
anyway by the "never modify spaced_repetition_service.dart" rule),
token key rename ("ethiomed_" prefix in auth_service.dart).

## Things that will never be built — don't propose these
A profession selector (Medicine only, by design). Firebase. Chapa,
Stripe, or Play Billing (Telebirr only, manual activation).

## Release signing key & backups
- Upload keystore backup location: <FILL IN>  (add the safe storage location where `android/app/upload-keystore.jks` is backed up)
- The upload keystore (`android/app/upload-keystore.jks`) and `android/key.properties` are gitignored and MUST NOT be committed.
- If the upload keystore is lost, Google Play App Signing can issue an upload-key reset; keep the Play Console recovery info safe.
- Supabase managed DB backups (daily + Point-in-Time Recovery) and Supabase project settings are dashboard-only and are NOT captured in this repo — verify them manually in the Supabase dashboard (Project Settings → Database → Backups).

## Working style
- One task at a time. Don't bundle unrelated fixes into one commit.
- Don't summarize a plan as if it's done — actually make the change,
  run analyze, then report what happened.
- If a task description and this file conflict, point out the conflict
  before proceeding rather than silently picking one.
