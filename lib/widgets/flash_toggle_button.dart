import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/theme/app_theme.dart';

FlashMode nextFlashMode(FlashMode current) {
  switch (current) {
    case FlashMode.off:
      return FlashMode.always;
    case FlashMode.always:
      return FlashMode.auto;
    case FlashMode.auto:
      return FlashMode.off;
    default:
      return FlashMode.off;
  }
}

class FlashToggleButton extends StatelessWidget {
  final FlashMode currentMode;
  final VoidCallback onTap;

  const FlashToggleButton({
    super.key,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkNavy.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              currentMode == FlashMode.off
                  ? LucideIcons.zapOff
                  : LucideIcons.zap,
              color: _iconColor(currentMode),
              size: 20,
            ),
            if (currentMode == FlashMode.auto)
              Positioned(
                bottom: 4,
                right: 4,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.magenta,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _iconColor(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
        return AppColors.magenta;
      case FlashMode.auto:
        return AppColors.magenta;
      case FlashMode.off:
      default:
        return AppColors.grey;
    }
  }
}
