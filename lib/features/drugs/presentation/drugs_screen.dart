import 'package:flutter/material.dart';

/// Empty-state shell for the upcoming Drugs feature.
///
/// Nav entry + placeholder only. No content loading, no schema, no article
/// wiring — the drug-content format/loading strategy is undecided (owner is
/// authoring drug content separately). Do not add a `drugs` category to
/// [AppConfig]/[TaxonomyConfig] or wire this into the article system.
class DrugsScreen extends StatelessWidget {
  const DrugsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drugs'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medication,
                size: 72,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Drugs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drug reference content is being prepared.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
