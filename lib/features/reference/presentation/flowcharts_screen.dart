import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../reference/data/reference_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/empty_state.dart';

class FlowchartsScreen extends ConsumerWidget {
  const FlowchartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final flowchartsAsync = ref.watch(flowchartsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flowcharts')),
      body: flowchartsAsync.when(
        data: (flowcharts) {
          if (flowcharts.isEmpty) {
            return const EmptyState(
              icon: Icons.account_tree,
              title: 'No flowcharts yet',
              subtitle: 'Flowchart references will appear here.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: flowcharts.length,
            itemBuilder: (context, index) {
              final flowchart = flowcharts[index];
              return InkWell(
                onTap: () => context.push(
                  '/flowchart-viewer',
                  extra: <String, String?>{
                    'url': flowchart.imageUrl,
                    'title': flowchart.title,
                  },
                ),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: flowchart.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: 600,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          flowchart.title,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                  'Could not load flowcharts.',
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
}
