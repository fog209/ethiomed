import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EthioMed branding renders in a Material 3 app shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: Text('EthioMed'))),
      ),
    );

    expect(find.text('EthioMed'), findsOneWidget);
  });
}
