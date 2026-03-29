import 'package:flutter_test/flutter_test.dart';
import 'package:archify_app/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('baseUrl should have a default value', () {
      expect(ApiService.baseUrl, isNotEmpty);
    });

    test('checkHealth should return a string', () async {
      final result = await apiService.checkHealth();
      expect(result, isA<String>());
    });

    test('checkHealth should handle connection failure', () async {
      final result = await apiService.checkHealth();
      expect(
        result,
        anyOf('Kan niet verbinden met de server', 'Verbinding duurde te lang'),
      );
    });

    test('uploadPhoto should handle connection failure', () async {
      final result = await apiService.uploadPhoto('/fake/path.jpg');
      expect(result['success'], false);
      expect(result['message'], isA<String>());
      expect(result['message'], isNotEmpty);
    });

    test(
      'uploadPhoto should return a map with success and message keys',
      () async {
        final result = await apiService.uploadPhoto('/fake/path.jpg');
        expect(result.containsKey('success'), true);
        expect(result.containsKey('message'), true);
      },
    );
  });
}
