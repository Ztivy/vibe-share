import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);       // violeta principal
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color accent = Color(0xFFFF6B6B);        // coral para likes/CTAs
  static const Color accentGold = Color(0xFFFFD166);    // premium / destacados

  // ── Neutrales Light ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EFF8);
  static const Color border = Color(0xFFE2E0F0);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6880);
  static const Color textHint = Color(0xFFAEACBF);

  // ── Neutrales Dark ───────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1C1B2E);
  static const Color surfaceVariantDark = Color(0xFF252440);
  static const Color borderDark = Color(0xFF2E2D45);
  static const Color textPrimaryDark = Color(0xFFF0EFF8);
  static const Color textSecondaryDark = Color(0xFFA09DBF);

  // ── Semánticos ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF118AB2);
}

class AppTextStyles {
  AppTextStyles._();

  static const String fontDisplay = 'Syne';       // headings llamativos
  static const String fontBody = 'DM Sans';       // cuerpo legible

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w800,
    fontSize: 36,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w700,
    fontSize: 22,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontDisplay,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontBody,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.5,
  );
}

class ThemeApp {
  ThemeApp._();

  // ── Radios globales ───────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 999.0;

  // ── Espaciado ─────────────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.accentGold,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.border,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontDisplay,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        selectedColor: AppColors.primary,
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.accentGold,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        outline: AppColors.borderDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(
        AppColors.textPrimaryDark,
        AppColors.textSecondaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontDisplay,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        selectedColor: AppColors.primary,
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: primary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: primary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: primary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: secondary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: primary),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: secondary),
    );
  }
}
