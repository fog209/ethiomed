import 'package:flutter/material.dart';

import '../../../core/utils/app_url_launcher.dart';
import 'forced_update_gate.dart';

/// Full-screen blocking screen shown when the installed app version is below
/// the minimum supported version ([kMinimumSupportedVersion]). The user cannot
/// dismiss it — they must download the latest APK to continue.
///
/// Unlike [UpdateAlert] (a soft, online-only dialog), this gate is evaluated
/// offline against a hardcoded constant so it always blocks outdated installs
/// even with no connectivity.
class ForcedUpdateScreen extends StatelessWidget {
  const ForcedUpdateScreen({super.key});

  static const String _downloadUrl = 'https://t.me/wardready_channel';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                size: 80,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Update Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This version of WardReady is no longer supported. '
                'Please download the latest APK to continue using the app.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Installed: $kInstalledAppVersion  ·  Minimum: $kMinimumSupportedVersion',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Latest APK'),
                  onPressed: () async {
                    final uri = Uri.parse(_downloadUrl);
                    await launchHttpsUrl(context, uri);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
