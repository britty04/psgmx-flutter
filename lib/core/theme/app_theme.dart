import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_dimens.dart';

/// Custom theme extension for semantic colors
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color info;
  final Color infoContainer;
  final Color onInfo;
  final Color gold;
  final Color silver;
  final Color bronze;

  const SemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.info,
    required this.infoContainer,
    required this.onInfo,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  @override
  SemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccess,
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? info,
    Color? infoContainer,
    Color? onInfo,
    Color? gold,
    Color? silver,
    Color? bronze,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfo: onInfo ?? this.onInfo,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      bronze: bronze ?? this.bronze,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      bronze: Color.lerp(bronze, other.bronze, t)!,
    );
  }

  static const light = SemanticColors(
    success: Color(0xFF059669),
    successContainer: Color(0xFFD1FAE5),
    onSuccess: Color(0xFF065F46),
    warning: Color(0xFFF59E0B),
    warningContainer: Color(0xFFFEF3C7),
    onWarning: Color(0xFF92400E),
    info: Color(0xFF3B82F6),
    infoContainer: Color(0xFFDEEBFF),
    onInfo: Color(0xFF1E40AF),
    gold: Color(0xFFFFD700),
    silver: Color(0xFFC0C0C0),
    bronze: Color(0xFFCD7F32),
  );

  static const dark = SemanticColors(
    success: Color(0xFF10B981),
    successContainer: Color(0xFF064E3B),
    onSuccess: Color(0xFFD1FAE5),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF78350F),
    onWarning: Color(0xFFFEF3C7),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF1E3A8A),
    onInfo: Color(0xFFDEEBFF),
    gold: Color(0xFFFFD700),
    silver: Color(0xFFC0C0C0),
    bronze: Color(0xFFCD7F32),
  );
}

class AppTheme {
  // --- Dark Theme Colors ---
  static const Color _darkBg = Color(0xFF0B0D10); // Deep Charcoal
  static const Color _darkSurface = Color(0xFF15181D); 
  static const Color _darkElevated = Color(0xFF1C2026);
  static const Color _darkBorder = Color(0xFF23262C);
  
  static const Color _darkTextPrimary = Color(0xFFF5F7FA);
  static const Color _darkTextSecondary = Color(0xFF9AA0A6);
  static const Color _darkTextMuted = Color(0xFF6B7078);

  // --- Light Theme Colors ---
  static const Color _lightBg = Color(0xFFF9FAFB); // Luxury Off-White
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightElevated = Color(0xFFF1F3F5);
  static const Color _lightBorder = Color(0xFFE6E8EB);
  
  static const Color _lightTextPrimary = Color(0xFF111318);
  static const Color _lightTextSecondary = Color(0xFF5E6368);
  static const Color _lightTextMuted = Color(0xFF9AA0A6);

  // --- Brand Colors (Shared) ---
  static const Color primaryOrange = Color(0xFFFF8C1A);
  static const Color primaryActive = Color(0xFFE67600);
  
  static const Color _darkSoftOrange = Color(0xFFFFB36B);
  static const Color _lightSoftOrange = Color(0xFFFFD2A1);

  // --- Methods ---

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: primaryOrange,
      onPrimary: _darkTextPrimary,
      secondary: _darkSoftOrange,
      onSecondary: _darkBg,
      surface: _darkSurface,
      onSurface: _darkTextPrimary, // Main text on surface
      surfaceContainerHighest: _darkElevated, // For cards/inputs
      error: Color(0xFFEF4743),
      onError: Colors.white,
      outline: _darkBorder,
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBg: _darkBg,
      surfaceColor: _darkSurface,
      elevatedColor: _darkElevated,
      borderColor: _darkBorder,
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
      textMuted: _darkTextMuted,
      semanticColors: SemanticColors.dark,
    );
  }

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: primaryOrange,
      onPrimary: Colors.white, // Text on orange button
      secondary: _lightSoftOrange,
      onSecondary: Colors.black,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      surfaceContainerHighest: _lightElevated,
      error: Color(0xFFDC2626),
      onError: Colors.white,
      outline: _lightBorder,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBg: _lightBg,
      surfaceColor: _lightSurface,
      elevatedColor: _lightElevated,
      borderColor: _lightBorder,
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
      textMuted: _lightTextMuted,
      semanticColors: SemanticColors.light,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color surfaceColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required SemanticColors semanticColors,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: <ThemeExtension<dynamic>>[semanticColors],
      
      // Typography
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: primaryOrange),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedColor,
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
      ),
      
      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white, // Always white on orange
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryActive.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          side: const BorderSide(color: primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: isDark ? _darkSoftOrange : primaryOrange,
      ),
    );
  }
}

