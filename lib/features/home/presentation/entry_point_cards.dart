import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/articles/data/daily_pearl.dart';
import '../../../features/flashcards/flashcard_provider.dart';
import '../../../features/flashcards/flashcard_track_provider.dart';

/// Reusable "quick access" entry cards shown on the Home tab.
/// Styling mirrors the legacy Library dashboard cards.

/// In-app "Daily Pearl" card: one sampled pearl from local article sections,
/// stable for the whole calendar day. Tapping opens the source article
/// scrolled to the pearl's section. Renders nothing when no pearl is
/// available (graceful empty state — no blank card).
class DailyPearlCard extends ConsumerWidget {
  const DailyPearlCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pearlAsync = ref.watch(dailyPearlProvider);

    return pearlAsync.when(
      data: (pearl) {
        if (pearl == null) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: theme.colorScheme.secondaryContainer,
          child: InkWell(
            onTap: () => context.push(
              '/article-detail',
              extra: <String, String?>{
                'id': pearl.articleId,
                'section': pearl.sectionKey,
              },
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.secondary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Pearl',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pearl.preview,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From: ${pearl.articleTitle}',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class CalculatorsEntryCard extends ConsumerWidget {
  const CalculatorsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EntryCard(
      icon: Icons.calculate,
      title: 'Clinical Calculators',
      subtitle: 'Quick medical calculations',
      onTap: () => context.push('/calculators'),
    );
  }
}

class CasesEntryCard extends ConsumerWidget {
  const CasesEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EntryCard(
      icon: Icons.medical_services,
      title: 'Clinical Cases',
      subtitle: 'Case-based learning scenarios',
      onTap: () => context.push('/cases'),
    );
  }
}

class ExamModeEntryCard extends ConsumerWidget {
  const ExamModeEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EntryCard(
      icon: Icons.assignment_turned_in,
      title: 'COC Exam Mode',
      subtitle: '200 questions · Timed · COC-weighted',
      onTap: () => context.push('/exam-setup'),
    );
  }
}

class ProgressEntryCard extends ConsumerWidget {
  const ProgressEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EntryCard(
      icon: Icons.bar_chart,
      title: 'Progress',
      subtitle: 'Streaks, heatmap & category stats',
      onTap: () => context.push('/progress'),
    );
  }
}

class DrugsEntryCard extends ConsumerWidget {
  const DrugsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EntryCard(
      icon: Icons.medication,
      title: 'Drugs',
      subtitle: 'Coming soon',
      onTap: () => context.push('/drugs'),
    );
  }
}

class FlashcardsEntryCard extends ConsumerWidget {
  const FlashcardsEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = ref.watch(flashcardTrackProvider);
    final dueCardsAsync = ref.watch(
      flashcardDueProvider((deckName: null, track: track)),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => context.push('/flashcards'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.style,
                color: theme.colorScheme.secondary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flashcards',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    dueCardsAsync.when(
                      data: (cards) => Text(
                        cards.isEmpty
                            ? 'Anki-style spaced repetition'
                            : '${cards.length} card${cards.length != 1 ? 's' : ''} due',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 14,
                        ),
                      ),
                      loading: () => Text(
                        'Loading...',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 14,
                        ),
                      ),
                      error: (_, _) => Text(
                        'Flashcards unavailable',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSecondaryContainer,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.secondary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSecondaryContainer,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
