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

  /// Disables sync functionality if signature verification fails.
  bool isSyncAllowed = true;

  /// Called during app initialization to check signature.
  Future<void> initialize() async {
    isSyncAllowed = await verifyAppSignature();
    if (!isSyncAllowed) {
      debugPrint('WARNING: App signature verification failed - sync disabled');
    }
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}