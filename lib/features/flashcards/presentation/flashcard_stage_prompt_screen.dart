import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../flashcard_track_provider.dart';
import 'flashcard_review_screen.dart';

/// Warm, identity-framed copy for the study-stage choices. These are NOT
/// described as "content filters" — they're about where the student is in
/// their training.
const Map<String, String> _stageTitles = {
  flashcardTrackPreclinical: 'Preclinical years',
  flashcardTrackClinical: 'Clinical rotations & internship',
  flashcardTrackBoth: 'Show me everything',
};

const Map<String, String> _stageSubtitles = {
  flashcardTrackPreclinical: 'Before wards — basics, pathology, pharm',
  flashcardTrackClinical: 'On the floor — wards, cases, exams',
  flashcardTrackBoth: 'Mix of both, no narrowing',
};

/// Shared study-stage picker used by both the first-run prompt and the
/// Settings "Change study stage" entry. Selecting a stage persists the choice
/// via [flashcardTrackProvider] and invokes [onChosen].
class StudyStageChooser extends ConsumerWidget {
  const StudyStageChooser({super.key, required this.onChosen});

  final void Function(String track) onChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final order = [
      flashcardTrackPreclinical,
      flashcardTrackClinical,
      flashcardTrackBoth,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final track in order)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => onChosen(track),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stageTitles[track]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stageSubtitles[track]!,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSecondary.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// First-time personalization moment shown before the Flashcards review
/// screen when the study stage has never been chosen. Reads like the app
/// getting to know the student, not a technical filter.
class FlashcardStagePromptScreen extends ConsumerWidget {
  const FlashcardStagePromptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.school,
                size: 56,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Where are you in your studies?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We'll tailor your flashcards to the stage you're at. "
                "You can change this anytime as you progress.",
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              StudyStageChooser(
                onChosen: (track) async {
                  await ref
                      .read(flashcardTrackProvider.notifier)
                      .setTrack(track);
                  if (!context.mounted) return;
                  context.go('/flashcards');
                },
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Routes the user to the study-stage prompt on first entry, or straight to
/// the review screen once a stage has been chosen. Avoids a flash of the
/// prompt for returning users while the preference loads from storage.
class FlashcardsGate extends ConsumerWidget {
  const FlashcardsGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(flashcardTrackProvider);
    final notifier = ref.read(flashcardTrackProvider.notifier);
    if (notifier.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!notifier.hasChosen) {
      return const FlashcardStagePromptScreen();
    }
    return const FlashcardReviewScreen();
  }
}
