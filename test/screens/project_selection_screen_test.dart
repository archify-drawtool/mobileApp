import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/project_selection_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('ProjectSelectionScreen', () {
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const ProjectSelectionScreen(previewId: 1),
      );
    }

    testWidgets('should display destination text', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Waar wil je deze schets opslaan?'), findsWidgets);
    });

    testWidgets('should have PROJECT badge', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('PROJECT'), findsOneWidget);
    });

    testWidgets('should upload to my sketches initially', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('Uploaden naar Mijn Schetsen'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have back button', (tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
