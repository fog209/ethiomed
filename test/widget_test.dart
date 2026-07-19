import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Smoke test: a Material 3 app shell pumps and renders without throwing.
// (Deliberately brand-neutral — the retired "EthioMed" name is the Dart
// package id only; the product is WardReady.)
void main() {
  testWidgets('Material 3 app shell renders without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(body: Center(child: Text('WardReady'))),
      ),
    );

    expect(find.text('WardReady'), findsOneWidget);
  });
}
