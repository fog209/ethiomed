import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/updater_provider.dart';
import '../presentation/version_checker.dart';
import 'forced_update_gate.dart';

/// Dismissible in-app update bottom sheet.
///
/// This is the SOFT, optional update experience. It is NOT the forced-update
/// gate: the user can swipe/close it and keep using the app. Forced blocking
/// is handled entirely by `ForcedUpdateScreen` (`/forced-update` route) which
/// this sheet deliberately does not touch.
class UpdateSheet extends ConsumerWidget {
  const UpdateSheet({super.key});

  static const String _manualDownloadUrl = kUpdateDownloadUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updaterProvider);
    final theme = Theme.of(context);

    if (state.status == UpdaterStatus.checking) {
      return Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update_alt_rounded,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Checking for updates…',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      );
    }

    if (state.status == UpdaterStatus.upToDate) {
      return Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
children: [
               Icon(
                 Icons.check_circle_rounded,
                 color: theme.colorScheme.secondary,
                 size: 28,
               ),
               const SizedBox(width: 12),
               Text(
                 "You're up to date",
                 style: theme.textTheme.titleMedium?.copyWith(
                   color: theme.colorScheme.onSurface,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ],
           ),
            const SizedBox(height: 12),
            Text(
              'WardReady ${state.manifest?.version ?? kInstalledAppVersion} is the latest version.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      );
    }

    if (state.status != UpdaterStatus.updateAvailable &&
        state.status != UpdaterStatus.downloading &&
        state.status != UpdaterStatus.readyToInstall &&
        state.status != UpdaterStatus.installing &&
        state.status != UpdaterStatus.verificationFailed &&
        state.status != UpdaterStatus.error) {
      return const SizedBox.shrink();
    }

    final manifest = state.manifest;
    final isDownloading = state.status == UpdaterStatus.downloading;
    final isReady = state.status == UpdaterStatus.readyToInstall ||
        state.status == UpdaterStatus.installing;
    final isFailed = state.status == UpdaterStatus.verificationFailed ||
        state.status == UpdaterStatus.error;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                color: theme.colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFailed ? 'Update unavailable' : 'Update available',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isDownloading && !isReady)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(updaterProvider.notifier).dismiss();
                    if (context.canPop()) context.pop();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (manifest != null) ...[
            Text(
              'Version ${manifest.version} is available '
              '(you have $kInstalledAppVersion).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (manifest.releaseNotes != null &&
                manifest.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                manifest.releaseNotes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          if (isDownloading) ...[
            LinearProgressIndicator(
              value: state.progress > 0 ? state.progress : null,
              color: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            Text(
              _formatProgress(state.receivedBytes, state.totalBytes),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else if (isReady) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user,
                      color: theme.colorScheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Integrity verified. Ready to install.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isFailed && state.errorMessage != null) ...[
            Text(
              state.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (!isDownloading && !isReady)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final uri = Uri.parse(_manualDownloadUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('Download manually'),
                  ),
                ),
              if (!isDownloading && !isReady) const SizedBox(width: 12),
              if (isDownloading)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(updaterProvider.notifier).cancelDownload(),
                    child: const Text('Cancel'),
                  ),
                )
              else if (state.status == UpdaterStatus.updateAvailable)
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Update now'),
                    onPressed: () =>
                        ref.read(updaterProvider.notifier).download(),
                  ),
                )
              else if (isReady)
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    icon: const Icon(Icons.install_mobile_rounded),
                    label: const Text('Install'),
                    onPressed: () async {
                      final launched =
                          await ref.read(updaterProvider.notifier).install();
                      if (!context.mounted) return;
                      if (launched && context.canPop()) context.pop();
                    },
                  ),
                )
              else if (isFailed)
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                    onPressed: () =>
                        ref.read(updaterProvider.notifier).download(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatProgress(int received, int? total) {
    final r = (received / (1024 * 1024)).toStringAsFixed(1);
    if (total == null || total <= 0) return '$r MB';
    final t = (total / (1024 * 1024)).toStringAsFixed(1);
    final pct = (received / total * 100).round();
    return '$r MB / $t MB ($pct%)';
  }
}

/// Shows the [UpdateSheet] as a modal bottom sheet when an update is available.
/// Call after the launch check completes. Dismissible — never blocks the app.
void showUpdateSheetIfNeeded(BuildContext context, WidgetRef ref) {
  final status = ref.read(updaterProvider).status;
  if (status == UpdaterStatus.updateAvailable ||
      status == UpdaterStatus.readyToInstall ||
      status == UpdaterStatus.error ||
      status == UpdaterStatus.checking ||
      status == UpdaterStatus.upToDate) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => const UpdateSheet(),
    );
  }
}
