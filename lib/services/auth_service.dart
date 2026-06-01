import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:http/http.dart' as http;
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/main.dart' show navigatorKey;

class AuthService {
  static const String _tokenKey = 'auth_token';

  static const String _clientId = String.fromEnvironment(
    'ENTRA_CLIENT_ID',
    defaultValue: '',
  );

  static const String _tenantId = String.fromEnvironment(
    'ENTRA_TENANT_ID',
    defaultValue: '',
  );

  final FlutterSecureStorage _storage;

  AuthService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static AadOAuth _buildOAuth() {
    final config = Config(
      tenant: _tenantId,
      clientId: _clientId,
      scope: 'openid profile email',
      navigatorKey: navigatorKey,
    );
    return AadOAuth(config);
  }

  // ── Token opslag ──────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Microsoft Entra login ─────────────────────────────────────────────────

  Future<String?> loginWithMicrosoft() async {
    final oauth = _buildOAuth();

    final result = await oauth.login();

    return result.fold(
      (failure) {
        final msg = failure.toString().toLowerCase();
        if (msg.contains('cancel') || msg.contains('user_cancelled')) {
          return null;
        }
        throw AuthException('Microsoft-login mislukt: $failure');
      },
      (_) async {
        final idToken = await oauth.getIdToken();
        if (idToken == null) {
          throw const AuthException('Geen id_token ontvangen van Microsoft.');
        }
        return _exchangeToken(idToken);
      },
    );
  }

  Future<String?> _exchangeToken(String msToken) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/auth/microsoft'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'id_token': msToken}),
          )
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const AuthException(
        'Server is niet bereikbaar. Controleer je internetverbinding.',
      );
    } on TimeoutException {
      throw const AuthException(
        'Inloggen duurde te lang. Probeer het opnieuw.',
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null) throw const AuthException('API gaf geen token terug.');
      await saveToken(token);
      return token;
    }

    String message;
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      message =
          data['message'] as String? ??
          'Inloggen mislukt (${response.statusCode}).';
    } catch (_) {
      message = 'Inloggen mislukt (${response.statusCode}).';
    }
    throw AuthException(message);
  }

  Future<void> logout() async {
    try {
      final oauth = _buildOAuth();
      await oauth.logout();
    } catch (_) {}
    await clearToken();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
