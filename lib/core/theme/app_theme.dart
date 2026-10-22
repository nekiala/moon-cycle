import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Builds the app's dark theme. The app has no light theme: it is about the
/// night sky and is mostly used at night.
abstract final class AppTheme {
  static const String displayFont = 'Cormorant Garamond';
  static const String bodyFont = 'Inter';

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.moonlight,
      onPrimary: AppColors.night,
      secondary: AppColors.gold,
      onSecondary: AppColors.night,
      tertiary: AppColors.lavender,
      onTertiary: AppColors.night,
      error: AppColors.error,
      onError: AppColors.night,
      surface: AppColors.night,
      onSurface: AppColors.moonlight,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.night,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHigh,
      outline: AppColors.outline,
      outlineVariant: AppColors.outline,
    );

    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      fontFamily: bodyFont,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.moonlight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.night,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.surfaceHigh,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.night,
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle display(double size, FontWeight weight, {double spacing = 0}) =>
        TextStyle(
          fontFamily: displayFont,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          height: 1.1,
          color: scheme.onSurface,
        );
    TextStyle body(
      double size,
      FontWeight weight, {
      double spacing = 0,
      Color? color,
    }) => TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      height: 1.4,
      color: color ?? scheme.onSurface,
    );

    return TextTheme(
      displayLarge: display(56, FontWeight.w500, spacing: -0.5),
      displayMedium: display(44, FontWeight.w500),
      displaySmall: display(36, FontWeight.w500),
      headlineLarge: display(32, FontWeight.w600),
      headlineMedium: display(28, FontWeight.w600),
      headlineSmall: display(24, FontWeight.w600),
      titleLarge: display(22, FontWeight.w600, spacing: 0.2),
      titleMedium: body(16, FontWeight.w500, spacing: 0.1),
      titleSmall: body(14, FontWeight.w500, spacing: 0.1),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(12, FontWeight.w400, color: scheme.onSurfaceVariant),
      labelLarge: body(14, FontWeight.w600, spacing: 0.4),
      labelMedium: body(
        12,
        FontWeight.w500,
        spacing: 0.6,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: body(
        11,
        FontWeight.w500,
        spacing: 0.8,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
