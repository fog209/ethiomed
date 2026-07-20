import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Articles'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Saved'),
              Tab(text: 'Learnt'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSavedList(context, db),
            _buildLearntList(context, db),
            _buildNotesList(context, db),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList(BuildContext context, AppDatabase db) {
    final bookmarksStream = db.select(db.articles).join([
      innerJoin(db.bookmarks, db.bookmarks.articleId.equalsExp(db.articles.id)),
    ]).watch();

    return _buildArticleList(
      context: context,
      db: db,
      stream: bookmarksStream,
      icon: Icons.bookmark,
      emptyIcon: Icons.bookmark_border,
      emptyTitle: 'No bookmarks yet',
      emptySubtitle: 'Tap the bookmark icon on any article to save it',
    );
  }

  Widget _buildLearntList(BuildContext context, AppDatabase db) {
    final learntStream = db.select(db.articles).join([
      innerJoin(db.learnt, db.learnt.articleId.equalsExp(db.articles.id)),
    ]).watch();

    return _buildArticleList(
      context: context,
      db: db,
      stream: learntStream,
      icon: Icons.school,
      emptyIcon: Icons.school_outlined,
      emptyTitle: 'Nothing marked as learnt',
      emptySubtitle: 'Tap the learnt icon on any article to track it',
    );
  }

  Widget _buildArticleList({
    required BuildContext context,
    required AppDatabase db,
    required Stream<List<TypedResult>> stream,
    required IconData icon,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    return StreamBuilder<List<TypedResult>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.amber, size: 48),
                SizedBox(height: 8),
                Text(
                  'Could not load articles.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final row = results[index];
            final article = row.readTable(db.articles);

            return ListTile(
              leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
              title: Text(
                article.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onTap: () => context.push('/article-detail', extra: article),
            );
          },
        );
      },
    );
  }

  Widget _buildNotesList(BuildContext context, AppDatabase db) {
    final notesStream = db.watchAllNotes();

    return StreamBuilder<List<NoteWithArticle>>(
      stream: notesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.amber, size: 48),
                SizedBox(height: 8),
                Text(
                  'Could not load notes.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return const EmptyState(
            icon: Icons.note_alt_outlined,
            title: 'No notes yet',
            subtitle:
                'Open any article and tap "My Notes" to start jotting.',
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final title = note.articleTitle ?? 'Unknown article';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.noteText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Go to Article'),
                        onPressed: () => context.push(
                          '/article-detail',
                          extra: <String, String?>{'id': note.articleId},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
