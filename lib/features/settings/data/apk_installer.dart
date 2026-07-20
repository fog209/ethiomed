import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Native bridge to the system package installer via the
/// `com.wardready.app/installer` MethodChannel (see MainActivity.kt).
///
/// This is the ONLY path that hands a downloaded APK to Android — it goes
/// through the FileProvider authority `com.wardready.app.fileprovider` so the
/// file is exposed read-only to the installer and never written to shared
/// external storage.
class ApkInstaller {
  const ApkInstaller();

  static const MethodChannel _channel =
      MethodChannel('com.wardready.app/installer');

  /// Whether the app is allowed to request package installs (Android 8+).
  /// On older versions this returns true (permission is implicit).
  Future<bool> canRequestPackageInstalls() async {
    try {
      final result = await _channel.invokeMethod<bool>('canRequestPackageInstalls');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('canRequestPackageInstalls failed: ${e.message}');
      return false;
    }
  }

  /// Opens the system settings page where the user can grant the
  /// "Install unknown apps" permission for this app.
  Future<bool> openInstallSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openInstallSettings');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('openInstallSettings failed: ${e.message}');
      return false;
    }
  }

  /// Hands [apkPath] to the system installer. Returns true if the install
  /// intent was successfully launched. Does NOT wait for install completion.
  ///
  /// IMPORTANT: [apkPath] MUST have passed checksum/signature verification
  /// before calling this. The installer cannot do that for us.
  Future<bool> install(String apkPath) async {
    if (!File(apkPath).existsSync()) {
      throw ArgumentError('APK does not exist at $apkPath');
    }
    try {
      final result = await _channel.invokeMethod<bool>(
        'installApk',
        {'path': apkPath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('install failed: ${e.message}');
      rethrow;
    }
  }

  /// Provider for the singleton bridge.
  static const ApkInstaller instance = ApkInstaller();
}

final apkInstallerProvider = Provider<ApkInstaller>((ref) => ApkInstaller.instance);
