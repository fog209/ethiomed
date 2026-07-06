import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content_flag_service.dart';

class ContentFlagWidget extends ConsumerStatefulWidget {
  const ContentFlagWidget({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  final ContentType contentType;
  final String contentId;

  @override
  ConsumerState<ContentFlagWidget> createState() => _ContentFlagWidgetState();
}

class FlagSubmission {
  final ContentType contentType;
  final String contentId;
  final IssueType issueType;
  final String userNote;

  FlagSubmission({
    required this.contentType,
    required this.contentId,
    required this.issueType,
    required this.userNote,
  });
}

class _ContentFlagWidgetState extends ConsumerState<ContentFlagWidget> {
  bool _isSubmitting = false;

  Future<void> _showFlagDialog() async {
    final result = await showModalBottomSheet<FlagSubmission>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _FlagDialog(contentType: widget.contentType, contentId: widget.contentId),
    );

    if (result != null && mounted) {
      setState(() {
        _isSubmitting = true;
      });
      final success = await ref.read(contentFlagServiceProvider).submitFlag(
            contentType: result.contentType,
            contentId: result.contentId,
            issueType: result.issueType,
            userNote: result.userNote,
          );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue reported successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Report will be sent when you are back online')),
          );
        }
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
      tooltip: 'Report Issue',
      onPressed: _isSubmitting ? null : _showFlagDialog,
    );
  }
}

class _FlagDialog extends StatefulWidget {
  const _FlagDialog({required this.contentType, required this.contentId});

  final ContentType contentType;
  final String contentId;

  @override
  State<_FlagDialog> createState() => _FlagDialogState();
}

class _FlagDialogState extends State<_FlagDialog> {
  IssueType? _selectedIssueType;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
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
            'Report an Issue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What type of issue?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: IssueType.values.map((type) {
              return ChoiceChip(
                label: Text(_issueTypeLabel(type)),
                selected: _selectedIssueType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedIssueType = type;
                    });
                  }
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.secondary,
                labelStyle: TextStyle(
                  color: _selectedIssueType == type
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Additional notes (optional)',
              hintText: 'Describe the issue...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedIssueType == null
                ? null
                : () => Navigator.pop(
                      context,
                      FlagSubmission(
                        contentType: widget.contentType,
                        contentId: widget.contentId,
                        issueType: _selectedIssueType!,
                        userNote: _noteController.text,
                      ),
                    ),
            child: const Text('Submit Report'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _issueTypeLabel(IssueType type) {
    switch (type) {
      case IssueType.typo:
        return 'Typo';
      case IssueType.factual:
        return 'Factual Error';
      case IssueType.unclear:
        return 'Unclear';
    }
  }
}