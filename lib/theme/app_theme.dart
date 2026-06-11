import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralised theming for Campus Fit.
///
/// All colours and sizes flow from a single seed colour via
/// [ColorScheme.fromSeed] and from [ThemeData], rather than being hardcoded in
/// individual widgets. Both light and dark variants are provided so the app can
/// follow the system setting (see `themeMode` on the [MaterialApp]).
class AppTheme {
  AppTheme._();

  static const double pagePadding = 20.0;
  static const double cardRadius = 20.0;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandTeal,
      secondary: AppColors.accentCoral,
      brightness: brightness,
    );

    // Display/headline in Inria Serif (the mockup's brand serif); body and
    // labels in Inter. Roboto remains the implicit fallback for inputs.
    final baseText = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final textTheme = baseText.copyWith(
      displayLarge: GoogleFonts.inriaSerif(textStyle: baseText.displayLarge),
      displayMedium: GoogleFonts.inriaSerif(textStyle: baseText.displayMedium),
      displaySmall: GoogleFonts.inriaSerif(textStyle: baseText.displaySmall),
      headlineLarge: GoogleFonts.inriaSerif(textStyle: baseText.headlineLarge),
      headlineMedium: GoogleFonts.inriaSerif(textStyle: baseText.headlineMedium),
      headlineSmall: GoogleFonts.inriaSerif(textStyle: baseText.headlineSmall),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inriaSerif(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      // Buttons default to a 56dp height. We deliberately do NOT use
      // Size.fromHeight here — that sets the minimum *width* to infinity, which
      // crashes when a themed button is a non-flex child of a Row. Screens that
      // want full-width buttons impose it via stretch or a width-bounded parent.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
