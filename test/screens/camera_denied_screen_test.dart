import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/camera_denied_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('CameraDeniedScreen', () {
    testWidgets('should display denied message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const CameraDeniedScreen()),
      );

      expect(find.text('Geen Camera toegang'), findsOneWidget);
    });

    testWidgets('should have settings button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const CameraDeniedScreen()),
      );

      expect(find.text('Instellingen openen'), findsOneWidget);
    });

    testWidgets('should have retry button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const CameraDeniedScreen()),
      );

      expect(find.text('Probeer opnieuw'), findsOneWidget);
    });
  });
}
