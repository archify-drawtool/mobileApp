import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:archify_app/services/photo_service.dart';

void main() {
  group('PhotoService.fixOrientation', () {
    late Directory tempDir;
    final service = PhotoService();

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('photo_service_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Writes a landscape (wider than tall) JPEG so rotation is observable.
    Future<String> writeSampleJpeg({int width = 120, int height = 60}) async {
      final image = img.Image(width: width, height: height);
      img.fill(image, color: img.ColorRgb8(10, 20, 30));
      final path = '${tempDir.path}/sample.jpg';
      await File(path).writeAsBytes(img.encodeJpg(image));
      return path;
    }

    img.Image decode(String path) {
      return img.decodeImage(File(path).readAsBytesSync())!;
    }

    test('keeps dimensions when quarterTurns is 0', () async {
      final src = await writeSampleJpeg(width: 120, height: 60);
      final out = await service.fixOrientation(src);
      final result = decode(out);
      expect(result.width, 120);
      expect(result.height, 60);
    });

    test('swaps width and height for a single 90° turn', () async {
      final src = await writeSampleJpeg(width: 120, height: 60);
      final out = await service.fixOrientation(src, quarterTurns: 1);
      final result = decode(out);
      expect(result.width, 60);
      expect(result.height, 120);
    });

    test('keeps dimensions for a 180° turn', () async {
      final src = await writeSampleJpeg(width: 120, height: 60);
      final out = await service.fixOrientation(src, quarterTurns: 2);
      final result = decode(out);
      expect(result.width, 120);
      expect(result.height, 60);
    });

    test('swaps width and height for a 270° turn', () async {
      final src = await writeSampleJpeg(width: 120, height: 60);
      final out = await service.fixOrientation(src, quarterTurns: 3);
      final result = decode(out);
      expect(result.width, 60);
      expect(result.height, 120);
    });

    test('normalises out-of-range quarterTurns (4 == 0)', () async {
      final src = await writeSampleJpeg(width: 120, height: 60);
      final out = await service.fixOrientation(src, quarterTurns: 4);
      final result = decode(out);
      expect(result.width, 120);
      expect(result.height, 60);
    });

    test('writes a separate _fixed.jpg that cleanup removes', () async {
      final src = await writeSampleJpeg();
      final out = await service.fixOrientation(src, quarterTurns: 1);
      expect(out.endsWith('_fixed.jpg'), isTrue);
      expect(await File(out).exists(), isTrue);

      await service.cleanupFixedPhoto(out);
      expect(await File(out).exists(), isFalse);
    });
  });
}
