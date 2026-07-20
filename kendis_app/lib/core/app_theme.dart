import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna diambil langsung dari desain Figma "Kendis (Driver)"
class AppColors {
  static const Color primaryDark = Color(0xFF004659); // teal gelap
  static const Color primary = Color(0xFF006780); // teal utama
  static const Color accentGold = Color(0xFFCEA700); // gold aksen
  static const Color background = Color(0xFFF1F5F9); // bg terang
  static const Color backgroundAlt = Color(0xFFE2E8F0);
  static const Color inputFill = Color(0xFFF0F4F8);
  static const Color textPrimary = Color(0xFF004659);
  static const Color textBody = Color(0xFF40484C);
  static const Color textMuted = Color(0xFF70787D);
  static const Color textPlaceholder = Color(0xFFBFC8CC);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFCA8A04);
  static const Color danger = Color(0xFFDC2626);
  static const Color cardBackground = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accentGold,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textBody,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textPlaceholder, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      useMaterial3: true,
    );
  }

  /// Gradient tombol utama / hero, sesuai desain (#006780 -> #004659)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
