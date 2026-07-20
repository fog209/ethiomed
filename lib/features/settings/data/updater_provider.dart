import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/services/security_service.dart';
import '../presentation/forced_update_gate.dart';
import 'apk_installer.dart';
import 'apk_update_service.dart';
import 'update_source.dart';

/// High-level state of the in-app updater, used by the UI sheet.
enum UpdaterStatus {
  /// No check performed yet / idle.
  idle,

  /// Checking the remote manifest (non-blocking).
  checking,

  /// Up to date — nothing to do.
  upToDate,

  /// A newer version is available (dismissible alert).
  updateAvailable,

  /// User declined the update this session.
  dismissed,

  /// Downloading the APK (progress reported separately).
  downloading,

  /// Download + verification succeeded; ready to install.
  readyToInstall,

  /// Install intent launched; waiting on the system installer.
  installing,

  /// Verification failed (checksum/signature) — update aborted.
  verificationFailed,

  /// A network / IO error occurred.
  error,
}

/// Immutable snapshot of the updater for the UI.
class UpdaterState {
  const UpdaterState({
    this.status = UpdaterStatus.idle,
    this.manifest,
    this.progress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes,
    this.localPath,
    this.errorMessage,
  });

  final UpdaterStatus status;
  final UpdateManifest? manifest;
  final double progress;
  final int receivedBytes;
  final int? totalBytes;
  final String? localPath;
  final String? errorMessage;

  UpdaterState copyWith({
    UpdaterStatus? status,
    UpdateManifest? manifest,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    String? localPath,
    String? errorMessage,
  }) {
    return UpdaterState(
      status: status ?? this.status,
      manifest: manifest ?? this.manifest,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      localPath: localPath ?? this.localPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Orchestrates the full update flow: check → (optional) download → verify →
/// hand-off to the system installer.
///
/// This is intentionally NON-BLOCKING and DISMISSIBLE. It never routes or
/// forces the user anywhere; the separate forced-update gate
/// (`forced_update_gate.dart` + `/forced-update` route) owns hard blocking,
/// and the two are kept deliberately separate (see task notes).
class UpdaterNotifier extends StateNotifier<UpdaterState> {
  UpdaterNotifier(this._ref)
      : _service = _ref.read(apkUpdateServiceProvider),
        _installer = _ref.read(apkInstallerProvider),
        super(const UpdaterState());

  final Ref _ref;
  final ApkUpdateService _service;
  final ApkInstaller _installer;
  CancelToken? _cancelToken;

  /// The version this build reports as its own. Mirrors the hardcoded
  /// [kInstalledAppVersion] used by the forced-update gate so the two never
  /// disagree about "what is installed".
  String get installedVersion => kInstalledAppVersion;

  /// Performs a best-effort version check against the remote manifest.
  /// Safe to call on launch; never throws to the caller (errors => upToDate).
  Future<void> checkForUpdate({bool force = false}) async {
    if (!force && state.status == UpdaterStatus.checking) return;
    if (!_ref.read(connectivityProvider)) {
      // Offline: stay idle, do not nag.
      state = state.copyWith(status: UpdaterStatus.idle);
      return;
    }
    state = state.copyWith(status: UpdaterStatus.checking, errorMessage: null);
    try {
      final manifest = await fetchUpdateManifest(
        dio: _ref.read(updateDioProvider),
        url: updateManifestUrl,
      );
      if (isNewerVersion(manifest.version, installedVersion)) {
        state = state.copyWith(
          status: UpdaterStatus.updateAvailable,
          manifest: manifest,
        );
      } else {
        state = state.copyWith(
          status: UpdaterStatus.upToDate,
          manifest: manifest,
        );
      }
    } catch (e) {
      debugPrint('Update check failed (ignored): $e');
      state = state.copyWith(status: UpdaterStatus.idle);
    }
  }

  /// Downloads + verifies the APK from the current [UpdateManifest].
  Future<void> download() async {
    final manifest = state.manifest;
    if (manifest == null) {
      state = state.copyWith(
        status: UpdaterStatus.error,
        errorMessage: 'No update manifest available',
      );
      return;
    }
    _cancelToken = CancelToken();
    state = state.copyWith(
      status: UpdaterStatus.downloading,
      progress: 0.0,
      receivedBytes: 0,
      totalBytes: null,
      errorMessage: null,
    );
    try {
      final signature = await _expectedSignatureHash();
      final path = await _service.downloadAndVerify(
        manifest,
        cancelToken: _cancelToken,
        expectedSignatureSha256: signature,
        onProgress: (progress, received, total) {
          if (mounted) {
            state = state.copyWith(
              progress: progress,
              receivedBytes: received,
              totalBytes: total,
            );
          }
        },
        onVerified: (localPath) {
          if (mounted) {
            state = state.copyWith(
              status: UpdaterStatus.readyToInstall,
              localPath: localPath,
            );
          }
        },
      );
      if (mounted && state.localPath == null) {
        state = state.copyWith(status: UpdaterStatus.readyToInstall, localPath: path);
      }
    } on ChecksumMismatchException {
      state = state.copyWith(
        status: UpdaterStatus.verificationFailed,
        errorMessage: 'Downloaded file failed integrity check. Update cancelled.',
      );
    } on SignatureMismatchException {
      state = state.copyWith(
        status: UpdaterStatus.verificationFailed,
        errorMessage: 'Update is signed by an untrusted key. Update cancelled.',
      );
    } catch (e) {
      debugPrint('Download failed: $e');
      state = state.copyWith(
        status: UpdaterStatus.error,
        errorMessage: 'Download failed. Please try again or update manually.',
      );
    }
  }

  /// Cancels an in-progress download.
  void cancelDownload() {
    _cancelToken?.cancel('User cancelled');
    _cancelToken = null;
    if (state.status == UpdaterStatus.downloading) {
      state = state.copyWith(status: UpdaterStatus.updateAvailable, progress: 0.0);
    }
  }

  /// Hands the verified APK to the system installer.
  Future<bool> install() async {
    final path = state.localPath;
    if (path == null) {
      state = state.copyWith(
        status: UpdaterStatus.error,
        errorMessage: 'No verified APK to install',
      );
      return false;
    }
    // Re-verify immediately before install as defense-in-depth (the file may
    // have been tampered with between download and install).
    final manifest = state.manifest;
    if (manifest != null) {
      final signature = await _expectedSignatureHash();
      final result = await _service.verifyFile(
        path,
        manifest,
        expectedSignatureSha256: signature,
      );
      if (result != VerificationResult.verified) {
        state = state.copyWith(
          status: UpdaterStatus.verificationFailed,
          errorMessage: 'Integrity check failed before install. Update cancelled.',
        );
        return false;
      }
    }

    final canInstall = await _installer.canRequestPackageInstalls();
    if (!canInstall) {
      // Guide the user to grant the permission; do not install.
      await _installer.openInstallSettings();
      return false;
    }

    state = state.copyWith(status: UpdaterStatus.installing);
    try {
      final launched = await _installer.install(path);
      return launched;
    } catch (e) {
      debugPrint('Install launch failed: $e');
      state = state.copyWith(
        status: UpdaterStatus.error,
        errorMessage: 'Could not start the installer. Update manually.',
      );
      return false;
    }
  }

  /// Marks the update as dismissed for this session (dismissible alert).
  void dismiss() {
    if (state.status == UpdaterStatus.updateAvailable ||
        state.status == UpdaterStatus.error) {
      state = state.copyWith(status: UpdaterStatus.dismissed);
    }
  }

  /// Returns the expected signing-cert SHA-256 for the installed app, or null
  /// when unavailable (e.g. no native channel). Null means the signature check
  /// is skipped (checksum still enforced).
  Future<String?> _expectedSignatureHash() async {
    try {
      final security = SecurityService();
      final actual = await security.getActualSignatureHash();
      if (actual == 'DEBUG MODE' || actual.isEmpty) return null;
      return actual;
    } catch (_) {
      return null;
    }
  }
}

final updaterProvider =
    StateNotifierProvider<UpdaterNotifier, UpdaterState>((ref) {
  return UpdaterNotifier(ref);
});
