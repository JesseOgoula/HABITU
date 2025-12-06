// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabituApp());

    // Verify that the app loads
    expect(find.text('User'), findsOneWidget);
  });
}
