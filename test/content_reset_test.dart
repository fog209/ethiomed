import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:ethiomed/features/settings/data/content_reset_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Safety-critical: the panic button must clear ONLY the allowlisted content
/// tables and leave every user-generated / progress table intact.
void main() {
  late AppDatabase db;
  late ContentResetService service;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    service = ContentResetService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAllData() async {
    await db
        .into(db.articles)
        .insert(
          ArticlesCompanion.insert(
            id: 'a1',
            title: 'Article One',
            category: const Value('Cardiology'),
          ),
        );
    await db
        .into(db.sectionRegistry)
        .insert(
          SectionRegistryCompanion.insert(
            key: 'definition',
            label: 'Definition',
          ),
        );
    // User progress / generated data — must SURVIVE the reset.
    await db
        .into(db.articleNotes)
        .insert(
          ArticleNotesCompanion.insert(articleId: 'a1', noteText: const Value('my note')),
        );
    await db
        .into(db.bookmarks)
        .insert(BookmarksCompanion.insert(articleId: 'a1'));
    await db
        .into(db.learnt)
        .insert(LearntCompanion.insert(articleId: 'a1'));
    await db.into(db.flashcardTable).insert(
          FlashcardTableCompanion.insert(
            remoteId: const Value(1),
            deckName: 'Deck',
            frontText: 'Q',
            backText: 'A',
            // SM-2 state columns populated — must survive.
            interval: const Value(5),
            repetitions: const Value(2),
            nextDueAt: Value(DateTime.utc(2026, 8, 1)),
          ),
        );
    await db.into(db.quizTable).insert(
          QuizTableCompanion.insert(
            remoteId: 'q1',
            articleId: 'a1',
            stem: 'Stem?',
            optionA: 'A',
            optionB: 'B',
            optionC: 'C',
            optionD: 'D',
            correctOption: 'A',
            explanation: 'Because.',
            category: 'Cardiology',
          ),
        );
  }

  Future<int> countRows(String table) async {
    final rows = await db.customSelect('SELECT COUNT(*) AS c FROM "$table"').get();
    return rows.first.read<int>('c');
  }

  test('allowlist contains only articles and section_registry', () {
    expect(service.allowedTables, containsAll(<String>['articles', 'section_registry']));
    expect(service.allowedTables.length, 2);
  });

  test('reset clears content tables but preserves notes/saved/SM-2', () async {
    await seedAllData();

    // Pre-conditions.
    expect(await countRows('articles'), 1);
    expect(await countRows('section_registry'), 1);
    expect(await countRows('article_notes'), 1);
    expect(await countRows('bookmarks'), 1);
    expect(await countRows('learnt'), 1);
    expect(await countRows('flashcard_table'), 1);
    expect(await countRows('quiz_table'), 1);

    final result = await service.resetContentCache();
    expect(result.hasErrors, isFalse);
    expect(result.clearedTables, containsAll(<String>['articles', 'section_registry']));

    // Content tables wiped.
    expect(await countRows('articles'), 0);
    expect(await countRows('section_registry'), 0);

    // User data PRESERVED — this is the whole point of the allowlist.
    expect(await countRows('article_notes'), 1, reason: 'Notes must survive');
    expect(await countRows('bookmarks'), 1, reason: 'Saved must survive');
    expect(await countRows('learnt'), 1, reason: 'Learnt must survive');
    expect(await countRows('flashcard_table'), 1,
        reason: 'SM-2 flashcard state must survive');
    expect(await countRows('quiz_table'), 1,
        reason: 'SM-2 quiz state must survive');

    // Verify the SM-2 columns are genuinely intact (not just the row count).
    final fc = (await db.select(db.flashcardTable).get()).first;
    expect(fc.interval, 5);
    expect(fc.repetitions, 2);
    expect(fc.nextDueAt != null, isTrue);
  });

  test('reset never touches tables outside the allowlist even if called twice', () async {
    await seedAllData();
    await service.resetContentCache();
    await service.resetContentCache();

    expect(await countRows('article_notes'), 1);
    expect(await countRows('bookmarks'), 1);
    expect(await countRows('learnt'), 1);
    expect(await countRows('flashcard_table'), 1);
    expect(await countRows('quiz_table'), 1);
  });
}
