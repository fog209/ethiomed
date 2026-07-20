import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currently installed app version. Mirrors `android:versionName` in
/// `android/app/build.gradle.kts` (1.0.1-beta.1 for versionCode 2).
///
/// NOTE: this is a hardcoded mirror, NOT read from `PackageInfo`. Keeping it
/// in sync with the build script is the owner's responsibility — mismatches
/// would make the forced-update gate falsely trigger or never trigger. The
/// in-app updater reads the live version from the same source via
/// [installedAppVersion].
const String kInstalledAppVersion = '1.0.1-beta.1';

/// Hardcoded minimum supported app version.
///
/// This is intentionally a static constant in app code (NOT a Supabase
/// `system_config` row) so the blocking "please update" screen works without
/// any new migration or network round-trip. The owner may later upgrade this
/// to a live remote-config source (e.g. the existing `system_config`
/// `min_required_version` row queried in `version_checker.dart`) if they want
/// to push forced-update thresholds without shipping a new APK — but that is
/// deliberately out of scope for this batch and left as a future enhancement.
const String kMinimumSupportedVersion = '1.0.1-beta.1';

/// Returns true when [installed] is below [minimum] and the app must block
/// until the user installs a newer APK.
bool isVersionUnsupported(
  String installed,
  String minimum,
) {
  final installedParts =
      installed.split('.').map(int.tryParse).whereType<int>().toList();
  final minimumParts =
      minimum.split('.').map(int.tryParse).whereType<int>().toList();

  for (var i = 0; i < 3; i++) {
    final installedVal = i < installedParts.length ? installedParts[i] : 0;
    final minimumVal = i < minimumParts.length ? minimumParts[i] : 0;
    if (installedVal < minimumVal) return true;
    if (installedVal > minimumVal) return false;
  }
  return false;
}

/// Pure provider that evaluates the hardcoded minimum-version gate.
/// Synchronous + offline-safe, so it can be checked at app start before any
/// async work (unlike the network-dependent `versionCheckProvider`).
final forcedUpdateRequiredProvider = Provider<bool>((ref) {
  return isVersionUnsupported(kInstalledAppVersion, kMinimumSupportedVersion);
});
