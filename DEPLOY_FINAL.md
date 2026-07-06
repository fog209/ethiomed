# WardReady Deployment Bible

## Build Commands

### Android App Bundle (Play Store)
```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=SUPABASE_URL="https://YOUR-PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR-ANON-KEY"
```

### Android APK (Sideload)
```bash
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=./debug-info \
  --dart-define=SUPABASE_URL="https://YOUR-PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR-ANON-KEY"
```

## Supabase Key Rotation

**Key Rotation Date:** Not yet rotated (initial deployment uses dart-define injection)

The anon key is injected at build time via `--dart-define` in `lib/app/env.dart`. No `.env` file is committed to source control. See `environment_config.dart` for runtime loading.

## Version Info

- **Version:** 1.0.0
- **Build Number:** 1
- **Application ID:** com.wardready.app

## Asset Bundles

- `assets/flashcards/import.json` - Empty (flashcards loaded from Supabase)
- `assets/data/lab_references.json` - Ethiopian lab values and EFDA drug doses

No full article content is bundled — all articles are loaded via Supabase sync.

## Database Schema

Schema version 17 (Drift). Tables include:
- articles, bookmarks, study_sessions, quiz_sessions
- quiz_table, flashcard_table, quiz_attempt_details
- clinical_cases, case_stages, case_options, case_progress

## Pre-launch Checklist

- [ ] Run `flutter analyze` (only 3 warnings in spaced_repetition_service.dart allowed)
- [ ] Execute `SUPABASE_SECURITY.sql` in Supabase SQL Editor
- [ ] Configure `key.properties` from template
- [ ] Test offline mode with empty database
- [ ] Verify Crashlytics is receiving test crash reports

## Signature Hash Retrieval

After building the release AAB/APK and installing:
1. Open the app
2. Go to Settings → System Health (or navigate to `/system-health`)
3. Copy the "APK Signature Hash" value
4. Update `SecurityService.expectedSignatureHash` in `lib/core/services/security_service.dart`
5. Rebuild