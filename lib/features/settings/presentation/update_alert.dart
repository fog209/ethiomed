import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/connectivity_notifier.dart';
import 'version_checker.dart';

class UpdateAlert extends ConsumerStatefulWidget {
  const UpdateAlert({super.key});

  @override
  ConsumerState<UpdateAlert> createState() => _UpdateAlertState();
}

class _UpdateAlertState extends ConsumerState<UpdateAlert> {
  bool _installFailed = false;

  Future<void> _launchDownload({required bool inBrowser}) async {
    final uri = Uri.parse(kUpdateDownloadUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: inBrowser
            ? LaunchMode.externalApplication
            : LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        setState(() {
          _installFailed = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _installFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _launchDownload(inBrowser: false),
              child: const Text('Download Update'),
            ),
            if (_installFailed)
              TextButton(
                onPressed: () => _launchDownload(inBrowser: true),
                child: const Text('Download via Browser'),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(), // Silent: update check is optional
    );
  }
}