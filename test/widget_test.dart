import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renderiza un widget base', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Mobile Orvexis'))),
      ),
    );

    expect(find.text('Mobile Orvexis'), findsOneWidget);
  });
}
