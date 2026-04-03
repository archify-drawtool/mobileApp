import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  Future<String> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      } else {
        return 'Fout: ${response.statusCode}';
      }
    } on TimeoutException {
      return 'Connectie niet kunnen leggen: verbinden duurde te lang';
    } catch (e) {
      return 'Kan niet verbinden met de server';
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(String photoPath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photos/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Er ging iets mis bij het uploaden',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Upload duurde te lang. Controleer je verbinding en probeer het opnieuw.',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Kan niet verbinden met de server. Controleer of de server draait.',
      };
    }
  }
}
