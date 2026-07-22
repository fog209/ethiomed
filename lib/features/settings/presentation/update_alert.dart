import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_url_launcher.dart';
import '../../../core/providers/connectivity_notifier.dart';
import 'version_checker.dart';

class UpdateAlert extends ConsumerWidget {
  const UpdateAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    if (!connectivity) {
      return const SizedBox.shrink();
    }

    return ref.watch(versionCheckProvider).when(
      data: (result) {
        if (result == null || !result.isUpdateRequired) {
          return const SizedBox.shrink();
        }
        return AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A new version of WardReady is available with critical content updates. '
            'Please download the latest APK to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(kUpdateDownloadUrl);
                await launchHttpsUrl(context, uri);
              },
              child: const Text('Download Update'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(), // Silent: update check is optional
    );
  }
}