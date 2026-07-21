import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_report_service.dart';

class UserReportWidget extends ConsumerStatefulWidget {
  const UserReportWidget({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  final String contentType;
  final String contentId;

  @override
  ConsumerState<UserReportWidget> createState() => _UserReportWidgetState();
}

class _UserReportWidgetState extends ConsumerState<UserReportWidget> {
  bool _isSubmitting = false;

  Future<void> _showReportDialog() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReportBottomSheet(contentId: widget.contentId),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _isSubmitting = true;
      });
      final success = await ref.read(userReportServiceProvider).submitReport(
            contentType: widget.contentType,
            contentId: widget.contentId,
            reportText: result,
          );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Report submitted. Thank you!'
                : 'Report will be sent when you are back online.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.flag_outlined, size: 20),
      tooltip: 'Report Error',
      onPressed: _isSubmitting ? null : _showReportDialog,
    );
  }
}

class _ReportBottomSheet extends StatefulWidget {
  const _ReportBottomSheet({required this.contentId});

  final String contentId;

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Report an Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'What is wrong with this content? (e.g., typo, medical inaccuracy, formatting)',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(context, text);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}