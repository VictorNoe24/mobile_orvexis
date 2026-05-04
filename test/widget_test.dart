import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_orvexis/config/theme/theme_controller.dart';
import 'package:mobile_orvexis/main.dart';

void main() {
  testWidgets('MyApp renders a MaterialApp router shell', (
    WidgetTester tester,
  ) async {
    final themeController = ThemeController();

    await tester.pumpWidget(MyApp(themeController: themeController));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
