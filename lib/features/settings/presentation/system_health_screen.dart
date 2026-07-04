import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/security_service.dart';

class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: FutureBuilder<SystemHealthData>(
        future: _gatherSystemHealth(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading system health: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('Sync Audit', theme),
              _buildInfoRow('Last Question Sync', data.lastQuestionSync, theme),
              _buildInfoRow('Last Flashcard Sync', data.lastFlashcardSync, theme),
              const SizedBox(height: 24),
              _buildSection('Data Grounding', theme),
              _buildInfoRow('Total Articles', data.articleCount.toString(), theme),
              _buildInfoRow('Total Questions', data.questionCount.toString(), theme),
              _buildInfoRow('Total Flashcards', data.flashcardCount.toString(), theme),
              _buildInfoRow('Due Flashcards', data.dueFlashcardCount.toString(), theme),
              const SizedBox(height: 24),
              _buildSection('Security Audit', theme),
              _buildInfoRow('APK Signature Hash', data.signatureHash, theme),
              _buildInfoRow(
                'Verification Status',
                data.signatureStatus,
                theme,
                isWarning: !data.isSignatureValid,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<SystemHealthData> _gatherSystemHealth() async {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase();
    final security = SecurityService();

    try {
      final lastQuestionSync =
          prefs.getString('last_question_sync') ?? 'Never synced';
      final lastFlashcardSync =
          prefs.getString('last_flashcard_sync') ?? 'Never synced';

      final articleCount = await (db.select(db.articles)..limit(10000)).get().then((l) => l.length);
      final questionCount = await (db.select(db.quizTable)..limit(10000)).get().then((l) => l.length);
      final flashcardCount = await (db.select(db.flashcardTable)..limit(10000)).get().then((l) => l.length);

      final dueFlashcards = await db
          .customSelect(
            'SELECT COUNT(*) AS count FROM flashcard_table WHERE next_due_at IS NULL OR next_due_at <= ?',
            variables: [Variable(DateTime.now().toIso8601String())],
          )
          .get();
      final dueCount = dueFlashcards.isEmpty
          ? 0
          : dueFlashcards.first.read<int>('count');

      final signatureValid = security.isSyncAllowed;
      final signatureHash = signatureValid
          ? 'MATCHES EXPECTED (valid)'
          : 'VERIFY IN PRODUCTION';

      return SystemHealthData(
        lastQuestionSync: lastQuestionSync,
        lastFlashcardSync: lastFlashcardSync,
        articleCount: articleCount,
        questionCount: questionCount,
        flashcardCount: flashcardCount,
        dueFlashcardCount: dueCount,
        signatureHash: signatureHash,
        signatureStatus: signatureValid ? 'PASSED' : 'FAILED',
        isSignatureValid: signatureValid,
      );
    } finally {
      await db.close();
    }
  }

  Widget _buildSection(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: TextStyle(
              color: isWarning
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SystemHealthData {
  SystemHealthData({
    required this.lastQuestionSync,
    required this.lastFlashcardSync,
    required this.articleCount,
    required this.questionCount,
    required this.flashcardCount,
    required this.dueFlashcardCount,
    required this.signatureHash,
    required this.signatureStatus,
    required this.isSignatureValid,
  });

  final String lastQuestionSync;
  final String lastFlashcardSync;
  final int articleCount;
  final int questionCount;
  final int flashcardCount;
  final int dueFlashcardCount;
  final String signatureHash;
  final String signatureStatus;
  final bool isSignatureValid;
}