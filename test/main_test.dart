import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_first_app/main.dart';


void main() {
  testWidgets('App displays Hello World text', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Hello World! from flutter'), findsOneWidget);
  });
}
