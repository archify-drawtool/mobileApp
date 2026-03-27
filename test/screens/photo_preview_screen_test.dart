import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('PhotoPreviewScreen', () {
    testWidgets('should display preview text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const PhotoPreviewScreen(photoPath: '/fake/path.jpg'),
        ),
      );

      expect(find.text('Foto gebruiken?'), findsOneWidget);
    });

    testWidgets('should have accept and retake buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const PhotoPreviewScreen(photoPath: '/fake/path.jpg'),
        ),
      );

      expect(find.text('Accepteren'), findsOneWidget);
      expect(find.text('Opnieuw'), findsOneWidget);
    });

    testWidgets('should have PREVIEW badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const PhotoPreviewScreen(photoPath: '/fake/path.jpg'),
        ),
      );

      expect(find.text('PREVIEW'), findsOneWidget);
    });
  });
}
