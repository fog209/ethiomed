import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';

/// Full-screen, pinch/drag-zoomable view of a single flowchart image.
/// Reuses the existing [CachedNetworkImage] pattern from the article detail
/// renderer; zoom/pan is provided by Flutter's built-in [InteractiveViewer]
/// (no new package required).
class FlowchartViewerScreen extends ConsumerWidget {
  const FlowchartViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final extra = GoRouterState.of(context).extra;
    String? url;
    String? title;
    if (extra is Map) {
      url = extra['url'] as String?;
      title = extra['title'] as String?;
    }
    title = title ?? 'Flowchart';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: url == null || url.isEmpty
          ? const EmptyState(
              icon: Icons.image_not_supported,
              title: 'Image unavailable',
              subtitle: 'This flowchart has no image URL.',
            )
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, u) => CircularProgressIndicator(
                    color: theme.colorScheme.secondary,
                  ),
                  errorWidget: (context, u, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
