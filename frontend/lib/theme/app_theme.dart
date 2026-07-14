import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFFF57C00);
  static const secondary = Color(0xFF2E7D32);
  static const background = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0E0E0);

  static const greyBg = Color(0xFFF5F5F5);
  static const orangeTint = Color(0xFFFFF3E0);
  static const greenTint = Color(0xFFE8F5E9);
  static const blueTint = Color(0xFFE3F2FD);

  static const pendingBg = Color(0xFFFFF3E0);
  static const pendingText = Color(0xFFE65100);
  static const inProgressBg = Color(0xFFE3F2FD);
  static const inProgressText = Color(0xFF1565C0);
  static const resolvedBg = Color(0xFFE8F5E9);
  static const resolvedText = Color(0xFF2E7D32);
  static const rejectedBg = Color(0xFFFCEBEB);
  static const rejectedText = Color(0xFFA32D2D);

  static const splashGradientEnd = Color(0xFFE65100);

  static const mutedText = Color(0xFF9E9E9E);
  static const secondaryText = Color(0xFF616161);
  static const inputBorder = Color(0xFFD9D9D9);
  static const navInactive = Color(0xFFBDBDBD);
}

class AppGradients {
  AppGradients._();

  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const cta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.secondary],
  );
}

class AppSpacing {
  AppSpacing._();

  static const screen = 16.0;
  static const gap = 10.0;
  static const gapSm = 8.0;
}

class AppRadius {
  AppRadius._();

  static const card = 14.0;
  static const button = 10.0;
  static const chip = 20.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData? _cachedLight;

  static ThemeData light() => _cachedLight ??= _buildLight();

  static ThemeData _buildLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.rejectedText,
      onError: Colors.white,
      surface: AppColors.background,
      onSurface: Color(0xFF212121),
    );

    final poppins = GoogleFonts.poppinsTextTheme();
    final notoDevanagari = GoogleFonts.notoSansDevanagariTextTheme();

    // Avoid GoogleFonts.* inside WidgetState resolvers (nav rebuilds often).
    const navSelected = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    );
    const navUnselected = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.navInactive,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: poppins.apply(
        bodyColor: const Color(0xFF212121),
        displayColor: const Color(0xFF212121),
      ),
      primaryTextTheme: notoDevanagari,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryText,
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
        hintStyle: GoogleFonts.poppins(color: AppColors.mutedText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.orangeTint,
        labelPadding: const EdgeInsets.only(top: 4, bottom: 4),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? navSelected
              : navUnselected;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.primary : AppColors.navInactive,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.greyBg;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return const Color(0xFF616161);
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
      ),
    );
  }
}
