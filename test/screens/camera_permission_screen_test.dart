import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  group('CameraPermissionScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: const CameraPermissionScreen(),
      );
    }

    testWidgets('should display permission heading', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Camera toegang vereist'), findsOneWidget);
    });

    testWidgets('should display permission description', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text(
          'Archify heeft toegang tot je camera nodig om foto\'s te maken van je toolkit.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should have allow access button', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Toegang toestaan'), findsOneWidget);
    });

    testWidgets('should have not now button', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Niet nu'), findsOneWidget);
    });

    testWidgets('not now button should show snackbar', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Niet nu'));
      await tester.pump();

      expect(
        find.text('Camera toegang is nodig om Archify te gebruiken'),
        findsOneWidget,
      );
    });
  });
}
