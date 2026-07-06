import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

typedef ContentCounts = ({int articles, int questions, int flashcards, int cases});

final contentCountProvider = FutureProvider<ContentCounts>((ref) async {
  final db = ref.watch(databaseProvider);

  final articleCount = await db
      .customSelect('SELECT COUNT(*) AS count FROM articles')
      .get()
      .then((r) => r.isNotEmpty ? r.first.read<int>('count') : 0);

  final questionCount = await db
      .customSelect('SELECT COUNT(*) AS count FROM quiz_table')
      .get()
      .then((r) => r.isNotEmpty ? r.first.read<int>('count') : 0);

  final flashcardCount = await db
      .customSelect('SELECT COUNT(*) AS count FROM flashcard_table')
      .get()
      .then((r) => r.isNotEmpty ? r.first.read<int>('count') : 0);

  final caseCount = await db
      .customSelect('SELECT COUNT(*) AS count FROM clinical_cases')
      .get()
      .then((r) => r.isNotEmpty ? r.first.read<int>('count') : 0);

  return (
    articles: articleCount,
    questions: questionCount,
    flashcards: flashcardCount,
    cases: caseCount,
  );
});