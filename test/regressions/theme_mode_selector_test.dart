import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethiomed/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders Theme Mode selector with System option', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('SegmentedButton allows switching between theme modes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    // Initial: System should be visible
    expect(find.text('System'), findsOneWidget);

    // Tap on Light segment
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    // Tap on Dark segment
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Should not throw any exceptions
    expect(find.text('Theme Mode'), findsOneWidget);
  });
}