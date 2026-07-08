import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class ArticleNotesSection extends ConsumerStatefulWidget {
  const ArticleNotesSection({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<ArticleNotesSection> createState() =>
      _ArticleNotesSectionState();
}

class _ArticleNotesSectionState extends ConsumerState<ArticleNotesSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = ref.read(databaseProvider);
    _focusNode.addListener(_onFocusChange);
    _load();
  }

  Future<void> _load() async {
    final note = await _db.getNoteForArticle(widget.articleId);
    if (!mounted) return;
    _controller.text = note?.noteText ?? '';
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _saveNow();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _saveNow);
  }

  Future<void> _saveNow() async {
    if (!mounted) return;
    await _db.saveArticleNote(widget.articleId, _controller.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          maxLines: null,
          minLines: 4,
          decoration: InputDecoration(
            hintText: 'Add a private note for this article...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Saved privately on this device. Visible only to you.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
