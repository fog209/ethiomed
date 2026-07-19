import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ethiomed/core/database/app_database.dart';
import 'package:ethiomed/features/search/data/spotlight_search_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SpotlightRepository repo;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = SpotlightRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedData() async {
    await db.into(db.articles).insert(
          ArticlesCompanion.insert(
            id: 'a1',
            title: 'Myocarditis article',
            category: const Value('Cardiology'),
            content: const Value('inflammation of the myocardium'),
          ),
        );
    await db.into(db.flashcardTable).insert(
          FlashcardTableCompanion.insert(
            remoteId: const Value(1),
            deckName: 'Cardio',
            frontText: 'Myocarditis cause?',
            backText: 'Viral',
          ),
        );
    await db.into(db.quizTable).insert(
          QuizTableCompanion.insert(
            remoteId: 'q1',
            articleId: 'a1',
            stem: 'Myocarditis most common cause?',
            optionA: 'A',
            optionB: 'B',
            optionC: 'C',
            optionD: 'D',
            correctOption: 'A',
            explanation: 'x',
            category: 'Cardiology',
          ),
        );
  }

  test('merges article, flashcard and question hits into one list', () async {
    await seedData();
    final results = await repo.searchAll('myocarditis');
    expect(results.length, 3);
    final kinds = results.map((r) => r.kind).toSet();
    expect(kinds, containsAll(<SpotlightKind>{
      SpotlightKind.article,
      SpotlightKind.flashcard,
      SpotlightKind.question,
    }));
  });

  test('empty query returns no results', () async {
    await seedData();
    expect(await repo.searchAll('   '), isEmpty);
  });

  test('no match returns empty across all three content types', () async {
    await seedData();
    expect(await repo.searchAll('zzz_no_match_zzz'), isEmpty);
  });
}
