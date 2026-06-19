import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';

enum QuizOption { a, b, c, d }

class QuizQuestionState {
  const QuizQuestionState({
    required this.question,
    this.selectedOption,
    this.showExplanation = false,
  });

  final QuizQuestionLocal question;
  final QuizOption? selectedOption;
  final bool showExplanation;

  QuizQuestionState copyWith({
    QuizQuestionLocal? question,
    QuizOption? selectedOption,
    bool? showExplanation,
  }) {
    return QuizQuestionState(
      question: question ?? this.question,
      selectedOption: selectedOption ?? this.selectedOption,
      showExplanation: showExplanation ?? this.showExplanation,
    );
  }
}

class QuizController extends StateNotifier<QuizQuestionState> {
  static const _questions = <QuizQuestionLocal>[
    QuizQuestionLocal(
      id: 1,
      articleId: null,
      stem: 'Which finding is most consistent with iron deficiency anemia?',
      optionA: 'Microcytic anemia with low ferritin',
      optionB: 'Macrocytic anemia with high B12',
      optionC: 'Normocytic anemia with normal ferritin',
      optionD: 'Hemolytic anemia with high reticulocytes',
      correctOption: 'A',
      explanation:
          'Iron deficiency typically causes microcytic anemia and reduced ferritin because ferritin reflects iron stores.',
      category: 'Hematology',
      difficulty: 'Easy',
    ),
    QuizQuestionLocal(
      id: 2,
      articleId: null,
      stem:
          'What is the first-line treatment for uncomplicated falciparum malaria in Ethiopia?',
      optionA: 'IV ceftriaxone',
      optionB: 'Artemether-lumefantrine (Coartem)',
      optionC: 'High-dose oral prednisolone',
      optionD: 'Metronidazole alone',
      correctOption: 'B',
      explanation:
          'Artemisinin-based combination therapy, especially Coartem, is the standard first-line treatment for uncomplicated falciparum malaria.',
      category: 'Infectious Diseases',
      difficulty: 'Easy',
    ),
    QuizQuestionLocal(
      id: 3,
      articleId: null,
      stem: 'Which symptom is a red flag in a child with fever?',
      optionA: 'Mild runny nose',
      optionB: 'Brief cough',
      optionC: 'Unable to drink or breastfeed',
      optionD: 'Passing urine normally',
      correctOption: 'C',
      explanation:
          'Inability to drink or breastfeed is a danger sign and requires urgent assessment.',
      category: 'Pediatrics',
      difficulty: 'Easy',
    ),
  ];

  QuizController() : super(QuizQuestionState(question: _questions.first));

  int get _index =>
      _questions.indexWhere((question) => question.id == state.question.id);

  void selectOption(QuizOption option) {
    state = state.copyWith(selectedOption: option, showExplanation: true);
  }

  void nextQuestion() {
    final nextIndex = _index + 1;
    if (nextIndex >= _questions.length) {
      return;
    }

    state = QuizQuestionState(question: _questions[nextIndex]);
  }

  bool get isLastQuestion => _index >= _questions.length - 1;
}

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizQuestionState>((ref) {
      return QuizController();
    });

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider);
    final controller = ref.read(quizControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Practice'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuestionHeader(state),
              const SizedBox(height: 16),
              _buildOptionButton(
                label: 'A',
                text: state.question.optionA,
                selectedOption: state.selectedOption,
                correctOption: state.question.correctOption,
                onTap: () => controller.selectOption(QuizOption.a),
              ),
              _buildOptionButton(
                label: 'B',
                text: state.question.optionB,
                selectedOption: state.selectedOption,
                correctOption: state.question.correctOption,
                onTap: () => controller.selectOption(QuizOption.b),
              ),
              _buildOptionButton(
                label: 'C',
                text: state.question.optionC,
                selectedOption: state.selectedOption,
                correctOption: state.question.correctOption,
                onTap: () => controller.selectOption(QuizOption.c),
              ),
              _buildOptionButton(
                label: 'D',
                text: state.question.optionD,
                selectedOption: state.selectedOption,
                correctOption: state.question.correctOption,
                onTap: () => controller.selectOption(QuizOption.d),
              ),
              if (state.showExplanation) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB300)),
                  ),
                  child: Text(
                    'Explanation: ${state.question.explanation}',
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                  onPressed: controller.isLastQuestion
                      ? null
                      : controller.nextQuestion,
                  child: Text(
                    controller.isLastQuestion ? 'End of Quiz' : 'Next Question',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(QuizQuestionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                state.question.category ?? 'Practice',
                style: const TextStyle(
                  color: Color(0xFFFFB300),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              state.question.difficulty ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          state.question.stem,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String text,
    required QuizOption? selectedOption,
    required String correctOption,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedOption != null;
    final selectedLetter = selectedOption?.name.toUpperCase();
    final isCorrect = selectedLetter == correctOption;
    final borderColor = isSelected
        ? isCorrect
              ? const Color(0xFFFFB300)
              : const Color(0xFFD32F2F)
        : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                child: Text(label),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}
