# Plan: Safely re-enable certificate pinning for Supabase (sideload distribution)

## Context
- Distribution is sideload APK (no Play Store auto-update), monetization via the
  existing Supabase paywall.
- `android/app/src/main/res/xml/network_security_config.xml` currently has pinning
  **disabled** (placeholder pins removed, TODO left in place).
- Earlier pinning commit `4ec976c` used a **placeholder** pin
  (`osBEuy3eNf4OoLe3tPQsaocoTmiJnwvFFwUHtCkjqto=`) and pinned the overly-broad
  `supabase.co` domain (all projects). Both are wrong and must be replaced.

## Verified live certificate chain (fetched from kxcdzlyirdonkipcymvc.supabase.co, TLS 1.3)
The served TLS leaf is issued by **Google Trust Services (WE1)** — NOT Cloudflare
(the CF-Ray header seen earlier is only the CDN edge; the TLS cert is GTS).

| # | Cert | SHA-256 SPKI pin (base64) |
|---|------|---------------------------|
| 0 leaf | CN=supabase.co (issuer WE1) | `ZcJbApTb7wyllleAjHw2vYAskqdT+DhMY9aPDFwAtf4=` |
| 1 intermediate | WE1 (Google Trust Services) | `kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=` |
| 2 | GTS Root R4 | `mEflZT5enoR1FuXLgYYGqnVEoZvmf9c2bVBpiOjYQ0c=` |
| 3 root | GlobalSign Root CA | `K87oWBWM9UZfyddvDfoxL+8lpNyoUB2ptGtn0fv6G2Q=` |

## Proposed change (network_security_config.xml)
- Pin the **specific project host** `kxcdzlyirdonkipcymvc.supabase.co`
  (`includeSubdomains="true"`) — NOT the broad `supabase.co`, so we never
  accidentally trust other Supabase projects.
- `<pin-set>` with **two pins**: the leaf (primary) + the WE1 intermediate
  (backup). This survives a routine leaf rotation by Google (intermediate stays).
- Add `expiration="2026-10-06"` (~90 days from now) so that if BOTH pins
  unexpectedly rotate and no updated APK ships in time, Android falls back to
  system trust automatically — **preventing permanent lockout**.
- Remove the disable TODO and placeholder comments.

## Lockout risk analysis
- **If only the leaf cert rotates** (Google does this periodically, ~90-day
  cadence): intermediate pin [1] still matches → **no outage**.
- **If the WE1 intermediate rotates** (rarer): both pins fail → TLS hard-fails for
  all Supabase calls (auth, sync, paywall) → **app unusable** until a new APK with
  updated pins is installed.
  - Mitigation #1: `expiration` date → auto-recovery after 2026-10-06 with no user
    action.
  - Mitigation #2: ship an updated APK (sideload) with the new pin(s) before then.
- **Sideload caveat**: unlike Play Store, users must manually reinstall the APK.
  This makes a pin-rotation incident slower to remediate, which is exactly why the
  `expiration` safety net is mandatory (not optional) for this distribution model.
- **Scope**: only the Supabase host is pinned; Firebase/Crashlytics and all other
  hosts keep using system trust, so pinning cannot break them.

## Validation
1. `C:\flutter\bin\flutter.bat build apk --debug` (with Supabase --dart-define).
2. Install on device SOAYYD7HEE65QKY5; confirm app launches, login + paywall +
   article sync all succeed (pin matches live cert).
3. Negative check (optional): temporarily break a pin and confirm the app fails
   closed, then restore.
4. `C:\flutter\bin\flutter.bat analyze` (XML change has no Dart impact, but
   confirm clean anyway).

## Rollback
Pinning is contained to one XML file. If it bricks connectivity, revert this file
to the disabled state and ship a new sideload APK.
