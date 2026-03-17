import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  Future<String> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Could not connect to API';
    }
  }
}
