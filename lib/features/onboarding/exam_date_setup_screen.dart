import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/planner/study_planner_provider.dart';

class ExamDateSetupScreen extends ConsumerStatefulWidget {
  const ExamDateSetupScreen({super.key});

  @override
  ConsumerState<ExamDateSetupScreen> createState() => _ExamDateSetupScreenState();
}

class _ExamDateSetupScreenState extends ConsumerState<ExamDateSetupScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadExamDate();
  }

  Future<void> _loadExamDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('target_exam_date');
    if (millis != null) {
      setState(() {
        _selectedDate = DateTime.fromMillisecondsSinceEpoch(millis);
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year + 1, 7, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      helpText: 'Select your COC exam date',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedDate != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'target_exam_date',
        _selectedDate!.millisecondsSinceEpoch,
      );
      ref.read(examDateProvider.notifier).state = _selectedDate;
    }
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Exam Date'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COC Exam Countdown',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Set your target exam date to get a personalized study plan.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Select Exam Date'
                    : 'Exam: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
              ),
              onPressed: _selectDate,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                onPressed: _saveAndContinue,
                child: const Text('Save and Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}