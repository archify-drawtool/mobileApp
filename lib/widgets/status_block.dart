import 'package:flutter/material.dart';
import 'package:archify_app/theme/app_theme.dart';

class StatusBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showSpinner;

  const StatusBlock({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 56),
        const SizedBox(height: 24),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.heading),
        const SizedBox(height: 12),
        Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.body),
        if (showSpinner) ...[
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: AppColors.magenta),
        ],
      ],
    );
  }
}

