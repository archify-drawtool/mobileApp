import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:archify_app/theme/app_theme.dart';

class ArchifyLogo extends StatelessWidget {
  final double fontSize;

  const ArchifyLogo({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.syne(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: 'Archi',
            style: TextStyle(color: AppColors.white),
          ),
          TextSpan(
            text: 'fy',
            style: TextStyle(color: AppColors.magenta),
          ),
        ],
      ),
    );
  }
}
