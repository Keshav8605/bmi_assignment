import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define colors
  static const Color primaryColor = Color(0xFFF92B54); // Vermo Red/Pink
  static const Color secondaryColor = Color(0xFF3F3D56);
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1E1E1E);
  static const Color textSecondaryColor = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFFF5A5F);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimaryColor), // Bolder for Vermo titles
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryColor),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimaryColor),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimaryColor),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondaryColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: Colors.white,
          shadowColor: primaryColor.withValues(alpha: 0.5),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
        hintStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: textPrimaryColor,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      ),
    );
  }
}
