import 'dart:io';
import 'package:image/image.dart' as img;

class PhotoService {
  Future<String> fixOrientation(String photoPath) async {
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return photoPath;

    final fixed = img.bakeOrientation(image);
    final fixedBytes = img.encodeJpg(fixed, quality: 95);

    final fixedPath = '${photoPath}_fixed.jpg';
    await File(fixedPath).writeAsBytes(fixedBytes);

    return fixedPath;
  }

  Future<void> cleanupFixedPhoto(String fixedPath) async {
    final file = File(fixedPath);
    if (await file.exists() && fixedPath.endsWith('_fixed.jpg')) {
      await file.delete();
    }
  }
}
