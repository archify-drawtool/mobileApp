import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/widgets/screen_badge.dart';

void main() {
  group('ScreenBadge', () {
    testWidgets('should display the label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScreenBadge(label: 'CAMERA')),
        ),
      );

      expect(find.text('CAMERA'), findsOneWidget);
    });

    testWidgets('should display different labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScreenBadge(label: 'PREVIEW')),
        ),
      );

      expect(find.text('PREVIEW'), findsOneWidget);
    });
  });
}
