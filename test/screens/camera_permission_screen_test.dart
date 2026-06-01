import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store;

  _FakeSecureStorage({Map<String, String>? initial}) : _store = initial ?? {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  group('CameraPermissionScreen', () {
    // Storage with no 'hasSeenPermissionScreen' key → screen shows permission UI
    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: CameraPermissionScreen(storage: _FakeSecureStorage()),
      );
    }

    testWidgets('should display permission heading', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      expect(find.text('Camera toegang vereist'), findsOneWidget);
    });

    testWidgets('should display permission description', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      expect(
        find.text(
          'Archify heeft toegang tot je camera nodig om foto\'s te maken van je toolkit.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should have allow access button', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      expect(find.text('Toegang toestaan'), findsOneWidget);
    });

    testWidgets('should have not now button', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      expect(find.text('Niet nu'), findsOneWidget);
    });

    testWidgets('not now button should show snackbar', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pump();

      await tester.tap(find.text('Niet nu'));
      await tester.pump();

      expect(
        find.text('Camera toegang is nodig om Archify te gebruiken'),
        findsOneWidget,
      );
    });
  });
}
