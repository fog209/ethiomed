# WardReady — UNUSED_DEPENDENCIES.md

## Confirmed Unused Packages

| Package | Version | pubspec.yaml Line | Import Found | Usage Found | Action |
|---------|---------|-----------------|------------|-----------|--------|
| fsrs | ^2.0.0 | 18 | No | No | REMOVE |
| google_fonts | ^6.2.1 | 20 | No | No | REMOVE |

---

## Unnecessary Imports (within used packages)

| File | Import | Unused | Evidence |
|------|--------|--------|----------|
| quiz_sync_service.dart | `dart:io` | No | Used for SocketException rethrow |
| quiz_sync_service.dart | `dio` | Partial | Only catches DioException |

---

## Duplicate Dependencies

| Package | Notes |
|---------|-------|
| No duplicates found | All dependencies unique |

---

## Dependencies That Could Be Replaced

| Package | SDK Alternative | Evidence |
|---------|----------------|----------|
| shared_preferences | N/A | No Flutter alternative for simple key-value |
| path_provider | N/A | No built-in for app documents dir |
| flutter_secure_storage | N/A | No built-in encrypted storage |

---

## Recommended Removal

To remove unused packages:
```yaml
# Remove these lines from pubspec.yaml:
fsrs: ^2.0.0
google_fonts: ^6.2.1
```

Then run:
```bash
flutter pub get
flutter analyze  # Verify no breakage
```