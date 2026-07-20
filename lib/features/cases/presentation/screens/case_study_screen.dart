import 'package:drift/drift.dart' show InsertMode, OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/app_database.dart';

class CaseStudyScreen extends ConsumerStatefulWidget {
  const CaseStudyScreen({super.key, required this.caseId});

  final String caseId;

  @override
  ConsumerState<CaseStudyScreen> createState() => _CaseStudyScreenState();
}

class _CaseStudyScreenState extends ConsumerState<CaseStudyScreen> {
  int _currentStage = 1;
  int _correctDecisions = 0;
  int _totalDecisions = 0;
  bool _isCompleted = false;
  int? _confidence;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final db = ref.read(databaseProvider);
    final progress = await (db.select(db.caseProgress)
          ..where((t) => t.caseId.equals(widget.caseId)))
        .get();
    if (progress.isNotEmpty) {
      final p = progress.first;
      if (!mounted) return;
      setState(() {
        _currentStage = p.currentStage;
        _correctDecisions = p.correctDecisions;
        _totalDecisions = p.totalDecisions;
        _confidence = p.confidenceLevel;
      });
    }
  }

  Future<void> _saveProgress() async {
    final db = ref.read(databaseProvider);
    await db.into(db.caseProgress).insert(
      CaseProgressCompanion.insert(
        caseId: widget.caseId,
        startedAt: DateTime.now(),
        currentStage: Value(_currentStage),
        correctDecisions: Value(_correctDecisions),
        totalDecisions: Value(_totalDecisions),
        confidenceLevel: Value(_confidence),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> _handleOptionSelected(CaseOption option, bool isCorrect) async {
    if (!mounted) return;
    setState(() {
      _totalDecisions++;
      if (isCorrect) _correctDecisions++;
    });

    final result = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? 'Correct!' : 'Review'),
        content: Text(option.feedback),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, isCorrect),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (result == true) {
      final db = ref.read(databaseProvider);
      final stages = await (db.select(db.caseStages)
            ..where((t) => t.caseId.equals(widget.caseId))
            ..orderBy([(t) => OrderingTerm.asc(t.stageNumber)]))
          .get();
      if (!mounted) return;
      if (_currentStage >= stages.length) {
        setState(() => _isCompleted = true);
      } else {
        setState(() => _currentStage++);
      }
    }
    await _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Case'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _isCompleted
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.secondary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Case Complete!',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_correctDecisions/$_totalDecisions correct decisions',
                        style:
                            TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'How confident were you with this case?',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildConfidenceChip(theme, 1, 'Guessing'),
                          _buildConfidenceChip(theme, 2, 'Somewhat Sure'),
                          _buildConfidenceChip(theme, 3, 'Confident'),
                        ],
                      ),
                    ],
                  ),
                )
          : FutureBuilder<List<CaseStage>>(
              future: _loadStageData(db),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stageData = snapshot.data!;
                final currentStageData = stageData.where((s) => s.stageNumber == _currentStage).firstOrNull;
                if (currentStageData == null) {
                  return const Center(child: Text('Case not available'));
                }
                return _buildStageContent(currentStageData, db);
              },
            ),
    );
  }

  Future<List<CaseStage>> _loadStageData(AppDatabase db) async {
    final rows = await (db.select(db.caseStages)
          ..where((t) => t.caseId.equals(widget.caseId))
          ..orderBy([(t) => OrderingTerm.asc(t.stageNumber)]))
        .get();
    return rows;
  }

  Widget _buildStageContent(CaseStage stage, AppDatabase db) {
    final theme = Theme.of(context);
    return FutureBuilder<List<CaseOption>>(
      future: _loadOptionsForStage(db, stage.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stage ${stage.stageNumber}',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                stage.content,
                style: TextStyle(color: theme.colorScheme.onSurface, height: 1.5),
              ),
              const SizedBox(height: 24),
              ...snapshot.data!.map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _handleOptionSelected(opt, opt.isCorrect),
                      child: Text(opt.optionText),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<List<CaseOption>> _loadOptionsForStage(AppDatabase db, int stageId) async {
    final rows = await (db.select(db.caseOptions)
          ..where((t) => t.stageId.equals(stageId)))
        .get();
    return rows;
  }

  Widget _buildConfidenceChip(ThemeData theme, int level, String label) {
    final isSelected = _confidence == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isSelected
          ? null
          : (selected) {
              if (selected && mounted) {
                setState(() => _confidence = level);
                _saveProgress();
              }
            },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.secondary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}