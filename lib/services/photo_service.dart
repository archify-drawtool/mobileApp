import 'dart:io';
import 'package:image/image.dart' as img;

class PhotoService {
  Future<String> fixOrientation(String photoPath) async {
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return photoPath;

    final oriented = img.bakeOrientation(image);

    const maxLongSide = 1920;
    final longestSide = oriented.width > oriented.height ? oriented.width : oriented.height;
    final resized = longestSide > maxLongSide
        ? img.copyResize(
            oriented,
            width: oriented.width > oriented.height ? maxLongSide : null,
            height: oriented.height >= oriented.width ? maxLongSide : null,
          )
        : oriented;

    final fixedBytes = img.encodeJpg(resized, quality: 85);

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
