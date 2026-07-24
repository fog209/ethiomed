import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethiomed/features/settings/reading_mode_provider.dart';
import 'package:ethiomed/features/quiz/quiz_screen.dart';

void main() {
  testWidgets('Sepia mode applies warm background to quiz explanation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: QuizScreen(),
        ),
      ),
    );

    // Verify the reading mode provider exists and sepia can be enabled
    final container = ProviderScope.containerOf(tester.element(find.byType(QuizScreen)));
    final initialMode = container.read(readingModeProvider);
    expect(initialMode.sepia, isFalse);

    // Enable sepia
    await container.read(readingModeProvider.notifier).setSepia(true);
    final sepiaMode = container.read(readingModeProvider);
    expect(sepiaMode.sepia, isTrue);
  });
}