import 'package:flutter/material.dart';

/// Dark Mystique Theme for The Chain
///
/// Design Philosophy: Mysterious, elegant, slightly gothic with cosmic undertones.
/// Think: Connected chains in a mystical void, ethereal glows, trustworthy yet enigmatic.
class DarkMystiqueTheme {
  // ============================================================================
  // COLOR PALETTE - Dark Mystique
  // ============================================================================

  /// Deep blacks - Primary backgrounds
  static const Color deepVoid = Color(0xFF0A0A0F);
  static const Color voidSecondary = Color(0xFF12121A);

  /// Dark purple-grays - Surface colors
  static const Color shadowPurple = Color(0xFF1A1A2E);
  static const Color twilightGray = Color(0xFF16213E);

  /// Mystical purples - Primary brand colors
  static const Color mysticViolet = Color(0xFF8B5CF6);
  static const Color etherealPurple = Color(0xFFA78BFA);
  static const Color deepMagenta = Color(0xFFD946EF);

  /// Ethereal cyans - Secondary/accent colors
  static const Color ghostCyan = Color(0xFF06B6D4);
  static const Color astralCyan = Color(0xFF22D3EE);

  /// Text colors
  static const Color textPrimary = Color(0xFFE4E4E7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  /// Status colors with mystique
  static const Color successGlow = Color(0xFF10B981);
  static const Color warningAura = Color(0xFFF59E0B);
  static const Color errorPulse = Color(0xFFEF4444);

  // ============================================================================
  // AGENT STATUS COLORS - Material Design Palette
  // For visual status indicators with high contrast and accessibility
  // ============================================================================

  /// Agent Status: In Progress (Active Work)
  /// Material Green 500 - Semantic "go" signal
  static const Color statusInProgress = Color(0xFF4CAF50);

  /// Agent Status: Focused (Deep Concentration)
  /// Material Amber 500 - Attention/caution signal
  static const Color statusFocused = Color(0xFFFFC107);

  /// Agent Status: Idle (No Active Work)
  /// Material Gray 700 - Neutral inactive state
  static const Color statusIdle = Color(0xFF616161);

  /// Agent Status: Blocked (Cannot Proceed)
  /// Material Red 500 - Error/stop signal
  static const Color statusBlocked = Color(0xFFF44336);

  /// Agent Status: Satisfied (Recently Completed)
  /// Material Light Blue 500 - Success/completion
  static const Color statusSatisfied = Color(0xFF03A9F4);

  /// Agent Status: Happy (Milestone/Success)
  /// Material Light Green 500 - Positive achievement
  static const Color statusHappy = Color(0xFF8BC34A);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static const LinearGradient voidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepVoid, voidSecondary, shadowPurple],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient mysticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mysticViolet, etherealPurple],
  );

  static const LinearGradient astralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ghostCyan, astralCyan],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x40A78BFA), // Soft purple glow
      Color(0x00A78BFA), // Fade to transparent
    ],
  );

  // ============================================================================
  // SHADOWS & GLOWS
  // ============================================================================

  static List<BoxShadow> get purpleGlow => [
    BoxShadow(
      color: mysticViolet.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: etherealPurple.withValues(alpha: 0.2),
      blurRadius: 40,
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> get cyanGlow => [
    BoxShadow(
      color: ghostCyan.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      spreadRadius: -5,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(
      color: mysticViolet.withValues(alpha: 0.2),
      blurRadius: 25,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      spreadRadius: -5,
      offset: const Offset(0, 10),
    ),
  ];

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  static const String _primaryFont = 'Inter';
  static const String _displayFont = 'Outfit';

  static TextTheme get textTheme => TextTheme(
    // Display - Large headings with mystical feel
    displayLarge: TextStyle(
      fontFamily: _displayFont,
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: textPrimary,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontFamily: _displayFont,
      fontSize: 45,
      fontWeight: FontWeight.w300,
      letterSpacing: 0,
      color: textPrimary,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontFamily: _displayFont,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textPrimary,
      height: 1.2,
    ),

    // Headline - Section headers
    headlineLarge: TextStyle(
      fontFamily: _displayFont,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: textPrimary,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.75,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textPrimary,
    ),

    // Title - Card titles, labels
    titleLarge: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.25,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.75,
      color: textSecondary,
    ),

    // Body - Regular text
    bodyLarge: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textMuted,
    ),

    // Label - Button text, labels
    labelLarge: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: _primaryFont,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
      color: textMuted,
    ),
  );

  // ============================================================================
  // THEME DATA
  // ============================================================================

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: mysticViolet,
        onPrimary: Colors.white,
        primaryContainer: shadowPurple,
        onPrimaryContainer: etherealPurple,

        secondary: ghostCyan,
        onSecondary: Colors.white,
        secondaryContainer: twilightGray,
        onSecondaryContainer: astralCyan,

        tertiary: deepMagenta,
        onTertiary: Colors.white,

        error: errorPulse,
        onError: Colors.white,

        surface: shadowPurple,
        onSurface: textPrimary,
        surfaceContainerHighest: twilightGray,
        onSurfaceVariant: textSecondary,

        outline: Color(0xFF3F3F46),
        shadow: Colors.black,
      ),

      // Scaffold
      scaffoldBackgroundColor: deepVoid,

      // Typography
      textTheme: textTheme,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: shadowPurple.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: etherealPurple),
      ),

      // Card
      cardTheme: CardThemeData(
        color: shadowPurple,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: mysticViolet.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mysticViolet,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: mysticViolet.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(
            fontFamily: _primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: etherealPurple,
          textStyle: TextStyle(
            fontFamily: _primaryFont,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: twilightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: mysticViolet.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: mysticViolet.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ghostCyan,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorPulse,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: errorPulse,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontFamily: _primaryFont,
          letterSpacing: 0.5,
        ),
        hintStyle: TextStyle(
          color: textMuted,
          fontFamily: _primaryFont,
        ),
        prefixIconColor: etherealPurple,
        suffixIconColor: textSecondary,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: etherealPurple,
        circularTrackColor: shadowPurple,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: mysticViolet.withValues(alpha: 0.1),
        thickness: 1,
        space: 32,
      ),

      // Icon
      iconTheme: IconThemeData(
        color: etherealPurple,
        size: 24,
      ),
    );
  }
}
