import 'dart:async';

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
  static const String expectedSignatureHash =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

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
}