import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_dimens.dart';

class AppTheme {
  // PSGMX Brand Colors - Dark Black + Orange
  static const Color psgOrange = Color(0xFFFF6600); // Vibrant Orange
  static const Color psgOrangeLight = Color(0xFFFF8833);
  static const Color psgOrangeDark = Color(0xFFCC5200);
  
  static const Color darkBlack = Color(0xFF000000); // Pure Black
  static const Color darkGray = Color(0xFF0A0A0A); // Slightly lighter black
  static const Color cardDark = Color(0xFF141414); // Card background
  static const Color borderDark = Color(0xFF222222); // Borders
  
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB3B3B3);

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: psgOrange,
      onPrimary: textWhite,
      secondary: psgOrangeLight,
      onSecondary: darkBlack,
      surface: cardDark,
      onSurface: textWhite,
      error: Colors.redAccent,
      onError: textWhite,
      outline: borderDark,
      surfaceContainerHighest: darkGray,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBlack, // Pure black background
      
      // Typography - Modern Google Font
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: textWhite,
          displayColor: textWhite,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        iconTheme: const IconThemeData(color: psgOrange),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        hintStyle: const TextStyle(color: textGray, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: psgOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      
      // Filled Button Theme (Primary Actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: psgOrange,
          foregroundColor: textWhite,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // Outlined Button Theme (Secondary Actions)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: psgOrange,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          side: const BorderSide(color: psgOrange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: psgOrange,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: psgOrange,
        unselectedItemColor: textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
      ),
    );
  }

  // For compatibility, light theme redirects to dark
  static ThemeData light() => dark();
}
