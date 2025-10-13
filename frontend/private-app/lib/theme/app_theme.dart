import 'package:flutter/material.dart';

/// App Theme Configuration for The Chain
/// Implements Dark Mystique design system
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Dark Mystique Theme Colors
  static const DarkMystiqueTheme darkMystique = DarkMystiqueTheme();

  /// Get the dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkMystique.deepVoid,
      primaryColor: darkMystique.mysticViolet,
      colorScheme: ColorScheme.dark(
        primary: darkMystique.mysticViolet,
        secondary: darkMystique.ghostCyan,
        surface: darkMystique.shadowDark,
        background: darkMystique.deepVoid,
        error: darkMystique.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white.withOpacity(0.9),
        onBackground: Colors.white.withOpacity(0.9),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkMystique.shadowDark.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkMystique.mysticViolet,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkMystique.shadowDark.withOpacity(0.5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkMystique.mysticViolet.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkMystique.shadowDark,
        selectedItemColor: darkMystique.mysticViolet,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: darkMystique.shadowDark,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkMystique.mysticViolet,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  /// Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Border radius constants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration animationVerySlow = Duration(milliseconds: 1000);

  /// Shadow presets
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];

  /// Gradient presets
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [
          darkMystique.mysticViolet,
          darkMystique.ghostCyan,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get successGradient => LinearGradient(
        colors: [
          darkMystique.emerald,
          darkMystique.ghostCyan,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get warningGradient => LinearGradient(
        colors: [
          darkMystique.amber,
          darkMystique.errorRed,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        colors: [
          darkMystique.shadowDark,
          darkMystique.deepVoid,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Glass morphism effect
  /// Note: For backdrop blur effect, wrap the container using this decoration
  /// with a BackdropFilter widget
  static BoxDecoration glassMorphism({
    Color? color,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double radius = 16,
  }) {
    final baseColor = color ?? darkMystique.mysticViolet;
    return BoxDecoration(
      color: baseColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: baseColor.withOpacity(borderOpacity),
        width: 1,
      ),
    );
  }
}

/// Dark Mystique Theme Color Palette
class DarkMystiqueTheme {
  const DarkMystiqueTheme();

  // Core colors
  final Color deepVoid = const Color(0xFF0A0A0F);
  final Color mysticViolet = const Color(0xFF7C3AED);
  final Color ghostCyan = const Color(0xFF00D4FF);
  final Color shadowDark = const Color(0xFF111827);

  // Status colors
  final Color emerald = const Color(0xFF10B981);
  final Color amber = const Color(0xFFF59E0B);
  final Color errorRed = const Color(0xFFEF4444);

  // Additional colors
  final Color gold = const Color(0xFFFFD700);
  final Color silver = const Color(0xFFC0C0C0);
  final Color bronze = const Color(0xFFCD7F32);

  // Neutral colors
  final Color gray100 = const Color(0xFFF3F4F6);
  final Color gray200 = const Color(0xFFE5E7EB);
  final Color gray300 = const Color(0xFFD1D5DB);
  final Color gray400 = const Color(0xFF9CA3AF);
  final Color gray500 = const Color(0xFF6B7280);
  final Color gray600 = const Color(0xFF4B5563);
  final Color gray700 = const Color(0xFF374151);
  final Color gray800 = const Color(0xFF1F2937);
  final Color gray900 = const Color(0xFF111827);

  // Chain status colors
  Color get activeColor => emerald;
  Color get pendingColor => amber;
  Color get expiredColor => errorRed;
  Color get tipColor => ghostCyan;
  Color get genesisColor => gold;
  Color get milestoneColor => mysticViolet;

  // Get color with opacity
  Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);
}