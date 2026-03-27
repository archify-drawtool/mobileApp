import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color magenta = Color(0xFFE5097F);
  static const Color darkNavy = Color(0xFF0D0A1F);
  static const Color grey = Color(0xFFA0A0A8);
  static const Color white = Colors.white;
  static const Color magentaLight = Color(0x33E5097F);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(color: AppColors.grey, fontSize: 14);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.darkNavy,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 24,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.magenta,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
      useMaterial3: true,
    );
  }
}
