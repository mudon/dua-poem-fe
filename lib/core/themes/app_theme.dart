import 'package:flutter/material.dart';

class AppTheme {
  static const Color sage = Color(0xFF7C9A6E);
  static const Color sageDark = Color(0xFF5F7A52);
  static const Color sageLight = Color(0xFFA8C39B);
  static const Color sageMist = Color(0xFFE2ECD9);
  static const Color earthBrown = Color(0xFFB48C6C);
  static const Color softCream = Color(0xFFFEFCF7);
  static const Color warmGray = Color(0xFFEBE3D5);
  static const Color errorRed = Color(0xFFE05A4F);

  static SnackBar snackBar(String message, {Color? backgroundColor}) {
    return SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor ?? const Color(0xFF3D4F3A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    );
  }

  static SnackBar successSnackBar(String message) {
    return snackBar(message, backgroundColor: const Color(0xFF5A7A4A));
  }

  static SnackBar errorSnackBar(String message) {
    return snackBar(message, backgroundColor: const Color(0xFFD95C4A));
  }

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFFF4F0E8),
    primaryColor: sage,
    colorScheme: const ColorScheme.light(
      primary: sage,
      secondary: earthBrown,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: softCream,
      labelStyle: const TextStyle(color: Color(0xFF9A8C79)),
      hintStyle: const TextStyle(color: Color(0xFF9A8C79)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: warmGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: warmGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: sageLight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: sage,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(44)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}
