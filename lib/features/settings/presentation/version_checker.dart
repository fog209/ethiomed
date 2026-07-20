import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/connectivity_notifier.dart';

const String kCurrentAppVersion = '1.0.1-beta.1';

final versionCheckProvider = FutureProvider<VersionCheckResult?>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  if (!connectivity) {
    return null;
  }

  try {
    final response = await Supabase.instance.client
        .from('system_config')
        .select('value')
        .eq('key', 'min_required_version')
        .limit(1)
        .maybeSingle();

    final minRequired = response?['value'] as String?;
    if (minRequired == null || minRequired.isEmpty) {
      return null;
    }

    final isUpdateRequired = _isVersionOutdated(kCurrentAppVersion, minRequired);
    return VersionCheckResult(
      isUpdateRequired: isUpdateRequired,
      currentVersion: kCurrentAppVersion,
      latestVersion: minRequired,
    );
  } catch (e) {
    return null;
  }
});

bool _isVersionOutdated(String current, String minRequired) {
  final currentParts = current.split('.').map(int.tryParse).whereType<int>().toList();
  final minParts = minRequired.split('.').map(int.tryParse).whereType<int>().toList();

  for (var i = 0; i < 3; i++) {
    final currentVal = i < currentParts.length ? currentParts[i] : 0;
    final minVal = i < minParts.length ? minParts[i] : 0;
    if (currentVal < minVal) return true;
    if (currentVal > minVal) return false;
  }
  return false;
}

class VersionCheckResult {
  const VersionCheckResult({
    required this.isUpdateRequired,
    required this.currentVersion,
    required this.latestVersion,
  });

  final bool isUpdateRequired;
  final String currentVersion;
  final String? latestVersion;
}

const String kUpdateDownloadUrl = 'https://t.me/wardready_channel';