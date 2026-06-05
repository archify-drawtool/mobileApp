import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archify_app/theme/app_theme.dart';

class PhotoPreviewBox extends StatelessWidget {
  final String photoPath;

  /// Number of 90° clockwise turns to apply to the preview (0–3).
  final int quarterTurns;

  const PhotoPreviewBox({
    super.key,
    required this.photoPath,
    this.quarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.magenta, width: 2),
        ),
        child: ClipRect(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            // RotatedBox rotates within layout, so the child is fit *after*
            // rotation. Combined with BoxFit.contain the whole photo stays
            // visible (letterboxed) instead of being cropped — also when the
            // user turns it to landscape.
            child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Image.file(
                File(photoPath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
