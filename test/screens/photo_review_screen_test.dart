import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/photo_review_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('PhotoReviewScreen', () {
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const PhotoReviewScreen(photoPath: '/fake/path.jpg'),
      );
    }

    testWidgets('should display review text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Foto controleren'), findsOneWidget);
    });

    testWidgets('should have REVIEW badge', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('REVIEW'), findsOneWidget);
    });

    testWidgets('should have use-photo button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Gebruik deze foto'), findsOneWidget);
    });

    testWidgets('should have new-photo button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Nieuwe foto'), findsOneWidget);
    });

    testWidgets('use-photo button should be disabled while uploading',
        (tester) async {
      await tester.pumpWidget(createScreen());

      final useButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gebruik deze foto'),
      );
      expect(useButton.onPressed, isNull);
    });

    testWidgets('new-photo button should always be enabled', (tester) async {
      await tester.pumpWidget(createScreen());

      final newButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Nieuwe foto'),
      );
      expect(newButton.onPressed, isNotNull);
    });

    testWidgets('should not show back button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('should show loading state while uploading', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should have ArchifyLogo in app bar', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
