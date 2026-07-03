import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';
import '../flashcard_review_service.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({super.key, this.deckName});

  final String? deckName;

  @override
  ConsumerState<FlashcardReviewScreen> createState() =>
      _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  int currentIndex = 0;
  bool isRevealed = false;

  void _revealAnswer() {
    setState(() => isRevealed = true);
  }

  // Import flashcards from bundled asset.
  // To add a new deck: copy your exported JSON file to assets/flashcards/import.json
  // and rebuild the app. The JSON format is: [{"deck":"DeckName","front":"Question","back":"Answer"},...]
  Future<void> _importFlashcards() async {
    try {
      // Load the bundled import.json asset
      final jsonString = await rootBundle.loadString(
        'assets/flashcards/import.json',
      );
      final jsonList = jsonDecode(jsonString);

      if (jsonList is! List) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid JSON: expected array of cards.'),
            ),
          );
        }
        return;
      }

      final db = ref.read(databaseProvider);
      final cards = <({String deck, String front, String back})>[];
      for (final item in jsonList.whereType<Map<String, dynamic>>()) {
        cards.add((
          deck: item['deck']?.toString() ?? '',
          front: item['front']?.toString() ?? '',
          back: item['back']?.toString() ?? '',
        ));
      }

      final count = await importFlashcardsFromJson(db, cards);
      if (!mounted) return;

      ref.invalidate(_flashcardsProvider(widget.deckName));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$count flashcards imported.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  void _onRatingTap(FlashcardEntity card, int quality) async {
    final service = ref.read(flashcardReviewServiceProvider);
    await service.recordFlashcardReview(card.id, quality);

    if (!mounted) return;

    final allCards = ref.read(_flashcardsProvider(widget.deckName)).value ?? [];
    if (currentIndex >= allCards.length - 1) {
      if (mounted) {
        context.pop();
      }
    } else {
      setState(() {
        currentIndex++;
        isRevealed = false;
      });
    }
  }

  void _onGoBackTap() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncCards = ref.watch(_flashcardsProvider(widget.deckName));

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: _onGoBackTap),
        title: asyncCards.when(
          data: (cards) => cards.isEmpty
              ? const Text('Flashcards')
              : Text('${currentIndex + 1} of ${cards.length} due'),
          loading: () => const Text('Flashcards'),
          error: (_, _) => const Text('Flashcards'),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import flashcards',
            onPressed: _importFlashcards,
          ),
        ],
      ),
      body: SafeArea(
        child: asyncCards.when(
          data: (cards) => cards.isEmpty
              ? EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'All caught up!',
                  subtitle: 'No flashcards due for review.',
                  onAction: _onGoBackTap,
                  actionLabel: 'Go Back',
                )
              : _buildReviewCard(context, cards[currentIndex]),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, FlashcardEntity card) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: isRevealed ? null : _revealAnswer,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isRevealed ? card.backText : card.frontText,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (!isRevealed) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Tap to reveal answer',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isRevealed) ...[_buildRatingButtons(card)],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons(FlashcardEntity card) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildRatingButton(
              label: 'Again',
              quality: 0,
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              card: card,
            ),
            const SizedBox(width: 8),
            _buildRatingButton(
              label: 'Hard',
              quality: 2,
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              card: card,
            ),
            const SizedBox(width: 8),
            _buildRatingButton(
              label: 'Good',
              quality: 4,
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              card: card,
            ),
            const SizedBox(width: 8),
            _buildRatingButton(
              label: 'Easy',
              quality: 5,
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: const Color(0xFF1A237E),
              card: card,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingButton({
    required String label,
    required int quality,
    required Color backgroundColor,
    required Color foregroundColor,
    required FlashcardEntity card,
  }) {
    return Flexible(
      fit: FlexFit.loose,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          minimumSize: const Size(0, 48),
        ),
        onPressed: () => _onRatingTap(card, quality),
        child: Text(label),
      ),
    );
  }
}

final _flashcardsProvider =
    FutureProvider.family<List<FlashcardEntity>, String?>((ref, deckName) {
      final service = ref.watch(flashcardReviewServiceProvider);
      return service.getDueFlashcards(deckName);
    });
