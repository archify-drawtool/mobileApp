import 'package:flutter/material.dart';
import 'package:archify_app/theme/app_theme.dart';

class ScreenBadge extends StatelessWidget {
  final String label;

  const ScreenBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.magentaLight,
        border: Border.all(color: AppColors.magenta, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.magenta,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
