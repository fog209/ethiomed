import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/features/settings/data/update_source.dart';
import 'package:ethiomed/features/settings/data/apk_update_service.dart';
import 'package:ethiomed/features/settings/presentation/forced_update_gate.dart';

void main() {
  group('isNewerVersion', () {
    test('higher patch is newer', () {
      expect(isNewerVersion('1.0.2', '1.0.1-beta.1'), isTrue);
    });
    test('same version is not newer', () {
      expect(isNewerVersion('1.0.1-beta.1', '1.0.1-beta.1'), isFalse);
    });
    test('lower version is not newer', () {
      expect(isNewerVersion('1.0.0', '1.0.1-beta.1'), isFalse);
    });
    test('release beats same-base beta', () {
      expect(isNewerVersion('1.0.1', '1.0.1-beta.1'), isTrue);
    });
    test('beta does not downgrade a release', () {
      expect(isNewerVersion('1.0.1-beta.2', '1.0.1'), isFalse);
    });
    test('higher minor is newer', () {
      expect(isNewerVersion('1.1.0', '1.0.9'), isTrue);
    });
  });

  group('isVersionUnsupported (forced-update gate)', () {
    test('installed below minimum is unsupported', () {
      expect(isVersionUnsupported('1.0.0', '1.0.1'), isTrue);
    });
    test('installed equal to minimum is supported', () {
      expect(isVersionUnsupported('1.0.1-beta.1', '1.0.1-beta.1'), isFalse);
    });
    test('installed above minimum is supported', () {
      expect(isVersionUnsupported('2.0.0', '1.0.1-beta.1'), isFalse);
    });
  });

  group('UpdateManifest.fromJson', () {
    test('parses a valid manifest and lowercases hashes', () {
      final m = UpdateManifest.fromJson({
        'version': '1.0.2',
        'versionCode': 3,
        'apkUrl': 'https://example.com/app.apk',
        'sha256': 'ABCDEF${'0' * 58}',
        'sizeBytes': 1234,
        'releaseNotes': 'fixes',
      });
      expect(m.version, '1.0.2');
      expect(m.versionCode, 3);
      expect(m.sha256, 'abcdef${'0' * 58}');
      expect(m.sizeBytes, 1234);
    });

    test('throws when sha256 malformed', () {
      expect(
        () => UpdateManifest.fromJson({
          'version': '1.0.2',
          'versionCode': 3,
          'apkUrl': 'https://example.com/app.apk',
          'sha256': 'not-a-hash',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when apkUrl missing', () {
      expect(
        () => UpdateManifest.fromJson({
          'version': '1.0.2',
          'versionCode': 3,
          'sha256': 'a' * 64,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when versionCode missing', () {
      expect(
        () => UpdateManifest.fromJson({
          'version': '1.0.2',
          'apkUrl': 'https://example.com/app.apk',
          'sha256': 'a' * 64,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ApkUpdateService.verifyFile', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('updater_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('verified when checksum matches', () async {
      final content = Uint8List.fromList([1, 2, 3, 4, 5]);
      final digest = sha256.convert(content);
      final file = File('${tempDir.path}/a.apk')..writeAsBytesSync(content);
      final manifest = UpdateManifest(
        version: '1.0.2',
        versionCode: 3,
        minRequiredVersion: '1.0.1',
        apkUrl: 'https://example.com/a.apk',
        sha256: digest.toString(),
      );
      final service = ApkUpdateService(Dio());
      final result = await service.verifyFile(file.path, manifest);
      expect(result, VerificationResult.verified);
    });

    test('checksumMismatch when checksum differs', () async {
      final content = Uint8List.fromList([1, 2, 3, 4, 5]);
      final file = File('${tempDir.path}/b.apk')..writeAsBytesSync(content);
      final manifest = UpdateManifest(
        version: '1.0.2',
        versionCode: 3,
        minRequiredVersion: '1.0.1',
        apkUrl: 'https://example.com/b.apk',
        sha256: 'f' * 64,
      );
      final service = ApkUpdateService(Dio());
      final result = await service.verifyFile(file.path, manifest);
      expect(result, VerificationResult.checksumMismatch);
    });

    test('signatureMismatch when manifest cert differs from expected', () async {
      final content = Uint8List.fromList([9, 9]);
      final digest = sha256.convert(content);
      final file = File('${tempDir.path}/c.apk')..writeAsBytesSync(content);
      final manifest = UpdateManifest(
        version: '1.0.2',
        versionCode: 3,
        minRequiredVersion: '1.0.1',
        apkUrl: 'https://example.com/c.apk',
        sha256: digest.toString(),
        signatureSha256: 'a' * 64,
      );
      final service = ApkUpdateService(Dio());
      final result = await service.verifyFile(
        file.path,
        manifest,
        expectedSignatureSha256: 'b' * 64,
      );
      expect(result, VerificationResult.signatureMismatch);
    });

    test('sha256Hex helper matches crypto', () {
      final bytes = Uint8List.fromList([0, 255, 16]);
      expect(sha256Hex(bytes), sha256.convert(bytes).toString());
    });
  });
}
