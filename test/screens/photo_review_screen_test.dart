import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/photo_review_screen.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';

void main() {
  group('PhotoReviewScreen', () {
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const PhotoReviewScreen(photoPath: '/fake/path.jpg'),
      );
    }

    testWidgets('should display orientation text first', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Zet de foto rechtop'), findsOneWidget);
    });

    testWidgets('should have DRAAIEN badge before upload', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('DRAAIEN'), findsOneWidget);
    });

    testWidgets('should have rotate buttons', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Rechtsom'), findsOneWidget);
      expect(find.text('Linksom'), findsOneWidget);
    });

    testWidgets('should have continue and new-photo buttons', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Verder'), findsOneWidget);
      expect(find.text('Nieuwe foto'), findsOneWidget);
    });

    testWidgets('should not show use-photo button before preview upload', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Gebruik deze foto'), findsNothing);
    });

    testWidgets('should not show back button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('should have ArchifyLogo in app bar', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('preview starts unrotated', (tester) async {
      await tester.pumpWidget(createScreen());

      final box = tester.widget<PhotoPreviewBox>(find.byType(PhotoPreviewBox));
      expect(box.quarterTurns, 0);
    });

    testWidgets('tapping "Rechtsom" advances 90 degrees clockwise each time', (
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

    testWidgets('tapping "Linksom" goes counter-clockwise from 0 to 3', (
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
