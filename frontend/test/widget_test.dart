// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties and correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:jonetsu/app.dart';

void main() {
  testWidgets('JŌNETSU app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JonetsuApp());

    // Verify that the app starts up successfully
    await tester.pumpAndSettle();
    expect(find.byType(JonetsuApp), findsOneWidget);
  });
}
