import 'package:flutter/material.dart';

/// A simple, custom skeleton loading widget built with standard Flutter widgets
/// (no external packages). Uses [AnimatedBuilder] for a subtle pulse effect
/// by cycling between two opacity levels.
///
/// Replace [CircularProgressIndicator] with this on core content screens to
/// give users a perceived-performance improvement and a cleaner loading UX.
class SkeletonWidget extends StatefulWidget {
  const SkeletonWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(opacity: _opacity.value, child: child);
      },
      child: Container(
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Pre-built skeleton layouts for common patterns.
class SkeletonLayouts {
  /// A typical article card skeleton (title + 3 lines of body).
  static Widget articleCard({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonWidget(height: 22, width: 240),
          SizedBox(height: 12),
          SkeletonWidget(height: 14),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 280),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 200),
        ],
      ),
    );
  }

  /// A typical list tile skeleton (leading icon + 2 lines of text).
  static Widget listTile({Key? key, double leadingSize = 40}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SkeletonWidget(
            width: leadingSize,
            height: leadingSize,
            borderRadius: leadingSize / 2,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonWidget(height: 16, width: 180),
                SizedBox(height: 6),
                SkeletonWidget(height: 12, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Full-screen loading placeholder for article detail.
  static Widget articleDetail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonWidget(height: 28, width: 300),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 180),
          SizedBox(height: 24),
          SkeletonWidget(height: 14),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 320),
          SizedBox(height: 8),
          SkeletonWidget(height: 14),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 260),
          SizedBox(height: 24),
          SkeletonWidget(height: 200, borderRadius: 12),
          SizedBox(height: 16),
          SkeletonWidget(height: 14),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 300),
          SizedBox(height: 8),
          SkeletonWidget(height: 14),
          SizedBox(height: 8),
          SkeletonWidget(height: 14, width: 200),
        ],
      ),
    );
  }
}
