import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final articleCommentsProvider = FutureProvider.family<List<ArticleComment>, String>((ref, articleId) async {
  final response = await Supabase.instance.client
      .from('article_comments')
      .select()
      .eq('articleId', articleId)
      .order('createdAt', ascending: true)
      .then((value) => value as List<dynamic>);
  return response
      .map((json) => ArticleComment.fromJson(json as Map<String, dynamic>))
      .toList(growable: false);
});

class ArticleComment {
  ArticleComment({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.userName,
    required this.commentBody,
    required this.createdAt,
  });

  final String id;
  final String articleId;
  final String userId;
  final String userName;
  final String commentBody;
  final DateTime createdAt;

  factory ArticleComment.fromJson(Map<String, dynamic> json) => ArticleComment(
        id: json['id'] as String,
        articleId: json['articleId'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String? ?? 'Anonymous',
        commentBody: json['commentBody'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

final _commentControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

Future<void> postComment(String articleId, String comment) async {
  final user = Supabase.instance.client.auth.currentUser;
  await Supabase.instance.client.from('article_comments').insert({
    'articleId': articleId,
    'userId': user?.id ?? '',
    'userName': user?.email ?? 'Anonymous',
    'commentBody': comment,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

class DiscussionSection extends ConsumerWidget {
  const DiscussionSection({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final commentsAsync = ref.watch(articleCommentsProvider(articleId));
    final controller = ref.watch(_commentControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discussion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ask a question or share insights...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            suffixIcon: IconButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  await postComment(articleId, text);
                  controller.clear();
                  ref.invalidate(articleCommentsProvider(articleId));
                }
              },
              icon: Icon(Icons.send, color: theme.colorScheme.secondary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        commentsAsync.when(
          data: (comments) => comments.isEmpty
              ? Text(
                  'No comments yet. Be the first to start the discussion!',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              : Column(
                  children: comments.map((c) => _CommentTile(comment: c)).toList(growable: false),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading comments: $e'),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final ArticleComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              comment.commentBody,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(comment.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}