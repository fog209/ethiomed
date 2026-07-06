import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/app_database.dart';
import 'screens/case_study_screen.dart';

class ClinicalCasesScreen extends ConsumerWidget {
  const ClinicalCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Cases'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: StreamBuilder<List<ClinicalCase>>(
        stream: (db.select(db.clinicalCases)..orderBy([(c) => OrderingTerm.asc(c.title)])).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final cases = snapshot.data ?? const [];
          if (cases.isEmpty) {
            return Center(
              child: Text(
                'No clinical cases available yet.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }
          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(c.title, style: TextStyle(color: theme.colorScheme.onSurface)),
                  subtitle: Text(c.specialty, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CaseStudyScreen(caseId: c.id)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}