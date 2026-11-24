import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PTColors.primary,
      primary: PTColors.primary,
      secondary: PTColors.secondary,
      surface: PTColors.surface,
      brightness: Brightness.light,
    ).copyWith(
      primary: PTColors.primary,
      onPrimary: PTColors.white,
      secondary: PTColors.secondary,
      onSecondary: PTColors.white,
      surface: PTColors.surface,
      onSurface: PTColors.text,
      error: PTColors.danger,
      onError: PTColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: PTColors.background,

      visualDensity: VisualDensity.adaptivePlatformDensity,

      splashFactory: InkSparkle.splashFactory,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: PTColors.primary,
        foregroundColor: PTColors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        toolbarHeight: 64,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: PTColors.white,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(
          color: PTColors.white,
          size: 24,
        ),
      ),

      // ==========================================================
      // CARDS
      // ==========================================================

      cardTheme: CardThemeData(
        color: PTColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Mais arredondado
          side: BorderSide(
            color:
                PTColors.border.withValues(alpha: 0.4), // Borda quase invisível
            width: 1,
          ),
        ),
      ),

      // ==========================================================
      // BOTÕES
      // ==========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PTColors.primary,
          foregroundColor: PTColors.white,
          minimumSize: const Size.fromHeight(50),
          elevation: 1,
          shadowColor: PTColors.shadow,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PTColors.primary,
          foregroundColor: PTColors.white,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PTColors.primary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          side: const BorderSide(
            color: PTColors.primary,
            width: 1.2,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PTColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ==========================================================
      // CAMPOS DE TEXTO
      // ==========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PTColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: const TextStyle(
          fontSize: 15,
          color: PTColors.text,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          color: PTColors.text.withValues(alpha: 0.55),
        ),
        prefixIconColor: PTColors.primary,
        suffixIconColor: PTColors.text,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PTColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PTColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PTColors.danger,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PTColors.danger,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: PTColors.border.withValues(alpha: 0.6),
          ),
        ),
        floatingLabelStyle: const TextStyle(
          color: PTColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ==========================================================
      // DROPDOWNS
      // ==========================================================

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          fontSize: 15,
          color: PTColors.text,
        ),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(
            PTColors.surface,
          ),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      // ==========================================================
      // DIVISORES
      // ==========================================================

      dividerTheme: const DividerThemeData(
        color: PTColors.border,
        thickness: 1,
        space: 24,
      ),

      // ==========================================================
      // LISTAS
      // ==========================================================

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),

      // ==========================================================
      // ÍCONES
      // ==========================================================

      iconTheme: const IconThemeData(
        color: PTColors.primary,
        size: 24,
      ),

      // ==========================================================
      // FAB
      // ==========================================================

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PTColors.primary,
        foregroundColor: PTColors.white,
        elevation: 4,
      ),

      // ==========================================================
      // DIÁLOGOS
      // ==========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: PTColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: PTColors.text,
        ),
      ),

      // ==========================================================
      // SNACKBAR
      // ==========================================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ==========================================================
      // TOOLTIP
      // ==========================================================

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PTColors.text,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: PTColors.white,
          fontSize: 13,
        ),
      ),

      // ==========================================================
      // PROGRESSO
      // ==========================================================

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PTColors.primary,
      ),

      // ==========================================================
      // TIPOGRAFIA
      // ==========================================================

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: PTColors.text,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: PTColors.text,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: PTColors.primary,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: PTColors.primary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: PTColors.text,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: PTColors.text,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.35,
          color: PTColors.text,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: PTColors.text,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PTColors.text,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: PTColors.text,
        ),
      ),
    );
  }
}
