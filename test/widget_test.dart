import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wa_status_saver/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StatusSaverApp());
    await tester.pumpAndSettle();

    // Verify that the app builds a Scaffold
    expect(find.byType(Scaffold), findsOneWidget);

    // Check for Home icon in the bottom navigation
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
