import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  Future<String> checkHealth() async {
    try {
      final response = await http
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

  Future<Map<String, dynamic>> uploadPhoto(String photoPath) async {
    // Controleer eerst of het bestand bestaat
    final file = File(photoPath);
    if (!await file.exists()) {
      return {'success': false, 'message': 'Bestand niet gevonden: $photoPath'};
    }

    // Stap 1: Verstuur het request (netwerk-fouten hier afvangen)
    http.StreamedResponse streamedResponse;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      request.headers['Accept'] = 'application/json';

      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
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

    // Stap 2: Response verwerken (apart van netwerk-errors)
    try {
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      }

      // Probeer foutmelding uit response body te halen
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
