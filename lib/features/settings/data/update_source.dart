import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Update manifest describing the latest available APK.
///
/// Hosted as a small JSON file (one endpoint, no new backend infra). See
/// [updateManifestUrl] for the default hosting location. Format:
///
/// ```json
/// {
///   "version": "1.0.2",
///   "versionCode": 3,
///   "minRequiredVersion": "1.0.1-beta.1",
///   "apkUrl": "https://github.com/<owner>/<repo>/releases/download/v1.0.2/app-release.apk",
///   "sha256": "abcdef...64hex...",
///   "sizeBytes": 12345678,
///   "releaseNotes": "Bug fixes and content updates.",
///   "signatureSha256": "optional 64hex hash of the signing cert"
/// }
/// ```
///
/// Security model: the client MUST verify the downloaded file's SHA-256
/// against [sha256] before installing. [signatureSha256] is optional — when
/// present it is additionally compared against the running app's signing
/// certificate hash (see `SecurityService`) so a re-signed/malicious APK is
/// rejected even if its checksum were somehow spoofed alongside the manifest.
class UpdateManifest {
  const UpdateManifest({
    required this.version,
    required this.versionCode,
    required this.minRequiredVersion,
    required this.apkUrl,
    required this.sha256,
    this.sizeBytes,
    this.releaseNotes,
    this.signatureSha256,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    final apkUrl = json['apkUrl'] as String?;
    final sha256 = json['sha256'] as String?;
    if (apkUrl == null || apkUrl.isEmpty) {
      throw const FormatException('UpdateManifest.apkUrl is required');
    }
    if (sha256 == null || sha256.isEmpty) {
      throw const FormatException('UpdateManifest.sha256 is required');
    }
    final version = json['version'] as String?;
    if (version == null || version.isEmpty) {
      throw const FormatException('UpdateManifest.version is required');
    }
    final rawVersionCode = json['versionCode'];
    final versionCode = rawVersionCode is int
        ? rawVersionCode
        : int.tryParse(rawVersionCode?.toString() ?? '');
    if (versionCode == null || versionCode <= 0) {
      throw const FormatException('UpdateManifest.versionCode must be a positive int');
    }
    final minRequiredVersion =
        (json['minRequiredVersion'] as String?) ?? version;
    final rawSha = sha256.trim().toLowerCase();
    if (!_sha256Pattern.hasMatch(rawSha)) {
      throw const FormatException('UpdateManifest.sha256 must be 64 hex chars');
    }
    final sigRaw = (json['signatureSha256'] as String?)?.trim().toLowerCase();
    if (sigRaw != null && !_sha256Pattern.hasMatch(sigRaw)) {
      throw const FormatException(
        'UpdateManifest.signatureSha256 must be 64 hex chars',
      );
    }
    final size = json['sizeBytes'];
    return UpdateManifest(
      version: version,
      versionCode: versionCode,
      minRequiredVersion: minRequiredVersion,
      apkUrl: apkUrl,
      sha256: rawSha,
      sizeBytes: size is int ? size : null,
      releaseNotes: json['releaseNotes'] as String?,
      signatureSha256: sigRaw,
    );
  }

  /// The latest version string (e.g. "1.0.2").
  final String version;

  /// Numeric version code, used to decide whether an update is available even
  /// when version-name comparison is ambiguous (pre-release tags etc.).
  final int versionCode;

  /// Minimum version a user may stay on; below this the existing
  /// non-dismissible forced-update gate should kick in.
  final String minRequiredVersion;

  /// Direct HTTPS URL of the APK (GitHub Releases asset, or any CDN).
  final String apkUrl;

  /// Expected SHA-256 of the APK, lowercase hex, 64 chars.
  final String sha256;

  /// Optional SHA-256 of the expected signing certificate. When set, the
  /// downloaded APK must be signed by that cert (compared via the installed
  /// app's own cert, not the APK file directly, to keep the check cheap).
  final String? signatureSha256;

  /// Size hint for progress UI (bytes). May be null when unknown.
  final int? sizeBytes;

  final String? releaseNotes;

  static final RegExp _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');

  Map<String, dynamic> toJson() => {
        'version': version,
        'versionCode': versionCode,
        'minRequiredVersion': minRequiredVersion,
        'apkUrl': apkUrl,
        'sha256': sha256,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
        if (releaseNotes != null) 'releaseNotes': releaseNotes,
        if (signatureSha256 != null) 'signatureSha256': signatureSha256,
      };

  @override
  String toString() =>
      'UpdateManifest(version: $version, versionCode: $versionCode, '
      'apkUrl: $apkUrl, sha256: $sha256, signatureSha256: $signatureSha256)';
}

/// Default hosting location for the update manifest.
///
/// DECISION: GitHub Releases is already the project's repo host, so we reuse it
/// rather than standing up new backend infra. The manifest is published as a
/// release asset (e.g. `update.json`) next to the APK, and fetched via the
/// public raw URL. No Supabase table or server is required.
///
/// The owner can override this per build via --dart-define=UPDATE_MANIFEST_URL
/// without changing code. This is the single source the updater consults.
const String kDefaultUpdateManifestUrl =
    'https://raw.githubusercontent.com/WardReady/ethiomed/main/update.json';

/// Returns the manifest URL, honoring a --dart-define override.
String get updateManifestUrl {
  const override = String.fromEnvironment(
    'UPDATE_MANIFEST_URL',
    defaultValue: kDefaultUpdateManifestUrl,
  );
  return override.isEmpty ? kDefaultUpdateManifestUrl : override;
}

/// Fetches + parses the [UpdateManifest] over HTTPS using dio.
///
/// Network errors are surfaced to the caller (the provider treats the check
/// as best-effort). Never throws [FormatException] for empty bodies silently —
/// it rethrows so the caller can log.
Future<UpdateManifest> fetchUpdateManifest({
  required Dio dio,
  String url = kDefaultUpdateManifestUrl,
}) async {
  final response = await dio.get<String>(
    url,
    options: Options(
      responseType: ResponseType.plain,
      // Manifest is tiny; never cache a stale update pointer.
      headers: {'Cache-Control': 'no-cache'},
    ),
  );
  final body = response.data;
  if (body == null || body.isEmpty) {
    throw const FormatException('Update manifest response was empty');
  }
  final decoded = jsonDecode(body) as Map<String, dynamic>;
  return UpdateManifest.fromJson(decoded);
}

/// Simple semver-ish comparison used to decide if an update is available.
/// Returns true when [candidate] is newer than [installed].
///
/// Pre-release tags (e.g. "-beta.1") are stripped before the x.y.z compare so
/// a tag like "1.0.1-beta.2" is never misparsed as version 2 of 1.0.1. Of two
/// versions with an identical base, a release (no suffix) is considered newer
/// than a pre-release, so promoting a beta to its release does not look like a
/// downgrade.
bool isNewerVersion(String candidate, String installed) {
  final cBase = _baseVersion(candidate);
  final iBase = _baseVersion(installed);
  final c = cBase.split('.').map(int.tryParse).whereType<int>().toList();
  final i = iBase.split('.').map(int.tryParse).whereType<int>().toList();
  for (var idx = 0; idx < 3; idx++) {
    final cv = idx < c.length ? c[idx] : 0;
    final iv = idx < i.length ? i[idx] : 0;
    if (cv > iv) return true;
    if (cv < iv) return false;
  }
  // Same x.y.z base: a release beats a pre-release of the same base.
  final cPre = _preReleaseSuffix(candidate);
  final iPre = _preReleaseSuffix(installed);
  if (cPre == null && iPre != null) return true;
  if (cPre != null && iPre == null) return false;
  return false;
}

String _baseVersion(String version) {
  final idx = version.indexOf('-');
  return idx < 0 ? version : version.substring(0, idx);
}

String? _preReleaseSuffix(String version) {
  final idx = version.indexOf('-');
  if (idx < 0) return null;
  final suffix = version.substring(idx + 1);
  return suffix.isEmpty ? null : suffix;
}

/// Riverpod provider for a shared [Dio] instance used by the updater.
/// Kept separate from any auth client so update fetches never carry session
/// tokens and cannot be redirected to an authed endpoint.
final updateDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
    ),
  );
});
