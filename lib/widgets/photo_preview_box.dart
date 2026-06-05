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
    final turns = ((quarterTurns % 4) + 4) % 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.magenta, width: 2),
            ),
            child: ClipRect(
              child: RotatedBox(
                quarterTurns: turns,
                child: Image.file(File(photoPath)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
