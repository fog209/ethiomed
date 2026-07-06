# WardReady Hotfix Guide - "Panic Button" for Launch Day

## Launch-Day Emergency Checklist

### Step 1: Content Error?
- **Where**: Supabase SQL Editor or Admin Dashboard
- **Fix**: Content errors (wrong medical info, typos, missing sections) can be fixed directly in the Supabase database
- **Command**: No app rebuild required
- **Timeline**: Students will see fixes on their next sync (within 24 hours for active users)
- **How**:
  ```sql
  -- Example content fix
  UPDATE articles 
  SET content = jsonb_set(content, '{clinicalFeatures}', '"Corrected text..."')
  WHERE id = 'wardready-diabetes';
  ```

### Step 2: App Crashing?
- **Where**: Firebase Crashlytics Console → Crashlytics → Dashboard
- **Diagnosis**: Check stack traces and affected devices
- **Fix Workflow**:
  1. Identify the crashing file and line number
  2. Fix the code in `lib/`
  3. Bump version in `pubspec.yaml` (versionCode must increment)
  4. Run release build command from `DEPLOY_FINAL.md`
  5. Distribute new APK via Telegram channel
- **Emergency Contact**: Verify with 2-3 users before full rollout

### Step 3: Sync Blocked?
- **Where**: Supabase Dashboard → Authentication → Policies
- **Checklist**:
  - Verify RLS policies are active (`SUPABASE_SECURITY.sql`)
  - Check anon key hasn't rotated unexpectedly
  - Verify Supabase project is not paused/suspended
  - Check network_security_config.xml pins match current Supabase cert
- **Quick Fix**:
  ```sql
  -- Re-apply RLS if needed
  ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
  ```

## Version Bump Quick Command
```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=SUPABASE_URL="https://kxcdzlyirdonkipcymvc.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR-ANON-KEY"
```

## Emergency Contacts
- Lead Developer: [redacted - update before launch]
- Supabase Dashboard: https://supabase.com/dashboard
- Firebase Console: https://console.firebase.google.com