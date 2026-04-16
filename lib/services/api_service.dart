import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:archify_app/models/project.dart';
import 'package:archify_app/services/auth_service.dart';

class LoginResult {
  final bool success;
  final String? token;
  final String? message;

  const LoginResult({required this.success, this.token, this.message});
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  final http.Client _client;
  final AuthService _authService;

  ApiService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await _authService.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException {
      return const LoginResult(
        success: false,
        message: 'Server is niet bereikbaar. Controleer je internetverbinding.',
      );
    } on TimeoutException {
      return const LoginResult(
        success: false,
        message: 'Inloggen duurde te lang. Probeer het opnieuw.',
      );
    } catch (e) {
      return const LoginResult(
        success: false,
        message: 'Kan geen verbinding maken met de server.',
      );
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['token'] is String) {
        return LoginResult(success: true, token: data['token'] as String);
      }

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values
            .expand((v) => v is List ? v : [v])
            .first;
        return LoginResult(success: false, message: firstError.toString());
      }

      final message = data['message'] as String?;
      return LoginResult(
        success: false,
        message: message ?? 'Inloggen mislukt (${response.statusCode}).',
      );
    } on FormatException {
      return LoginResult(
        success: false,
        message: 'Ongeldig antwoord van de server (${response.statusCode}).',
      );
    }
  }

  Future<String> checkHealth() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      } else {
        return 'Fout: ${response.statusCode}';
      }
    } on SocketException {
      return 'Server is niet bereikbaar. Controleer of de server draait.';
    } on TimeoutException {
      return 'Connectie niet kunnen leggen: verbinden duurde te lang';
    } on FormatException {
      return 'Ongeldig antwoord van de server.';
    } catch (e) {
      return 'Kan niet verbinden met de server';
    }
  }

  Future<Map<String, dynamic>> getProjects() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/projects'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final projects = data.map((json) => Project.fromJson(json)).toList();
        return {'success': true, 'projects': projects};
      } else if (response.statusCode == 401) {
        await _authService.clearToken();
        return {
          'success': false,
          'unauthorized': true,
          'message': 'Je sessie is verlopen. Log opnieuw in.',
        };
      } else {
        return {
          'success': false,
          'message': 'Kon projecten niet ophalen (${response.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Server is niet bereikbaar. Controleer of de server draait.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Verbinding duurde te lang. Probeer het later opnieuw.',
      };
    } on FormatException {
      return {'success': false, 'message': 'Ongeldig antwoord van de server.'};
    } catch (e) {
      return {'success': false, 'message': 'Kan niet verbinden met de server'};
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(
    String photoPath, {
    required int projectId,
  }) async {
    final file = File(photoPath);
    if (!await file.exists()) {
      return {'success': false, 'message': 'Bestand niet gevonden: $photoPath'};
    }

    http.StreamedResponse streamedResponse;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      request.headers.addAll(await _authHeaders());
      request.fields['project_id'] = projectId.toString();
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
    } on SocketException {
      return {
        'success': false,
        'message': 'Server is niet bereikbaar. Controleer of de server draait.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Upload duurde te lang. Controleer je verbinding en probeer het opnieuw.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kan geen verbinding maken: $e'};
    }

    try {
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      }

      if (response.statusCode == 401) {
        await _authService.clearToken();
        return {
          'success': false,
          'unauthorized': true,
          'message': 'Je sessie is verlopen. Log opnieuw in.',
        };
      }

      String errorMessage;
      try {
        final data = jsonDecode(response.body);
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values
              .expand((v) => v is List ? v : [v])
              .join(', ');
        } else {
          errorMessage = data['message'] ?? 'Onbekende fout';
        }
      } on FormatException {
        errorMessage =
            'Server gaf een ongeldig antwoord (${response.statusCode})';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {
        'success': false,
        'message': 'Fout bij verwerken van server-antwoord: $e',
      };
    }
  }
}
