import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:archify_app/theme/app_theme.dart';

class CameraPreviewBox extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewBox({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.magenta, width: 2),
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize!.height,
                height: controller.value.previewSize!.width,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
