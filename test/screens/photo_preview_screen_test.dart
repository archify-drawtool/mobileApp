import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('PhotoPreviewScreen', () {
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const PhotoPreviewScreen(photoPath: '/fake/path.jpg'),
      );
    }

    testWidgets('should display preview text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Foto gebruiken?'), findsOneWidget);
    });

    testWidgets('should have PREVIEW badge', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('PREVIEW'), findsOneWidget);
    });

    testWidgets('should have accept button with correct text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Accepteren'), findsOneWidget);
    });

    testWidgets('should have retake button with correct text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Opnieuw'), findsOneWidget);
    });

    testWidgets('should have ArchifyLogo in app bar', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('should not show back button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('accept and retake buttons should be enabled initially', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());

      final acceptButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Accepteren'),
      );
      final retakeButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Opnieuw'),
      );

      expect(acceptButton.onPressed, isNotNull);
      expect(retakeButton.onPressed, isNotNull);
    });
  });
}
