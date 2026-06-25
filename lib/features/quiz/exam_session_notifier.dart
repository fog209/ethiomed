import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class ExamSessionState {
  const ExamSessionState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.startTime,
    required this.timeRemaining,
    required this.isComplete,
    required this.isActive,
  });

  final List<QuizQuestionEntity> questions; // up to 200
  final int currentIndex; // 0–199
  final Map<int, String> answers; // index → 'a'|'b'|'c'|'d'
  final DateTime startTime;
  final Duration timeRemaining; // starts 3:00:00, counts down
  final bool isComplete;
  final bool isActive;

  ExamSessionState copyWith({
    List<QuizQuestionEntity>? questions,
    int? currentIndex,
    Map<int, String>? answers,
    DateTime? startTime,
    Duration? timeRemaining,
    bool? isComplete,
    bool? isActive,
  }) {
    return ExamSessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      startTime: startTime ?? this.startTime,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isComplete: isComplete ?? this.isComplete,
      isActive: isActive ?? this.isActive,
    );
  }
}

final examSessionProvider =
    StateNotifierProvider<ExamSessionNotifier, ExamSessionState>((ref) {
      final db = ref.watch(databaseProvider);
      return ExamSessionNotifier(database: db);
    });

class ExamSessionNotifier extends StateNotifier<ExamSessionState> {
  ExamSessionNotifier({required AppDatabase database})
    : _db = database,
      super(
        ExamSessionState(
          questions: const [],
          currentIndex: 0,
          answers: const {},
          startTime: DateTime.fromMillisecondsSinceEpoch(0),
          timeRemaining: const Duration(hours: 3),
          isComplete: false,
          isActive: false,
        ),
      );

  final AppDatabase _db;
  Timer? _timer;

  static const _examDuration = Duration(hours: 3);

  bool get _hasStarted => state.isActive && state.questions.isNotEmpty;

  static const Map<String, int> _defaultDomainWeights = {
    'Internal Medicine': 30,
    'Infectious Diseases': 24,
    'Pediatrics': 22,
    'OB/GYN': 20,
    'General Surgery': 18,
    'Pulmonology': 14,
    'Psychiatry': 12,
    'Endocrinology': 10,
    'Gastroenterology': 10,
    'Ophthalmology': 5,
    'ENT': 5,
    'Dermatology': 8,
    'Hematology': 8,
  };

  Future<int> _domainCount(String category) async {
    final rows = await _db
        .customSelect(
          'SELECT COUNT(*) AS count FROM quiz_table WHERE category = ?',
          variables: [Variable<String>(category)],
        )
        .get();

    return rows.isEmpty ? 0 : rows.single.read<int>('count');
  }

  QuizQuestionEntity _quizTableDataFromRow(QueryRow row) {
    return QuizQuestionEntity(
      id: row.read<int>('id'),
      remoteId: row.read<String>('remote_id'),
      articleId: row.read<String>('article_id'),
      stem: row.read<String>('stem'),
      optionA: row.read<String>('option_a'),
      optionB: row.read<String>('option_b'),
      optionC: row.read<String>('option_c'),
      optionD: row.read<String>('option_d'),
      correctOption: row.read<String>('correct_option'),
      explanation: row.read<String>('explanation'),
      category: row.read<String>('category'),
      difficulty: row.read<String>('difficulty'),
      testedField: row.read<String>('tested_field'),
      wrongCount: row.read<int>('wrong_count'),
      lastAttemptedAt: row.read<DateTime?>('last_attempted_at'),
      srInterval: row.read<int?>('sr_interval'),
      repetitions: row.read<int?>('repetitions'),
      nextDueAt: row.read<DateTime?>('next_due_at'),
      easeFactor: row.read<double?>('ease_factor') ?? 2.5,
    );
  }

  Future<List<QuizQuestionEntity>> _selectWeighted200Questions({
    required Map<String, int> domainWeights,
  }) async {
    final random = Random();

    final selectedIds = <int>{};
    final selected = <QuizQuestionEntity>[];

    // For each domain, select up to weight, taking all if fewer exist.
    for (final entry in domainWeights.entries) {
      final category = entry.key;
      final weight = entry.value;

      final count = await _domainCount(category);
      final limit = min(count, weight);
      if (limit <= 0) continue;

      final rows = await _db
          .customSelect(
            '''
SELECT *
FROM quiz_table
WHERE category = ?
ORDER BY RANDOM()
LIMIT ?
''',
            variables: [Variable<String>(category), Variable<int>(limit)],
          )
          .get();

      final domainQuestions = rows
          .map(_quizTableDataFromRow)
          .toList(growable: false);

      for (final q in domainQuestions) {
        selectedIds.add(q.id);
      }
      selected.addAll(domainQuestions);
    }

    // Fill remainder to 200 with random questions excluding already-selected IDs.
    if (selectedIds.length < 200) {
      final remaining = 200 - selectedIds.length;

      if (selectedIds.isEmpty) {
        final rows = await _db
            .customSelect(
              '''
SELECT *
FROM quiz_table
ORDER BY RANDOM()
LIMIT ?
''',
              variables: [Variable<int>(remaining)],
            )
            .get();
        selected.addAll(rows.map(_quizTableDataFromRow));
      } else {
        final ids = selectedIds.toList(growable: false);
        final placeholders = List<String>.filled(ids.length, '?').join(',');
        final vars = <Variable>[
          for (final id in ids) Variable<int>(id),
          Variable<int>(remaining),
        ];

        final rows = await _db.customSelect('''
SELECT *
FROM quiz_table
WHERE id NOT IN ($placeholders)
ORDER BY RANDOM()
LIMIT ?
''', variables: vars).get();

        selected.addAll(rows.map(_quizTableDataFromRow));
      }
    }

    selected.shuffle(random);
    if (selected.length > 200) return selected.sublist(0, 200);
    return selected;
  }

  Future<void> startExam() async {
    _timer?.cancel();
    _timer = null;

    final questions = await _selectWeighted200Questions(
      domainWeights: _defaultDomainWeights,
    );

    state = state.copyWith(
      questions: questions,
      currentIndex: 0,
      answers: const {},
      startTime: DateTime.now(),
      timeRemaining: _examDuration,
      isComplete: false,
      isActive: true,
    );
  }

  void answerQuestion(String optionLetter) {
    if (!_hasStarted) return;

    final idx = state.currentIndex;
    final answers = Map<int, String>.from(state.answers);
    answers[idx] = optionLetter;

    state = state.copyWith(answers: answers);
  }

  void previousQuestion() {
    if (!_hasStarted) return;

    state = state.copyWith(currentIndex: max(0, state.currentIndex - 1));
  }

  void nextQuestion() {
    if (!_hasStarted) return;

    state = state.copyWith(
      currentIndex: min(state.questions.length - 1, state.currentIndex + 1),
    );
  }

  void submitExam() {
    if (!_hasStarted) return;

    _timer?.cancel();
    _timer = null;

    state = state.copyWith(isComplete: true, isActive: false);
  }

  void tickTimer() {
    if (!state.isActive || state.isComplete) return;

    final next = state.timeRemaining - const Duration(seconds: 1);
    if (next <= Duration.zero) {
      state = state.copyWith(timeRemaining: Duration.zero);
      submitExam();
      return;
    }

    state = state.copyWith(timeRemaining: next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
