import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';

abstract final class AppTextStyles {
  static const rowTitle = TextStyle(fontSize: 17, color: AppColors.label);
  static const rowSubtitle = TextStyle(
    fontSize: 15,
    height: 1.2,
    color: AppColors.mutedText,
  );
  static const switchTitle = TextStyle(fontSize: 16, color: AppColors.label);
  static const caption = TextStyle(fontSize: 12, color: AppColors.mutedText);
  static const sectionHeader = TextStyle(
    fontSize: 13,
    color: AppColors.mutedText,
  );
  static const statusValue = TextStyle(fontSize: 17);
  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier'],
    fontSize: 11,
    color: AppColors.label,
  );
}

/// The themed [ElevatedButton] is the primary (blue) action; use [callback]
/// for the "...with callback" variant, as the native demos do.
abstract final class AppButtonStyles {
  static final callback = ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
  );
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    error: AppColors.destructive,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.surface,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: const TextStyle(color: AppColors.placeholder),
      border: _fieldBorder(AppColors.fieldBorder),
      enabledBorder: _fieldBorder(AppColors.fieldBorder),
      focusedBorder: _fieldBorder(AppColors.primary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.label,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.primary),
      actionsIconTheme: IconThemeData(color: AppColors.primary),
      shape: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 12),
        side: const BorderSide(color: AppColors.divider),
        selectedBackgroundColor: AppColors.selected,
        selectedForegroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Thin rounded border like a UIKit `roundedRect` text field.
OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(6),
  borderSide: BorderSide(color: color),
);
