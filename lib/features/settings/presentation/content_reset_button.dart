import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../articles/data/content_update_service.dart';
import '../data/content_reset_service.dart';

/// "Clear cache / Force re-sync" panic button. Wipes ONLY the allowlisted
/// server-sourced content tables (see [kContentResetAllowlist]) behind a
/// confirmation dialog, then triggers a re-sync of those tables. It can never
/// touch SM-2 state, Notes, Saved articles, or any other user progress.
class ContentResetButton extends ConsumerWidget {
  const ContentResetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.cloud_sync_outlined, color: theme.colorScheme.error),
      title: Text(
        'Clear cache / Force re-sync',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      subtitle: const Text(
        'Re-download articles & section metadata. '
        'Your notes, saved items and SM-2 progress are kept.',
      ),
      onTap: () => _confirmAndReset(context, ref),
    );
  }

  Future<void> _confirmAndReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear content cache?'),
        content: const Text(
          'This re-downloads all articles and section metadata from the '
          'server. Your notes, bookmarks, learnt items, and spaced-repetition '
          'progress will NOT be affected.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear & Re-sync'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);
    final service = ref.read(contentResetServiceProvider);
    final result = await service.resetContentCache();

    if (!context.mounted) return;

    if (result.hasErrors) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Some content failed to clear: ${result.errors.join('; ')}'),
        ),
      );
      return;
    }

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Content cache cleared. Re-syncing…'),
      ),
    );

    // Kick a re-sync of the cleared content tables. Both are no-ops when
    // Supabase is offline; the next launch/in-app sync will refill them.
    try {
      await ref.read(contentUpdateServiceProvider).syncSectionRegistry();
      await ref.read(contentUpdateServiceProvider).checkForUpdates();
    } catch (e) {
      debugPrint('Post-reset re-sync trigger failed: $e');
    }
  }
}
