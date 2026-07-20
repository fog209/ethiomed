import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the Feature 1 Notes-tab query: joins the article title, orders by
/// most-recently-edited first, and surfaces orphan notes (article deleted
/// locally) instead of silently dropping them.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedArticle(String id, String title) async {
    await db
        .into(db.articles)
        .insert(
          ArticlesCompanion.insert(
            id: id,
            title: title,
            category: const Value('Cardiology'),
          ),
        );
  }

  test('watchAllNotes orders by updatedAt desc and joins article title', () async {
    await seedArticle('a1', 'Article One');
    await seedArticle('a2', 'Article Two');

    // Insert with explicit, distinct timestamps so ordering is deterministic.
    await db.into(db.articleNotes).insert(
          ArticleNotesCompanion.insert(
            articleId: 'a1',
            noteText: const Value('first note'),
            updatedAt: Value(DateTime.utc(2026, 1, 1, 10, 0, 0)),
          ),
        );
    await db.into(db.articleNotes).insert(
          ArticleNotesCompanion.insert(
            articleId: 'a2',
            noteText: const Value('second note'),
            updatedAt: Value(DateTime.utc(2026, 1, 1, 11, 0, 0)),
          ),
        );

    final notes = await db.watchAllNotes().first;

    expect(notes.length, 2);
    // Most-recently-edited first.
    expect(notes.first.articleId, 'a2');
    expect(notes.first.articleTitle, 'Article Two');
    expect(notes.last.articleId, 'a1');
    expect(notes.last.articleTitle, 'Article One');
  });

  test('watchAllNotes returns orphan notes with null title', () async {
    // Note for an article that was never seeded locally.
    await db.saveArticleNote('missing', 'orphan note');

    final notes = await db.watchAllNotes().first;

    expect(notes.length, 1);
    expect(notes.first.articleId, 'missing');
    expect(notes.first.articleTitle, isNull);
    expect(notes.first.noteText, 'orphan note');
  });

  test('watchAllNotes empty when no notes saved', () async {
    final notes = await db.watchAllNotes().first;
    expect(notes, isEmpty);
  });
}
