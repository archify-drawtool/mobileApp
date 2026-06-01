import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:archify_app/screens/login_screen.dart';
import 'package:archify_app/services/auth_service.dart';

// ── Fake AuthService voor widget-tests ───────────────────────────────────────

class _FakeAuthService extends AuthService {
  _FakeAuthService({required this.outcome});

  /// null = geannuleerd, String = token, AuthException = fout
  final Object? outcome;

  int calls = 0;

  @override
  Future<String?> loginWithMicrosoft() async {
    calls++;
    if (outcome is AuthException) throw outcome!;
    return outcome as String?;
  }

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<bool> isLoggedIn() async => false;
}

// ── Fake FlutterSecureStorage voor unit-tests ─────────────────────────────────

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};

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

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> _pumpLogin(
  WidgetTester tester, {
  required AuthService auth,
}) async {
  await tester.pumpWidget(MaterialApp(home: LoginScreen(authService: auth)));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('renders title and Microsoft login button', (tester) async {
      await _pumpLogin(tester, auth: _FakeAuthService(outcome: null));

      expect(find.text('Login op Archify'), findsOneWidget);
      expect(find.byKey(const Key('login-microsoft')), findsOneWidget);
      // Oude velden mogen er niet meer zijn
      expect(find.byKey(const Key('login-email')), findsNothing);
      expect(find.byKey(const Key('login-password')), findsNothing);
    });

    testWidgets('shows no error when user cancels Microsoft login', (
      tester,
    ) async {
      final auth = _FakeAuthService(outcome: null); // null = geannuleerd

      await _pumpLogin(tester, auth: auth);
      await tester.tap(find.byKey(const Key('login-microsoft')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(auth.calls, 1);
      expect(find.byKey(const Key('login-error')), findsNothing);
    });

    testWidgets('shows error message on AuthException', (tester) async {
      final auth = _FakeAuthService(
        outcome: const AuthException('Account niet gevonden.'),
      );

      await _pumpLogin(tester, auth: auth);
      await tester.tap(find.byKey(const Key('login-microsoft')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('login-error')), findsOneWidget);
      expect(find.text('Account niet gevonden.'), findsOneWidget);
    });
  });

  group('AuthService (token opslag)', () {
    late _FakeSecureStorage fakeStorage;
    late AuthService auth;

    setUp(() {
      fakeStorage = _FakeSecureStorage();
      auth = AuthService(storage: fakeStorage);
    });

    test('saveToken + getToken roundtrip', () async {
      expect(await auth.isLoggedIn(), false);
      await auth.saveToken('xyz');
      expect(await auth.getToken(), 'xyz');
      expect(await auth.isLoggedIn(), true);
      await auth.clearToken();
      expect(await auth.getToken(), isNull);
      expect(await auth.isLoggedIn(), false);
    });
  });
}
