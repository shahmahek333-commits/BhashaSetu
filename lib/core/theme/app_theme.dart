import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central theme configuration for BhasaSetu adhering to Material 3
/// and the pastel educational design language.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final baseColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLavender,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lavenderLight,
      onPrimaryContainer: AppColors.lavenderDark,
      secondary: AppColors.secondaryBlue,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.blueLight,
      onSecondaryContainer: AppColors.blueDark,
      tertiary: AppColors.tertiaryGreen,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.greenLight,
      onTertiaryContainer: AppColors.greenDark,
      error: AppColors.statusError,
      onError: Colors.white,
      surface: AppColors.whiteCard,
      onSurface: AppColors.darkCharcoal,
      surfaceContainerHighest: AppColors.creamAlt,
      outline: AppColors.cardBorder,
      outlineVariant: AppColors.creamAlt,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: AppColors.softCream,
      fontFamily: null, // Uses platform default font with high legibility

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.softCream,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkCharcoal,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.whiteCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.cardBorder,
            width: 1.0,
          ),
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.whiteCard,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.lavenderLight,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLavender,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoalMuted,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primaryLavender,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.charcoalMuted,
              size: 24,
            );
          },
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLavender,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLavender,
          side: const BorderSide(color: AppColors.primaryLavender, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLavender, width: 1.8),
        ),
        hintStyle: const TextStyle(
          color: AppColors.charcoalLight,
          fontSize: 14,
        ),
      ),

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkCharcoal,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: AppColors.charcoalMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: AppColors.charcoalLight,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
