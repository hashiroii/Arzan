import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppTheme {
  AppTheme._();

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryYellow,
        primaryContainer: AppColors.primaryYellowLight,
        secondary: AppColors.accentOrange,
        error: AppColors.error,
        surface: AppColors.white,
        onPrimary: AppColors.black,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.black,
        background: AppColors.grey100,
        onBackground: AppColors.black,
      ),
      scaffoldBackgroundColor: AppColors.grey100,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.h6.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.grey300,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        titleSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.overline,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryYellow,
        primaryContainer: AppColors.primaryYellowDark,
        secondary: AppColors.accentOrange,
        error: AppColors.error,
        surface: AppColors.grey800,
        onPrimary: AppColors.black,
        onSecondary: AppColors.white,
        onError: AppColors.white,
        onSurface: AppColors.white,
        background: AppColors.grey900,
        onBackground: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.grey900,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.grey800,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.h6.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.grey800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.white),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
        headlineLarge: AppTextStyles.h1.copyWith(color: AppColors.white),
        headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.white),
        headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.white),
        titleLarge: AppTextStyles.h4.copyWith(color: AppColors.white),
        titleMedium: AppTextStyles.h5.copyWith(color: AppColors.white),
        titleSmall: AppTextStyles.h6.copyWith(color: AppColors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.grey300),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.white),
        labelMedium: AppTextStyles.caption.copyWith(color: AppColors.grey300),
        labelSmall: AppTextStyles.overline.copyWith(color: AppColors.grey400),
      ),
    );
  }
}
