# WardReady — Architecture & Settled Decisions
*Source of Truth as of 2026-07-21*

## Stack & Services
*   **Tech Stack:** Flutter/Dart, Supabase (Auth/Postgres/Storage), Drift (Local SQLite), Riverpod (State), dio (HTTP), GoRouter (Navigation). 
*   **Firebase:** Scoped to Crashlytics ONLY (`recordFlutterError` in `main.dart`). No other Firebase services permitted.
*   **Payment Model:** Manual Telebirr. Owner manually activates 365-day subscriptions via the Admin Dashboard.
*   **Distribution:** Sideload APK only. No Google Play Store.

## Data Models & Schema
*   **Drift Local Schema:** Currently at `v26`.
*   **Content/Progress Split:** `quiz_table` and `flashcard_table` have been split into discrete Content (server-synced) and Progress (user SM-2 state) tables to prevent data loss on cache clears.
*   **Article Schema:** Dynamic `schemaVersion: 2` using `ArticleSection`. Backed by `section_registry` (allows dynamic fields without app updates).
*   **Flashcards:** Sourced from Anki (`.apkg`). Classification framework (`track` and `category`) is live.
*   **Locked File:** `spaced_repetition_service.dart` (SM-2 logic) must never be modified.

## Database Migrations (Supabase)
Migrations are manually executed by the owner via Supabase SQL Editor.
*   `0001` - `0007`, and `0010` are CONFIRMED LIVE.
*   *Note: `0008` (Activation Log) and `0009` (Referral Rewards) are missing/unbuilt.*
