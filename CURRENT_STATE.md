# WardReady — Current State
_Update this file after every KiloCode session and every Supabase batch_

---

## 📅 Last Updated
Date: 2026-06-19
Updated by: (you — fill in after each session)

---

## 📦 Git State
- Branch: `master`
- Last commit message: (fill in)
- Pending commits: YES — `git add . && git commit -m "checkpoint"` before next session
- Remote: pushed / NOT pushed (circle one)

---

## 📰 Article Count
Run this to get real numbers:
SELECT category, COUNT(*) as count FROM articles GROUP BY category ORDER BY count DESC;

| Category | Target | In Supabase |
|---|---|---|
| Internal Medicine | 52 | ? |
| Pulmonology | 20 | ? |
| Infectious Diseases | 30 | ? |
| Gastroenterology | 20 | ? |
| Endocrinology | 17 | ? |
| Hematology | 10 | ? |
| OB/GYN | 20 | ? |
| Pediatrics | 22 | ? |
| General Surgery | 15 | ? |
| Psychiatry | 10 | ? |
| Dermatology | 10 | ? |
| Ophthalmology | 8 | ? |
| ENT | 8 | ? |
| Pharmacology | 25 | ? |
| Microbiology | 45 | ? |
| Physiology | 34 | ? |
| Biochemistry | 25 | ? |
| Pathology | 40 | ? |
| Anatomy | 30 | ? |
| TOTAL | 441 | ? |

---

## ✅ Phase Completion
- [x] Phase 0 — Flutter + Supabase + Auth
- [x] Phase 1 — Drift, FTS5, Articles, Search, Bookmarks, Dark mode, Subscription gate
- [x] Phase 2 (core) — WardReady branding, MainShell, Ethiopian Pearl UI, MigrationStrategy, search history, category filters
- [ ] Phase 2 (remaining) — Pagination (article_list_screen.dart), Admin panel
- [ ] Phase 3 — Release signing, signed APK, device test

---

## 🔨 In Progress Right Now
_Nothing — idle_

---

## 🐛 Known Issues / Broken Things
- None confirmed at time of writing — update as found

---

## 📁 Key File Locations
lib/
  app/
    main.dart
    main_shell.dart          ← MainShell + BottomNavigationBar (4 tabs)
    app_config.dart          ← category strings, Supabase URL/key, colours
  features/
    articles/
      article_list_screen.dart    ← needs pagination (Phase 2 remaining)
      article_viewer_screen.dart  ← Ethiopian Pearl + Mnemonics sections
      article_model.dart          ← includes ethiopianContext + mnemonics
    search/
      search_screen.dart
      search_history_service.dart
    bookmarks/
    settings/
    admin/                        ← Phase 2 remaining
    quiz/                         ← Phase 3 new (F1 MCQ)
    progress/                     ← Phase 3 new
  core/
    database/
      app_database.dart           ← Drift AppDatabase + MigrationStrategy
    services/
      auth_service.dart
      sync_service.dart
      subscription_gate.dart
android/
  app/
    build.gradle
  key.properties                  ← DO NOT COMMIT (in .gitignore)
supabase/
  schema.sql

---

## 🎨 Theme Constants
- Navy: #1A237E
- Gold: #F9A825
- Material 3, dark navy base

---

## 📱 Test Device
- Model: Nex N2 Pro
- ADB ID: SOAYYD7HEE65QKY5
- Connect: flutter run -d SOAYYD7HEE65QKY5
- Install APK: flutter install -d SOAYYD7HEE65QKY5
- Logcat (filtered): fdb logcat | grep -E "flutter|WardReady|E/"

---

## 🗓️ Deadline
- N2 Pro free window closes: ~June 23, 2026
- Distribution target: June 27, 2026
- Priority before deadline: signed release APK on device

---

## 🚦 flutter analyze Status
- Last run: (fill in date)
- Result: zero errors / HAS ERRORS
- Errors: (paste here if any)