import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'flashcard_review_service.dart';

/// Query args for the due-flashcards family: an optional deck plus an
/// optional track filter. Using a record keeps the original single deckName
/// semantics while letting the track preference narrow results.
typedef FlashcardDueArgs = ({String? deckName, String? track});

final flashcardDueProvider =
    FutureProvider.family<List<FlashcardEntity>, FlashcardDueArgs>(
  (ref, args) {
    final service = ref.watch(flashcardReviewServiceProvider);
    final track = (args.track == null || args.track == 'both')
        ? null
        : args.track;
    return service.getDueFlashcards(args.deckName, track: track);
  },
);
