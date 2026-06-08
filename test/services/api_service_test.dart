import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/auth_service.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => null;

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
  }) async {}

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

AuthService _fakeAuth() => AuthService(storage: _FakeSecureStorage());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService', () {
    test('baseUrl should have a default value', () {
      expect(ApiService.baseUrl, isNotEmpty);
    });

    group('checkHealth', () {
      test('should return status when server responds 200', () async {
        final client = MockClient((request) async {
          expect(request.url.path, endsWith('/health'));
          expect(request.headers['Accept'], 'application/json');
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        });

        final apiService = ApiService(client: client);
        final result = await apiService.checkHealth();
        expect(result, 'ok');
      });

      test('should return error message on non-200 status', () async {
        final client = MockClient(
          (_) async => http.Response('Server Error', 503),
        );

        final apiService = ApiService(client: client);
        final result = await apiService.checkHealth();
        expect(result, 'Fout: 503');
      });

      test('should handle invalid JSON response', () async {
        final client = MockClient((_) async => http.Response('not json', 200));

        final apiService = ApiService(client: client);
        final result = await apiService.checkHealth();
        expect(result, 'Ongeldig antwoord van de server.');
      });

      test('should handle SocketException', () async {
        final client = MockClient((_) => throw const SocketException(''));

        final apiService = ApiService(client: client);
        final result = await apiService.checkHealth();
        expect(
          result,
          'Server is niet bereikbaar. Controleer of de server draait.',
        );
      });

      test('should handle generic exception', () async {
        final client = MockClient((_) => throw Exception('unexpected'));

        final apiService = ApiService(client: client);
        final result = await apiService.checkHealth();
        expect(result, 'Kan niet verbinden met de server');
      });
    });

    group('getProjects', () {
      test('should return list of projects on 200', () async {
        final client = MockClient((request) async {
          expect(request.url.path, endsWith('/projects'));
          expect(request.headers['Accept'], 'application/json');
          return http.Response(
            jsonEncode([
              {'id': 1, 'title': 'Project A'},
              {'id': 2, 'title': 'Project B'},
            ]),
            200,
          );
        });

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.getProjects();

        expect(result['success'], true);
        expect(result['projects'], hasLength(2));
      });

      test('should return empty list when no projects exist', () async {
        final client = MockClient(
          (_) async => http.Response(jsonEncode([]), 200),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.getProjects();

        expect(result['success'], true);
        expect(result['projects'], isEmpty);
      });

      test('should return error on non-200 status', () async {
        final client = MockClient((_) async => http.Response('error', 500));

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.getProjects();

        expect(result['success'], false);
        expect(result['message'], contains('500'));
      });

      test('should handle SocketException', () async {
        final client = MockClient((_) => throw const SocketException(''));

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.getProjects();

        expect(result['success'], false);
        expect(result['message'], contains('niet bereikbaar'));
      });

      test('should handle invalid JSON', () async {
        final client = MockClient((_) async => http.Response('not json', 200));

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.getProjects();

        expect(result['success'], false);
        expect(result['message'], contains('Ongeldig'));
      });
    });

    group('uploadPhoto', () {
      test('should return error when file does not exist', () async {
        final client = MockClient((_) async => http.Response('', 200));
        final apiService = ApiService(client: client, authService: _fakeAuth());

        final result = await apiService.uploadPhoto(
          '/nonexistent/photo.jpg',
          projectId: 1,
        );

        expect(result['success'], false);
        expect(
          result['message'],
          'Bestand niet gevonden: /nonexistent/photo.jpg',
        );
      });

      test('should send project_id and return success on 201', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        late http.MultipartRequest capturedRequest;
        final client = MockClient.streaming((request, _) async {
          capturedRequest = request as http.MultipartRequest;
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(
                jsonEncode({'message': 'Photo uploaded successfully'}),
              ),
            ),
            201,
          );
        });

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 42,
        );

        expect(result['success'], true);
        expect(result['message'], 'Photo uploaded successfully');
        expect(capturedRequest.url.path, endsWith('/photos/upload'));
        expect(capturedRequest.headers['Accept'], 'application/json');
        expect(capturedRequest.fields['project_id'], '42');

        tempFile.deleteSync();
      });

      test('should omit project_id when uploading to my sketches', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        late http.MultipartRequest capturedRequest;
        final client = MockClient.streaming((request, _) async {
          capturedRequest = request as http.MultipartRequest;
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(
                jsonEncode({'message': 'Photo uploaded successfully'}),
              ),
            ),
            201,
          );
        });

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(tempFile.path);

        expect(result['success'], true);
        expect(capturedRequest.url.path, endsWith('/photos/upload'));
        expect(capturedRequest.fields.containsKey('project_id'), false);

        tempFile.deleteSync();
      });

      test('should return error message from server on failure', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({'message': 'Bestand is te groot'}),
            413,
          ),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 1,
        );

        expect(result['success'], false);
        expect(result['message'], 'Bestand is te groot');

        tempFile.deleteSync();
      });

      test('should handle Laravel validation errors', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({
              'message': 'The given data was invalid.',
              'errors': {
                'photo': ['The photo field is required.'],
              },
            }),
            422,
          ),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 1,
        );

        expect(result['success'], false);
        expect(result['message'], 'The photo field is required.');

        tempFile.deleteSync();
      });

      test('should handle non-JSON error response', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final client = MockClient(
          (_) async => http.Response('<html>Server Error</html>', 500),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 1,
        );

        expect(result['success'], false);
        expect(result['message'], 'Server gaf een ongeldig antwoord (500)');

        tempFile.deleteSync();
      });

      test('should handle SocketException during upload', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final client = MockClient(
          (_) => throw const SocketException('Connection refused'),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 1,
        );

        expect(result['success'], false);
        expect(result['message'], contains('niet bereikbaar'));

        tempFile.deleteSync();
      });

      test('should handle unknown server error with null message', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_photo.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        final client = MockClient(
          (_) async => http.Response(jsonEncode({}), 500),
        );

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhoto(
          tempFile.path,
          projectId: 1,
        );

        expect(result['success'], false);
        expect(result['message'], 'Onbekende fout');

        tempFile.deleteSync();
      });

      test('should always return map with success and message keys', () async {
        final client = MockClient((_) async => http.Response('', 500));
        final apiService = ApiService(client: client, authService: _fakeAuth());

        final result = await apiService.uploadPhoto(
          '/nonexistent/photo.jpg',
          projectId: 1,
        );

        expect(result.containsKey('success'), true);
        expect(result.containsKey('message'), true);
        expect(result['success'], isA<bool>());
        expect(result['message'], isA<String>());
        expect(result['message'], isNotEmpty);
      });
    });

    group('uploadPhotoPreview', () {
      test('should upload the already rotated preview image', () async {
        final tempFile = File('${Directory.systemTemp.path}/test_preview.jpg');
        tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]);

        late http.MultipartRequest capturedRequest;
        final client = MockClient.streaming((request, _) async {
          capturedRequest = request as http.MultipartRequest;
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode({'preview_id': 7}))),
            201,
          );
        });

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.uploadPhotoPreview(tempFile.path);

        expect(result['success'], true);
        expect(result['preview_id'], 7);
        expect(capturedRequest.url.path, endsWith('/photos/preview'));
        expect(capturedRequest.fields.containsKey('rotation'), false);

        tempFile.deleteSync();
      });
    });

    group('commitPhotoPreview', () {
      test('should send project_id without rotation', () async {
        final client = MockClient((request) async {
          expect(request.url.path, endsWith('/photos/preview/7/commit'));
          expect(request.headers['Content-Type'], contains('application/json'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['project_id'], 42);
          expect(body.containsKey('rotation'), false);

          return http.Response(
            jsonEncode({'photo_id': 9, 'sketch_id': 12}),
            201,
          );
        });

        final apiService = ApiService(client: client, authService: _fakeAuth());
        final result = await apiService.commitPhotoPreview(7, projectId: 42);

        expect(result['success'], true);
        expect(result['photo_id'], 9);
        expect(result['sketch_id'], 12);
      });
    });
  });
}
