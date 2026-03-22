import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archify_app/theme/app_theme.dart';

class PhotoPreviewBox extends StatelessWidget {
  final String photoPath;

  const PhotoPreviewBox({super.key, required this.photoPath});

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
            child: Image.file(
              File(photoPath),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
