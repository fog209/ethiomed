import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'flashcard_review_service.dart';

final flashcardDueProvider =
    FutureProvider.family<List<FlashcardEntity>, String?>((ref, deckName) {
  final service = ref.watch(flashcardReviewServiceProvider);
  return service.getDueFlashcards(deckName);
});