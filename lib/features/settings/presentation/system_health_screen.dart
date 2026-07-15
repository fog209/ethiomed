import 'package:drift/drift.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Export Diagnostic Log'),
                onPressed: () => _exportDiagnosticLog(data, context),
              ),
              const SizedBox(height: 16),
              if (kDebugMode)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                  onPressed: () {
                    FirebaseCrashlytics.instance.crash();
                  },
                  child: const Text('Simulate Crash (Debug Only)'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _exportDiagnosticLog(SystemHealthData data, BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('=== WardReady Diagnostic Log ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('--- Database Counts ---');
    buffer.writeln('Articles: ${data.articleCount}');
    buffer.writeln('Questions: ${data.questionCount}');
    buffer.writeln('Flashcards: ${data.flashcardCount}');
    buffer.writeln('Due Flashcards: ${data.dueFlashcardCount}');
    buffer.writeln('');
    buffer.writeln('--- Sync Timestamps ---');
    buffer.writeln('Last Question Sync: ${data.lastQuestionSync}');
    buffer.writeln('Last Flashcard Sync: ${data.lastFlashcardSync}');
    buffer.writeln('');
    buffer.writeln('--- App Info ---');
    buffer.writeln('App Version: ${data.appVersion}');
    buffer.writeln('');
    buffer.writeln('--- Security Status ---');
    buffer.writeln('Signature Hash: ${data.signatureHash}');
    buffer.writeln('Verification Status: ${data.signatureStatus}');
    buffer.writeln('');
    buffer.writeln('--- Tamper Warnings ---');
    if (data.tamperWarnings.isEmpty) {
      buffer.writeln('No warnings recorded');
    } else {
      for (final warning in data.tamperWarnings) {
        buffer.writeln('- $warning');
      }
    }

    final log = buffer.toString();
    Clipboard.setData(ClipboardData(text: log));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostic log copied to clipboard')),
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
      final actualSignature = await security.getActualSignatureHash();
      final signatureHash = signatureValid
          ? 'MATCHES EXPECTED ($actualSignature)'
          : 'COPY THIS: $actualSignature';

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
        appVersion: '1.0.0',
        tamperWarnings: prefs.getStringList('tamper_warnings') ?? const [],
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
      {bool isWarning = false, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                value,
                style: TextStyle(
                  color: isWarning
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
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
    required this.appVersion,
    required this.tamperWarnings,
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
  final String appVersion;
  final List<String> tamperWarnings;
}