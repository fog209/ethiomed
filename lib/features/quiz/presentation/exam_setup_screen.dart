import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../exam_session_notifier.dart';
import '../quiz_repository.dart';

final customQuizConfigProvider = StateProvider<CustomQuizConfig?>((ref) => null);

typedef CustomQuizConfig = ({
  String? specialtyFilter,
  QuestionScope scope,
  int questionCount,
});

class ExamSetupScreen extends ConsumerStatefulWidget {
  const ExamSetupScreen({super.key});

  @override
  ConsumerState<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends ConsumerState<ExamSetupScreen> {
  int _questionCount = 50;
  String? _specialtyFilter;
  QuestionScope _scope = QuestionScope.all;
  bool _useTimer = true;
  late final TextEditingController _customCountController;

  static const _questionOptions = [10, 25, 50];

  @override
  void initState() {
    super.initState();
    _customCountController = TextEditingController();
  }

  @override
  void dispose() {
    _customCountController.dispose();
    super.dispose();
  }

  String _scopeLabel(QuestionScope scope) {
    switch (scope) {
      case QuestionScope.all:
        return 'All';
      case QuestionScope.newOnly:
        return 'New Only';
      case QuestionScope.incorrectOnly:
        return 'Incorrect Only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('COC Exam Setup'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Number of Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _questionOptions.map((count) {
                final isSelected = _questionCount == count;
                return ChoiceChip(
                  label: Text('$count'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _questionCount = count;
                      });
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
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Specialty Filter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _specialtyFilter,
              hint: const Text('All Specialties'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Specialties')),
                ...AppConfig.clinicalCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['name'] as String,
                    child: Text(cat['name'] as String),
                  );
                }),
                ...AppConfig.preclinicalCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['name'] as String,
                    child: Text(cat['name'] as String),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _specialtyFilter = value;
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Timed Mode'),
              subtitle: Text(_useTimer
                  ? '${_questionCount * 90} seconds total'
                  : 'No time limit'),
              value: _useTimer,
              onChanged: (value) {
                setState(() {
                  _useTimer = value;
                });
              },
              activeTrackColor: theme.colorScheme.secondary,
              activeThumbColor: theme.colorScheme.onSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Question Scope',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: QuestionScope.values.map((scope) {
                final isSelected = _scope == scope;
                return ChoiceChip(
                  label: Text(_scopeLabel(scope)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _scope = scope;
                      });
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
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Custom Question Count',
                hintText: 'Enter a number (optional)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                final count = int.tryParse(value);
                if (count != null && count > 0) {
                  setState(() {
                    _questionCount = count;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_questionCount ${_scopeLabel(_scope).toLowerCase()} questions${_specialtyFilter != null ? " in $_specialtyFilter" : ""}',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                onPressed: _startExam,
                child: const Text('Start Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startExam() async {
    final config = (
      specialtyFilter: _specialtyFilter,
      scope: _scope,
      questionCount: _questionCount,
    );
    ref.read(customQuizConfigProvider.notifier).state = config;

    final notifier = ref.read(examSessionProvider.notifier);
    await notifier.startCustomQuiz(
      questionCount: config.questionCount,
      specialtyFilter: config.specialtyFilter,
      scope: config.scope,
      useTimer: _useTimer,
    );
    if (!mounted) return;
    context.go('/exam');
  }
}