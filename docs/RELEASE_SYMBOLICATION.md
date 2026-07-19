# Release builds & crash symbolication

Release APKs are built with obfuscation so the Dart symbol names are not
shipped in the binary. To debug obfuscated crash reports you must keep the
matching debug-info output (`--split-debug-info`).

## Local build

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols/<version>
```

`<version>` should match the `version` field in `pubspec.yaml`
(e.g. `1.0.1-beta.1+2`) so each release's symbols are namespaced separately
under `build/symbols/`.

## CI

`.github/workflows/ci.yml` runs this same command on pushes to `master` and
uploads the symbol directory as a build artifact
(`symbols-<version>`, retained 90 days). The symbols are gitignored and never
committed to the repo.

## Symbolicating a crash

Crash reporting (e.g. Firebase Crashlytics) returns an obfuscated stack trace
with mangled symbol names. To map it back to readable Dart symbols:

```bash
flutter symbolize \
  --input=crash_dump.txt \
  --debug-info=build/symbols/<version>
```

- `crash_dump.txt` — the raw obfuscated stack trace from the crash reporter.
- `--debug-info` — point at the **same** `build/symbols/<version>` directory
  produced by the build whose binary the crash came from. Using mismatched
  symbols yields meaningless output, so keep each version's directory until
  that release is retired.
