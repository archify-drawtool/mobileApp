import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';

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

    testWidgets('accept and retake buttons should be enabled', (tester) async {
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

    testWidgets('should have an enabled rotate button', (tester) async {
      await tester.pumpWidget(createScreen());

      final rotateRight = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Rechtsom'),
      );
      final rotateLeft = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Linksom'),
      );
      expect(rotateRight.onPressed, isNotNull);
      expect(rotateLeft.onPressed, isNotNull);
    });

    testWidgets('preview starts unrotated', (tester) async {
      await tester.pumpWidget(createScreen());

      final box = tester.widget<PhotoPreviewBox>(find.byType(PhotoPreviewBox));
      expect(box.quarterTurns, 0);
    });

    testWidgets('tapping "Rechtsom" advances 90° clockwise each time', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());

      PhotoPreviewBox box() =>
          tester.widget<PhotoPreviewBox>(find.byType(PhotoPreviewBox));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Rechtsom'));
      await tester.pump();
      expect(box().quarterTurns, 1);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Rechtsom'));
      await tester.pump();
      expect(box().quarterTurns, 2);
    });

    testWidgets('tapping "Linksom" goes counter-clockwise (0 -> 3)', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.widgetWithText(OutlinedButton, 'Linksom'));
      await tester.pump();

      final box = tester.widget<PhotoPreviewBox>(find.byType(PhotoPreviewBox));
      expect(box.quarterTurns, 3);
    });

    testWidgets('clockwise rotation wraps back to 0 after four taps', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.widgetWithText(OutlinedButton, 'Rechtsom'));
        await tester.pump();
      }

      final box = tester.widget<PhotoPreviewBox>(find.byType(PhotoPreviewBox));
      expect(box.quarterTurns, 0);
    });

    testWidgets('rotate buttons have accessible semantics labels', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      expect(
        find.bySemanticsLabel('Foto 90 graden rechtsom draaien'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Foto 90 graden linksom draaien'),
        findsOneWidget,
      );
    });
  });
}
