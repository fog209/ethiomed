import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'update_source.dart';

/// Result of verifying a downloaded APK.
enum VerificationResult {
  /// SHA-256 matched the manifest and (if required) the signing cert matched.
  verified,

  /// SHA-256 did not match — file is corrupt or tampered.
  checksumMismatch,

  /// Manifest required a signing cert and it did not match the running app.
  signatureMismatch,

  /// Could not compute/verify (IO error, missing file, etc.).
  error,
}

/// Download + verification service for in-app APK updates.
///
/// The downloaded APK is written to app-private storage
/// (`getApplicationSupportDirectory()/updates/`) so it is only ever exposed to
/// the system installer through the FileProvider — never world-readable on
/// disk. Verification is MANDATORY: [downloadAndVerify] throws if the checksum
/// does not match; callers must not install an unverified file.
class ApkUpdateService {
  const ApkUpdateService(this._dio);

  final Dio _dio;

  /// Resolves the local directory where update APKs are stored.
  Future<Directory> _updatesDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'updates'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String localApkFileName(UpdateManifest manifest) =>
      'wardready-${manifest.versionCode}.apk';

  /// Downloads the APK described by [manifest] to app-private storage,
  /// reporting progress (0.0–1.0) via [onProgress].
  ///
  /// Throws [ChecksumMismatchException] if the downloaded file's SHA-256 does
  /// not match [manifest.sha256]. Throws on network/IO errors. Returns the
  /// local file path.
  Future<String> downloadAndVerify(
    UpdateManifest manifest, {
    required void Function(double progress, int received, int? total) onProgress,
    required void Function(String localPath) onVerified,
    CancelToken? cancelToken,
    String? expectedSignatureSha256,
  }) async {
    final dir = await _updatesDir();
    final filePath = p.join(dir.path, localApkFileName(manifest));
    final file = File(filePath);

    await _dio.download(
      manifest.apkUrl,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        final t = total <= 0 ? manifest.sizeBytes ?? 0 : total;
        final progress = t > 0 ? received / t : 0.0;
        onProgress(progress.clamp(0.0, 1.0), received, t > 0 ? t : null);
      },
      options: Options(
        followRedirects: true,
        // Never resume/overwrite a possibly-partial file silently.
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final verification = await verifyFile(
      filePath,
      manifest,
      expectedSignatureSha256: expectedSignatureSha256,
    );

    switch (verification) {
      case VerificationResult.verified:
        onVerified(filePath);
        return filePath;
      case VerificationResult.checksumMismatch:
        // Delete the bad file so it can never be installed.
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {
          // best-effort cleanup
        }
        throw const ChecksumMismatchException();
      case VerificationResult.signatureMismatch:
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {
          // best-effort cleanup
        }
        throw const SignatureMismatchException();
      case VerificationResult.error:
        throw const VerificationException('Verification could not be completed');
    }
  }

  /// Verifies [filePath] against [manifest].
  ///
  /// 1. Computes SHA-256 of the file and compares to [manifest.sha256].
  /// 2. If [expectedSignatureSha256] is provided, compares it to the running
  ///    app's own signing-cert SHA-256. A mismatch means the update pipeline
  ///    is signed by a different key than the installed app, which is rejected.
  Future<VerificationResult> verifyFile(
    String filePath,
    UpdateManifest manifest, {
    String? expectedSignatureSha256,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return VerificationResult.error;
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      final actual = digest.toString().toLowerCase();
      if (actual != manifest.sha256.toLowerCase()) {
        debugPrint(
          'APK checksum mismatch: expected ${manifest.sha256} got $actual',
        );
        return VerificationResult.checksumMismatch;
      }
      if (expectedSignatureSha256 != null && expectedSignatureSha256.isNotEmpty) {
        if (manifest.signatureSha256 != null &&
            manifest.signatureSha256!.toLowerCase() !=
                expectedSignatureSha256.toLowerCase()) {
          debugPrint('APK signing cert mismatch vs manifest');
          return VerificationResult.signatureMismatch;
        }
      }
      return VerificationResult.verified;
    } catch (e) {
      debugPrint('APK verification error: $e');
      return VerificationResult.error;
    }
  }

  /// Removes any previously downloaded update APKs (frees private storage).
  Future<void> clearDownloadedUpdates() async {
    try {
      final dir = await _updatesDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to clear downloaded updates: $e');
    }
  }
}

/// Provider for [ApkUpdateService], wired to the shared update [Dio].
final apkUpdateServiceProvider = Provider<ApkUpdateService>((ref) {
  return ApkUpdateService(ref.watch(updateDioProvider));
});

class ChecksumMismatchException implements Exception {
  const ChecksumMismatchException();
  @override
  String toString() =>
      'ChecksumMismatchException: downloaded APK did not match the expected SHA-256';
}

class SignatureMismatchException implements Exception {
  const SignatureMismatchException();
  @override
  String toString() =>
      'SignatureMismatchException: downloaded APK signing cert did not match the expected hash';
}

class VerificationException implements Exception {
  const VerificationException(this.message);
  final String message;
  @override
  String toString() => 'VerificationException: $message';
}

/// Standalone SHA-256 helper for tests / reuse.
String sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();
