import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/widgets/archify_logo.dart';

void main() {
  group('ArchifyLogo', () {
    testWidgets('should display Archi and fy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ArchifyLogo())),
      );

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should accept custom fontSize', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ArchifyLogo(fontSize: 30))),
      );

      expect(find.byType(RichText), findsOneWidget);
    });
  });
}
