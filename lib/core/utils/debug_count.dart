import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';

/// Utility for gathering data counts from local database.
/// Run on app start in debug mode to verify data integrity.
Future<void> logDatabaseCounts() async {
  final db = AppDatabase();
  
  try {
    final articleCount = await (db.select(db.articles)..limit(10000)).get().then((list) => list.length);
    final questionCount = await (db.select(db.quizTable)..limit(10000)).get().then((list) => list.length);
    final flashcardCount = await (db.select(db.flashcardTable)..limit(10000)).get().then((list) => list.length);
    
    if (!kReleaseMode) {
      debugPrint('=== DATABASE COUNTS ===');
      debugPrint('Articles: $articleCount');
      debugPrint('Questions: $questionCount');
      debugPrint('Flashcards: $flashcardCount');
      debugPrint('======================');
    }
  } finally {
    await db.close();
  }
}