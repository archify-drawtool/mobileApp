import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archify_app/screens/login_screen.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/auth_service.dart';

class _FakeApiService extends ApiService {
  _FakeApiService({required this.result});

  final LoginResult result;
  int calls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    calls++;
    lastEmail = email;
    lastPassword = password;
    return result;
  }
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  required ApiService api,
  required AuthService auth,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(apiService: api, authService: auth),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LoginScreen', () {
    testWidgets('renders email, password field and login button', (
      tester,
    ) async {
      await _pumpLogin(
        tester,
        api: _FakeApiService(
          result: const LoginResult(success: true, token: 't'),
        ),
        auth: AuthService(),
      );

      expect(find.text('Login op Archify'), findsOneWidget);
      expect(find.byKey(const Key('login-email')), findsOneWidget);
      expect(find.byKey(const Key('login-password')), findsOneWidget);
      expect(find.byKey(const Key('login-submit')), findsOneWidget);
    });

    testWidgets('shows validation error when email is invalid', (tester) async {
      final api = _FakeApiService(
        result: const LoginResult(success: true, token: 't'),
      );

      await _pumpLogin(tester, api: api, auth: AuthService());

      await tester.enterText(
        find.byKey(const Key('login-email')),
        'not-an-email',
      );
      await tester.enterText(find.byKey(const Key('login-password')), 'secret');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();

      expect(find.text('Vul een geldig e-mailadres in.'), findsOneWidget);
      expect(api.calls, 0);
    });

    testWidgets('shows validation error when password is empty', (
      tester,
    ) async {
      final api = _FakeApiService(
        result: const LoginResult(success: true, token: 't'),
      );

      await _pumpLogin(tester, api: api, auth: AuthService());

      await tester.enterText(
        find.byKey(const Key('login-email')),
        'john@example.com',
      );
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();

      expect(find.text('Wachtwoord is verplicht.'), findsOneWidget);
      expect(api.calls, 0);
    });

    testWidgets('shows server error on failed login', (tester) async {
      final api = _FakeApiService(
        result: const LoginResult(
          success: false,
          message: 'De opgegeven credentials zijn onjuist.',
        ),
      );

      await _pumpLogin(tester, api: api, auth: AuthService());

      await tester.enterText(
        find.byKey(const Key('login-email')),
        'john@example.com',
      );
      await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 50));

      expect(api.calls, 1);
      expect(
        find.text('De opgegeven credentials zijn onjuist.'),
        findsOneWidget,
      );
    });

    testWidgets('saves token on successful login', (tester) async {
      final api = _FakeApiService(
        result: const LoginResult(success: true, token: 'abc123'),
      );
      final auth = AuthService();

      await _pumpLogin(tester, api: api, auth: auth);

      await tester.enterText(
        find.byKey(const Key('login-email')),
        'john@example.com',
      );
      await tester.enterText(find.byKey(const Key('login-password')), 'secret');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(await auth.getToken(), 'abc123');
      expect(api.lastEmail, 'john@example.com');
      expect(api.lastPassword, 'secret');
    });
  });

  group('AuthService', () {
    test('saveToken + getToken roundtrip', () async {
      final auth = AuthService();
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
