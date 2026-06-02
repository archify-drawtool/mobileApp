import 'dart:io';
import 'package:image/image.dart' as img;

class PhotoService {
  /// Bakes EXIF orientation, applies the user's manual rotation, resizes and
  /// re-encodes the photo as JPEG.
  ///
  /// [quarterTurns] is the number of 90° clockwise rotations the user picked in
  /// the preview (0–3). The rotation is baked into the pixels so the uploaded
  /// file is already upright — no orientation metadata is sent to the backend.
  Future<String> fixOrientation(String photoPath, {int quarterTurns = 0}) async {
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return photoPath;

    var oriented = img.bakeOrientation(image);

    // Normalise to 0–3 and bake the manual rotation clockwise. This matches the
    // clockwise AnimatedRotation used in the preview, so the saved file equals
    // what the user saw on screen.
    final turns = ((quarterTurns % 4) + 4) % 4;
    if (turns != 0) {
      oriented = img.copyRotate(oriented, angle: turns * 90);
    }

    const maxLongSide = 1920;
    final longestSide = oriented.width > oriented.height
        ? oriented.width
        : oriented.height;
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
