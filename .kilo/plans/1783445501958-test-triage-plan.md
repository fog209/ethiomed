# Triage: Verification Results & Failing-Test Remediation

## 1. Category list (verified directly from `lib/core/config/app_config.dart`)

- **Clinical: 20** — Internal Medicine, Pulmonology, Infectious Diseases, Gastroenterology, Endocrinology, Hematology, OB/GYN, Pediatrics, General Surgery, Psychiatry, Dermatology, Ophthalmology, ENT, Pharmacology, Radiology, Emergency Medicine, Orthopedics, Anesthesiology, Public Health and Epidemiology, Forensic Medicine.
- **Preclinical: 5** — Microbiology, Physiology, Biochemistry, Pathology, Anatomy.
- **Total: 25.**

## 2. `flutter analyze` (fresh)

- Default scope (`lib/`, `test/`, `web/`, `bin/`): **No issues found!** (ran in 87.6s)
- Explicit `integration_test/`: **No issues found!** (ran in 10.6s)

`flutter analyze` does NOT flag any of the expected ~4 issues. They surface only under `flutter test` / `flutter build` (per user confirmation).

## 3. `flutter test` — 3 failing tests (exit 1)

All in `test/article_model_test.dart`, all the same root cause:

```
test/article_model_test.dart: Article.fromJson category as null defaults to General [E]
  Expected: 'General'
    Actual: ['General']
     Which: not an <Instance of 'String'>
test/article_model_test.dart: Article.fromJson category as empty string defaults to General [E]
  Expected: 'General'
    Actual: ['General']
test/article_model_test.dart: Article.fromJson category as whitespace defaults to General [E]
  Expected: 'General'
    Actual: ['   ']
```

Root cause: `lib/features/articles/domain/models/article.dart:7` declares
`final List<String> category;` (a category *path*: `[parent, subcategory]`).
`Article.fromJson` deliberately returns `['General']` (a `List<String>`) when the
source `category` is null/empty/whitespace (lines 62–71). The 3 tests still
assert `category` is a `String` (`'General'`), so they are **stale** relative to
the current, broadly-used model contract (`parentCategory`, `subcategory`,
`categoryName` getters all depend on `category` being a `List<String>`).

The model is the intended contract (used across `article_detail_screen`,
`category_progress_provider`, search/repository, etc.), so reverting the model
to `String` would regress those consumers. The fix is to update the 3 tests.

## 4. `flutter test integration_test` — no code issues

```
No supported devices connected.
... No devices are connected. Ensure that `flutter doctor` shows at least one connected device
```

No analysis/lint/test failures — it simply cannot run because no device is
attached (device SOAYYD7HEE65QKY5 was disconnected earlier). Not a code defect.

## 5. `flutter build apk --debug` — clean (exit 0)

Only an informational pub notice, no error:
```
  sqlite3_flutter_libs 0.5.42 (0.6.0+eol available)
```
The `sqlite3`-related item the user expected is just this **deprecation marker**
(`0.6.0+eol` = end-of-life) for `sqlite3_flutter_libs`. No build error, no native
glue failure. (Also a benign `share_plus` KGP warning unrelated to sqlite3.)

## Decision / Open question
Whether to (A) update the 3 stale tests to assert the `List<String>` contract
(`expect(article.category, ['General'])`), or (B) revert `Article.category` to
`String` and rework the path getters. **Recommended: (A)** — the `List<String>`
path model is the intended, widely-consumed design.

## Proposed change (if A chosen)
- `test/article_model_test.dart`: change the 3 `expect(article.category, 'General')`
  assertions (approx. lines 100, 109, 118) to `expect(article.category, ['General'])`.
  (Whitespace case: confirm whether `['   ']` is the desired output or whether
  `fromJson` should trim → `['General']`; the test currently receives `['   ']`.)

## Validation
- `C:\flutter\bin\flutter.bat test` → expect 0 failures.
- `C:\flutter\bin\flutter.bat analyze` → already clean; remains clean.
