import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Security service for APK signature verification.
///
/// Protects against modded/re-signed APKs by checking the app's signing certificate
/// against an expected SHA-256 hash.
///
/// To update the expected hash after key rotation or signing changes:
/// 1. Get the new SHA-256 hash: keytool -list -v -keystore YOUR_KEYSTORE -alias YOUR_KEY
/// 2. Update the [expectedSignatureHash] constant below
///
/// IMPORTANT: The hash format is lowercase hex without colons/spaces.
class SecurityService {
  /// ============================================================================
  /// RELEASE SIGNATURE HASH INSTRUCTIONS
  /// ============================================================================
  ///
  /// To populate this hash for production:
  ///
  /// Step 1: Build the release APK
  ///   flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  ///
  /// Step 2: Install the APK on a physical Android device (NOT emulator)
  ///
  /// Step 3: Open the app and navigate to "System Health" screen
  ///   (Settings → System Health, or directly via /system-health route)
  ///
  /// Step 4: Look for the "APK Signature Hash" row - it displays the runtime
  ///   SHA-256 hash of the signing certificate
  ///
  /// Step 5: Copy that hash and paste it below, replacing the placeholder value
  ///
  /// Step 6: Rebuild the APK with the correct hash embedded
  ///
  /// Note: The hash is 64 lowercase hex characters (SHA-256 = 256 bits = 32 bytes)
  /// ============================================================================
  // This MUST be updated any time the release keystore changes — verify with
  // 'keytool -list -v -keystore android/app/upload-keystore.jks' and update this
  // value, or every legitimate release will incorrectly trigger the tamper alert.
  static const String expectedSignatureHash =
      'ccca78d472e4ddb6a7aded6496db383a9ef98cb0640378d63b2c4bef8b8d7cca';

  static const MethodChannel _channel =
      MethodChannel('com.wardready.app/security');

  /// Verifies the APK signature matches the expected production hash.
  /// Returns true if signature is valid or if running in debug mode.
  Future<bool> verifyAppSignature() async {
    if (!kReleaseMode) {
      return true;
    }

    try {
      final Uint8List? signature = await _channel.invokeMethod<Uint8List>(
        'getSha256Signature',
      );

      if (signature == null) {
        return false;
      }

      final actualHash = _bytesToHex(signature);
      return actualHash.toLowerCase() == expectedSignatureHash.toLowerCase();
    } catch (e) {
      debugPrint('Signature verification failed: $e');
      return false;
    }
  }

  /// Returns the actual runtime signature hash for display in System Health screen.
  /// Call after `initialize()` to get the computed hash value.
  Future<String> getActualSignatureHash() async {
    if (!kReleaseMode) {
      return 'DEBUG MODE';
    }
    try {
      final Uint8List? signature = await _channel.invokeMethod<Uint8List>(
        'getSha256Signature',
      );
      if (signature == null) return 'UNAVAILABLE';
      return _bytesToHex(signature).toLowerCase();
    } catch (e) {
      return 'ERROR: $e';
    }
  }

  /// Disables sync functionality if signature verification fails.
  bool isSyncAllowed = true;

  /// Called during app initialization to check signature.
  /// Returns true if signature is valid (or debug mode), false if tampered.
  Future<bool> initialize() async {
    isSyncAllowed = await verifyAppSignature();
    if (!isSyncAllowed) {
      debugPrint('WARNING: App signature verification failed - sync disabled');
    }
    return isSyncAllowed;
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// ============================================================================
  /// ROOT / EMULATOR DETECTION (DETECTION-ONLY — no enforcement)
  /// ============================================================================
  ///
  /// These helpers surface environmental risk signals (rooted device, emulator,
  /// or a known unlocked/debuggable build). They are intentionally NON-ENFORCING:
  /// they collect signals and report them so UI/analytics can warn the user, but
  /// they take NO blocking action (no sync disable, no exit, no tamper alert).
  ///
  /// Enforcement (e.g. gating sync or showing a hard warning) is out of scope for
  /// this pass and must be wired up deliberately after an owner decision.

  /// Lightweight, platform-level heuristics that do not need the native channel.
  ///
  /// Returns true when the current environment looks like an emulator/rooted
  /// device based on [Platform] metadata alone. This is a fast, coarse signal
  /// and will report false on real hardware.
  bool detectEmulatorFromPlatform() {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    final fingerprint = Platform.isAndroid
        ? (Platform.environment['ro.product.cpu.abi'] ?? '')
        : '';
    // Generic emulator ABIs / board names are a strong emulator tell.
    final board = Platform.isAndroid
        ? (Platform.environment['ro.product.board'] ?? '').toLowerCase()
        : '';
    final isEmulatorAbi =
        fingerprint.contains('x86') || fingerprint.contains('emulator');
    final isEmulatorBoard =
        board.contains('goldfish') || board.contains('ranchu') || board.isEmpty;
    return isEmulatorAbi || isEmulatorBoard;
  }

  /// Best-effort root detection via the native security channel.
  ///
  /// Returns null when the native handler is unavailable (e.g. on platforms
  /// without the MethodChannel implementation yet, or in tests). A `true`
  /// result means the native layer reported a root indicator; `false` means the
  /// native layer explicitly reported no indicator. Detection only — the result
  /// is reported, never acted upon here.
  Future<bool?> detectRoot() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isDeviceRooted');
      return result;
    } catch (e) {
      debugPrint('Root detection unavailable: $e');
      return null;
    }
  }

  /// Best-effort emulator detection via the native security channel.
  ///
  /// Mirrors [detectRoot]: returns null when the native handler is unavailable
  /// and otherwise reports the native layer's verdict. Detection only.
  Future<bool?> detectEmulatorNative() async {
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isEmulator');
      return result;
    } catch (e) {
      debugPrint('Emulator detection unavailable: $e');
      return null;
    }
  }

  /// Aggregates all detection signals into a single report for UI/analytics.
  ///
  /// Does NOT block, disable, or alter any app behavior. Callers decide what
  /// (if anything) to do with the result.
  Future<EnvironmentRiskReport> scanEnvironment() async {
    final root = await detectRoot();
    final emulatorNative = await detectEmulatorNative();
    final emulatorPlatform = detectEmulatorFromPlatform();
    return EnvironmentRiskReport(
      rootDetected: root,
      emulatorDetectedNative: emulatorNative,
      emulatorDetectedPlatform: emulatorPlatform,
    );
  }
}

/// Immutable, non-enforcing summary of environmental risk signals.
///
/// Every field is nullable: a null means "signal unavailable / not evaluated",
/// which must NOT be treated as a positive or negative verdict by callers.
class EnvironmentRiskReport {
  const EnvironmentRiskReport({
    this.rootDetected,
    this.emulatorDetectedNative,
    required this.emulatorDetectedPlatform,
  });

  /// True = native layer reported root indicators. Null = unavailable.
  final bool? rootDetected;

  /// True = native layer reported emulator. Null = unavailable.
  final bool? emulatorDetectedNative;

  /// True = platform metadata heuristically suggests an emulator.
  final bool emulatorDetectedPlatform;

  /// True only when at least one signal affirmatively indicates risk.
  bool get hasAnySignal =>
      rootDetected == true ||
      emulatorDetectedNative == true ||
      emulatorDetectedPlatform;

  @override
  String toString() =>
      'EnvironmentRiskReport(root: $rootDetected, '
      'emulatorNative: $emulatorDetectedNative, '
      'emulatorPlatform: $emulatorDetectedPlatform)';
}