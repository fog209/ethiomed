import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/empty_state.dart';
import '../../reference/data/reference_repository.dart';

class LocalGuidelinesScreen extends ConsumerWidget {
  const LocalGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guidelinesAsync = ref.watch(localGuidelinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Local Guidelines')),
      body: guidelinesAsync.when(
        data: (guidelines) {
          if (guidelines.isEmpty) {
            return const EmptyState(
              icon: Icons.description,
              title: 'No guidelines yet',
              subtitle: 'Local guideline documents will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: guidelines.length,
            itemBuilder: (context, index) {
              final guideline = guidelines[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.secondary,
                  ),
                  title: Text(
                    guideline.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: guideline.description != null &&
                          guideline.description!.isNotEmpty
                      ? Text(
                          guideline.description!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Icon(
                    Icons.open_in_new,
                    color: theme.colorScheme.outline,
                  ),
                  onTap: () => _openFile(context, guideline.fileUrl),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, color: Colors.amber, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Could not load guidelines.',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  error is AppException ? error.message : 'Please try again.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(BuildContext context, String fileUrl) async {
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this document.')),
      );
    }
  }
}
